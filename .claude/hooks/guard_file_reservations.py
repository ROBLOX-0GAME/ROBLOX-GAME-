#!/usr/bin/env python3
"""Block Claude Code edits outside an active task reservation."""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPTS_DIR = REPO_ROOT / ".github" / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

from check_file_reservations import (  # noqa: E402
    REGISTRY_PATHS,
    extract_task_id,
    normalize_status,
    parse_reservations,
    paths_conflict,
)

LOCAL_LOCKED_STATUSES = {
    "en desarrollo",
    "en progreso",
    "bloqueada",
    "en revisión",
}


def validate_file_edit(
    branch: str, relative_path: str, reservations: list
) -> tuple[bool, str]:
    if branch == "main":
        return False, "No se permiten ediciones directas en main; crea una rama task/<ID>-<slug>."
    task_id = extract_task_id(branch)
    if not task_id:
        return False, "La edición requiere una rama task/<ID>-<slug>."
    if relative_path in REGISTRY_PATHS:
        return True, "Ruta del registro central; CI limita las filas que puede cambiar cada tarea."

    own_rows = [row for row in reservations if row.task_id == task_id]
    if len(own_rows) != 1:
        return False, f"{task_id} no tiene una reserva única integrada en ACTIVE_TASKS.md."
    own = own_rows[0]
    if normalize_status(own.status) not in LOCAL_LOCKED_STATUSES:
        return False, f"La reserva de {task_id} no está activa."
    if not paths_conflict(relative_path, own.paths):
        return False, f"{relative_path} no pertenece a la reserva activa de {task_id}."

    for row in reservations:
        if row.task_id == task_id:
            continue
        if normalize_status(row.status) not in LOCAL_LOCKED_STATUSES:
            continue
        if paths_conflict(relative_path, row.paths):
            return False, f"{relative_path} está reservada por otra tarea: {row.task_id}."
    return True, f"{relative_path} está reservada para {task_id}."


def git_output(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=root,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def repository_name(root: Path) -> str:
    remote = git_output(root, "remote", "get-url", "origin")
    match = re.search(r"github\.com[:/]([^/\s]+/[^/\s]+?)(?:\.git)?$", remote)
    if not match:
        raise RuntimeError("El remoto origin no identifica este repositorio de GitHub.")
    return match.group(1)


def fetch_main_reservations(root: Path, branch: str) -> str:
    repository = repository_name(root)
    url = f"https://raw.githubusercontent.com/{repository}/main/ACTIVE_TASKS.md"
    request = urllib.request.Request(url, headers={"User-Agent": "Roblox-Game-Reservation-Guard"})
    try:
        with urllib.request.urlopen(request, timeout=8) as response:
            return response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        if exc.code == 404 and extract_task_id(branch) == "INFRA-001":
            bootstrap_file = root / "ACTIVE_TASKS.md"
            if bootstrap_file.is_file():
                return bootstrap_file.read_text(encoding="utf-8")
        raise RuntimeError(
            "No se pudo leer ACTIVE_TASKS.md de main; por seguridad se bloquea la edición."
        ) from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(
            "No se pudo consultar la reserva central; por seguridad se bloquea la edición."
        ) from exc


def repository_relative_path(root: Path, raw_path: str, cwd: str) -> str:
    candidate = Path(raw_path)
    if not candidate.is_absolute():
        candidate = Path(cwd) / candidate
    resolved = candidate.resolve()
    try:
        return resolved.relative_to(root.resolve()).as_posix()
    except ValueError as exc:
        raise RuntimeError("La ruta está fuera del repositorio autorizado.") from exc


def main() -> int:
    try:
        payload = json.load(sys.stdin)
        tool_input = payload.get("tool_input") or {}
        raw_path = tool_input.get("file_path")
        if not raw_path:
            raise RuntimeError("Claude Code no proporcionó la ruta del archivo.")

        cwd = payload.get("cwd") or os.getcwd()
        root = Path(git_output(Path(cwd), "rev-parse", "--show-toplevel"))
        branch = git_output(root, "branch", "--show-current")
        relative_path = repository_relative_path(root, str(raw_path), cwd)

        allowed, reason = validate_file_edit(
            branch,
            relative_path,
            parse_reservations(fetch_main_reservations(root, branch)),
        )
        if not allowed:
            print(reason, file=sys.stderr)
            return 2
        return 0
    except Exception as exc:
        print(f"Control de reserva falló; edición bloqueada: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
