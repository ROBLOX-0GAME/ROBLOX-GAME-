#!/usr/bin/env python3
"""Validate task branches and reserved paths before a PR can merge."""

from __future__ import annotations

import base64
import fnmatch
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any

TASK_BRANCH = re.compile(r"^task/([A-Z][A-Z0-9]*-\d+)-[a-z0-9]+(?:-[a-z0-9]+)*$")
LOCKED_STATUSES = {"en desarrollo", "en progreso", "bloqueada"}
REGISTRY_PATHS = {"ACTIVE_TASKS.md", "09 - TAREAS Y DESARROLLO/Backlog.md"}


@dataclass(frozen=True)
class Reservation:
    task_id: str
    account: str
    owner: str
    reviewer: str
    paths: tuple[str, ...]
    status: str


def extract_task_id(branch: str) -> str | None:
    match = TASK_BRANCH.fullmatch(branch)
    return match.group(1) if match else None


def parse_reservations(markdown: str) -> list[Reservation]:
    reservations: list[Reservation] = []
    for line in markdown.splitlines():
        if not line.strip().startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 6 or cells[0].casefold() == "id" or set(cells[0]) <= {"-", " "}:
            continue
        task_id = cells[0].strip()
        if not re.fullmatch(r"[A-Z][A-Z0-9]*-\d+", task_id):
            continue
        path_cell = cells[4]
        paths = tuple(
            item.strip().replace(chr(96), "").strip()
            for item in re.split(r"<br\s*/?>|;", path_cell, flags=re.IGNORECASE)
            if item.strip()
        )
        if not paths:
            continue
        reservations.append(
            Reservation(
                task_id=task_id,
                account=cells[1],
                owner=cells[2],
                reviewer=cells[3],
                paths=paths,
                status=cells[5].strip(),
            )
        )
    return reservations


def path_matches(path: str, pattern: str) -> bool:
    pattern = pattern.strip().replace(chr(96), "")
    if not pattern:
        return False
    if pattern.endswith("/**"):
        prefix = pattern[:-3].rstrip("/")
        if path == prefix or path.startswith(prefix + "/"):
            return True
    return fnmatch.fnmatchcase(path, pattern)


def paths_conflict(path: str, patterns: tuple[str, ...] | list[str]) -> bool:
    return any(path_matches(path, pattern) for pattern in patterns)


def reservation_patterns_overlap(first: str, second: str) -> bool:
    first = first.strip().replace(chr(96), "").removeprefix("./")
    second = second.strip().replace(chr(96), "").removeprefix("./")
    if not first or not second:
        return False
    if first == second or first in {"*", "**"} or second in {"*", "**"}:
        return True

    first_directory = first.endswith("/**")
    second_directory = second.endswith("/**")
    if first_directory and second_directory:
        first_prefix = first[:-3].rstrip("/")
        second_prefix = second[:-3].rstrip("/")
        return (
            first_prefix == second_prefix
            or first_prefix.startswith(second_prefix + "/")
            or second_prefix.startswith(first_prefix + "/")
        )
    if first_directory:
        return True if any(char in second for char in "*?[") else path_matches(second, first)
    if second_directory:
        return True if any(char in first for char in "*?[") else path_matches(first, second)

    if any(char in first or char in second for char in "*?["):
        # For unsupported glob combinations, reject conservatively rather than miss a collision.
        return True
    return first == second


def reservation_paths_overlap(
    first: tuple[str, ...] | list[str], second: tuple[str, ...] | list[str]
) -> bool:
    first_routes = [path for path in first if path.strip().replace(chr(96), "") not in REGISTRY_PATHS]
    second_routes = [path for path in second if path.strip().replace(chr(96), "") not in REGISTRY_PATHS]
    return any(
        reservation_patterns_overlap(left, right)
        for left in first_routes
        for right in second_routes
    )


def normalize_status(status: str) -> str:
    return " ".join(status.casefold().split())


def other_task_reservations(markdown: str, task_id: str) -> list[Reservation]:
    return sorted(
        (row for row in parse_reservations(markdown) if row.task_id != task_id),
        key=lambda row: (row.task_id, row.paths, row.status),
    )


def without_task_section(markdown: str, task_id: str) -> str:
    section = re.compile(
        rf"^###\s+{re.escape(task_id)}\b.*?(?=^###\s+[A-Z][A-Z0-9]*-\d+\b|\Z)",
        flags=re.MULTILINE | re.DOTALL,
    )
    return section.sub("", markdown)


def backlog_edit_is_scoped(
    before: str, after: str, task_id: str, initial_bootstrap: bool = False
) -> bool:
    return initial_bootstrap or without_task_section(before, task_id) == without_task_section(after, task_id)


def task_pr_state(task_id: str, pull_requests: list[dict[str, Any]]) -> str:
    matches = [
        pr for pr in pull_requests
        if extract_task_id(str(pr.get("ref", ""))) == task_id
    ]
    if any(pr.get("state") == "open" for pr in matches):
        return "open"
    if not matches:
        return "none"
    latest = max(matches, key=lambda pr: int(pr.get("number", 0)))
    if latest.get("merged"):
        return "merged"
    return "closed"


