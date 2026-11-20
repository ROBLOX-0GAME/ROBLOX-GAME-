#!/usr/bin/env python3
"""Validate task branches and reserved paths before a PR can merge."""

from __future__ import annotations

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


def normalize_status(status: str) -> str:
    return " ".join(status.casefold().split())


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
    head_rows = parse_reservations(head_text)
    own_rows = [row for row in head_rows if row.task_id == task_id]
    if len(own_rows) != 1:
        print(f"ACTIVE_TASKS.md debe tener exactamente una fila para {task_id}.")
        return 1
    own = own_rows[0]
    not_reserved = sorted(path for path in changed if not paths_conflict(path, own.paths))
    if not_reserved:
        print("El Pull Request modifica rutas fuera de su reserva:")
        for path in not_reserved:
            print(f"  - {path}")
        return 1

    all_prs = normalized_pull_requests(github_get_all(repository, "pulls?state=all", token))
    open_prs = [pull for pull in all_prs if pull["state"] == "open"]
    base_rows = parse_reservations(reservation_text_at_commit(base_sha))
    base_ids = {item.task_id for item in base_rows}
    active_conflicts: list[tuple[str, str, str]] = []

    for row in base_rows:
        if row.task_id == task_id or not reservation_is_active(row, all_prs):
            continue
        for path in sorted(changed):
            if paths_conflict(path, row.paths):
                active_conflicts.append((row.task_id, path, row.status))

    for row in head_rows:
        if row.task_id == task_id or row.task_id in base_ids:
            continue
        if not reservation_is_active(row, all_prs):
            continue
        for path in sorted(changed):
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
        files = github_get_all(repository, f"pulls/{other['number']}/files", token)
        other_paths = {item.get("filename", "") for item in files}
        overlap = sorted(changed & other_paths)
        if overlap:
            print(f"El Pull Request #{other['number']} abierto modifica las mismas rutas:")
            for path in overlap:
                print(f"  - {path}")
            return 1

    print(
        f"Reserva validada para {task_id}: {len(changed)} rutas revisadas; "
        f"sin reservas ajenas ni Pull Requests abiertos con rutas solapadas."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyError, OSError, RuntimeError, subprocess.CalledProcessError, ValueError) as exc:
        print(f"Error en el control de reservas: {exc}", file=sys.stderr)
        raise SystemExit(2)