def reservation_is_active(
    reservation: Reservation, pull_requests: list[dict[str, Any]]
) -> bool:
    status = normalize_status(reservation.status)
    if status in LOCKED_STATUSES:
        return True
    if status == "en revisión":
        return task_pr_state(reservation.task_id, pull_requests) != "merged"
    return False


def github_get_all(repository: str, endpoint: str, token: str) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    page = 1
    while True:
        separator = "&" if "?" in endpoint else "?"
        url = f"https://api.github.com/repos/{repository}/{endpoint}{separator}per_page=100&page={page}"
        request = urllib.request.Request(
            url,
            headers={
                "Accept": "application/vnd.github+json",
                "Authorization": f"Bearer {token}",
                "X-GitHub-Api-Version": "2022-11-28",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                batch = json.loads(response.read().decode("utf-8"))
        except (urllib.error.URLError, json.JSONDecodeError) as exc:
            raise RuntimeError(f"No se pudo consultar GitHub ({endpoint}): {exc}") from exc
        if not isinstance(batch, list):
            raise RuntimeError(f"GitHub devolvió una respuesta inesperada para {endpoint}.")
        items.extend(batch)
        if len(batch) < 100:
            return items
        page += 1


def github_get(repository: str, endpoint: str, token: str) -> dict[str, Any]:
    request = urllib.request.Request(
        f"https://api.github.com/repos/{repository}/{endpoint}",
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            result = json.loads(response.read().decode("utf-8"))
    except (urllib.error.URLError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"No se pudo consultar GitHub ({endpoint}): {exc}") from exc
    if not isinstance(result, dict):
        raise RuntimeError(f"GitHub devolvió una respuesta inesperada para {endpoint}.")
    return result


def reservation_text_at_commit(commit: str) -> str:
    result = subprocess.run(
        ["git", "show", f"{commit}:ACTIVE_TASKS.md"],
        check=False,
        capture_output=True,
        text=True,
    )
    return result.stdout if result.returncode == 0 else ""


def reservation_text_at_ref(repository: str, commit: str, token: str) -> str:
    result = github_get(
        repository,
        f"contents/ACTIVE_TASKS.md?ref={commit}",
        token,
    )
    if result.get("encoding") != "base64" or not result.get("content"):
        raise RuntimeError("GitHub no devolvió ACTIVE_TASKS.md codificado en base64.")
    return base64.b64decode(result["content"]).decode("utf-8")


def changed_paths(base_sha: str, head_sha: str) -> set[str]:
    result = subprocess.run(
        ["git", "diff", "--name-only", f"{base_sha}...{head_sha}"],
        check=True,
        capture_output=True,
        text=True,
    )
    return {line.strip() for line in result.stdout.splitlines() if line.strip()}


def normalized_pull_requests(raw: list[dict[str, Any]]) -> list[dict[str, Any]]:
    result = []
    for pr in raw:
        result.append(
            {
                "number": pr.get("number", 0),
                "ref": ((pr.get("head") or {}).get("ref") or ""),
                "base": ((pr.get("base") or {}).get("ref") or ""),
                "state": pr.get("state"),
                "merged": bool(pr.get("merged_at")),
                "head_sha": ((pr.get("head") or {}).get("sha") or ""),
            }
        )
    return result


def main() -> int:
    event_path = os.environ.get("GITHUB_EVENT_PATH")
    repository = os.environ.get("GITHUB_REPOSITORY")
    token = os.environ.get("GITHUB_TOKEN")
    if not event_path or not repository or not token:
        print("Faltan GITHUB_EVENT_PATH, GITHUB_REPOSITORY o GITHUB_TOKEN.", file=sys.stderr)
        return 2

    event = json.loads(Path(event_path).read_text(encoding="utf-8"))
    pr = event.get("pull_request")
    if not pr:
        print("Este control debe ejecutarse desde un evento pull_request.", file=sys.stderr)
        return 2
    base = pr["base"]
    head = pr["head"]
    base_ref = base["ref"]
    if base_ref != "main":
        print("Los Pull Requests de desarrollo deben dirigirse a main.")
        return 1

    task_id = extract_task_id(head["ref"])
    if not task_id:
        print("La rama debe tener el formato task/<ID>-<slug>, por ejemplo task/INFRA-001-coordination-rojo.")
        return 1

    body = pr.get("body") or ""
    if not re.search(rf"(?im)^\s*Task ID:\s*{re.escape(task_id)}\s*$", body):
        print(f"El cuerpo del Pull Request debe incluir exactamente Task ID: {task_id}.")
        return 1

    base_sha = base["sha"]
    head_sha = head["sha"]
    changed = changed_paths(base_sha, head_sha)
    if not changed:
        print("No se encontraron archivos modificados en el Pull Request.")
        return 1

    head_text = Path("ACTIVE_TASKS.md").read_text(encoding="utf-8")
    base_text = reservation_text_at_commit(base_sha)
    head_rows = parse_reservations(head_text)
    if "ACTIVE_TASKS.md" in changed:
        if other_task_reservations(base_text, task_id) != other_task_reservations(head_text, task_id):
            print("El Pull Request solo puede crear o actualizar su propia fila en ACTIVE_TASKS.md.")
            return 1
    backlog_path = "09 - TAREAS Y DESARROLLO/Backlog.md"
    if backlog_path in changed:
        base_backlog = subprocess.run(
            ["git", "show", f"{base_sha}:{backlog_path}"],
            check=False,
            capture_output=True,
            text=True,
        )
        if base_backlog.returncode != 0:
            base_backlog_text = ""
        else:
            base_backlog_text = base_backlog.stdout
        head_backlog_text = Path(backlog_path).read_text(encoding="utf-8")
        initial_bootstrap = (
            task_id == "INFRA-001"
            and not any(row.task_id == task_id for row in parse_reservations(base_text))
        )
        if not backlog_edit_is_scoped(
            base_backlog_text, head_backlog_text, task_id, initial_bootstrap
        ):
            print(f"El Pull Request solo puede crear o actualizar la sección {task_id} en Backlog.md.")
            return 1
    own_rows = [row for row in head_rows if row.task_id == task_id]
    if len(own_rows) != 1:
        print(f"ACTIVE_TASKS.md debe tener exactamente una fila para {task_id}.")
        return 1
    own = own_rows[0]
    code_changed = changed - REGISTRY_PATHS
    not_reserved = sorted(
        path for path in code_changed if not paths_conflict(path, own.paths)
    )
    if not_reserved:
        print("El Pull Request modifica rutas fuera de su reserva:")
        for path in not_reserved:
            print(f"  - {path}")
        return 1

    all_prs = normalized_pull_requests(github_get_all(repository, "pulls?state=all", token))
    open_prs = [pull for pull in all_prs if pull["state"] == "open"]
    base_rows = parse_reservations(base_text)
    base_ids = {item.task_id for item in base_rows}

    active_rows = [
        row for row in base_rows
        if row.task_id != task_id and reservation_is_active(row, all_prs)
    ]
    for row in head_rows:
        if row.task_id == task_id or row.task_id in base_ids:
            continue
        if reservation_is_active(row, all_prs):
            active_rows.append(row)

    open_pr_paths: dict[int, set[str]] = {}
    for other in open_prs:
        if other["number"] == pr["number"] or other["base"] != "main":
            continue
        files = github_get_all(repository, f"pulls/{other['number']}/files", token)
        other_paths = {item.get("filename", "") for item in files if item.get("filename")}
        open_pr_paths[other["number"]] = other_paths
        if "ACTIVE_TASKS.md" not in other_paths:
            continue
        other_text = reservation_text_at_ref(repository, other["head_sha"], token)
        for row in parse_reservations(other_text):
            if row.task_id == task_id:
                print(f"El Pull Request #{other['number']} reutiliza el ID {task_id}.")
                return 1
            if reservation_is_active(row, all_prs):
                active_rows.append(row)

    reservation_collisions = [
        (row.task_id, row.status)
        for row in active_rows
        if reservation_is_active(row, all_prs)
        and reservation_paths_overlap(own.paths, row.paths)
    ]
    if reservation_collisions:
        print("La reserva de esta tarea se solapa con una reserva activa:")
        for other_id, status in reservation_collisions:
            print(f"  - Coincide con {other_id} ({status}).")
        return 1

    active_conflicts: list[tuple[str, str, str]] = []
    for row in active_rows:
        if not reservation_is_active(row, all_prs):
            continue
        for path in sorted(code_changed):
            if paths_conflict(path, row.paths):
                active_conflicts.append((row.task_id, path, row.status))

    if active_conflicts:
        print("El Pull Request invade rutas reservadas por otra tarea:")
        for other_id, path, status in active_conflicts:
            print(f"  - {path} está reservada por {other_id} ({status}).")
        return 1

    for other in open_prs:
        if other["number"] == pr["number"] or other["base"] != "main":
            continue
        other_paths = open_pr_paths.get(other["number"], set())
        overlap = sorted((changed - REGISTRY_PATHS) & (other_paths - REGISTRY_PATHS))
        if overlap:
            print(f"El Pull Request #{other['number']} abierto modifica las mismas rutas:")
            for path in overlap:
                print(f"  - {path}")
            return 1

    print(
        f"Reserva validada para {task_id}: {len(code_changed)} rutas de trabajo revisadas; "
        f"sin reservas duplicadas ni Pull Requests abiertos con rutas solapadas."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyError, OSError, RuntimeError, subprocess.CalledProcessError, ValueError) as exc:
        print(f"Error en el control de reservas: {exc}", file=sys.stderr)
        raise SystemExit(2)
