#!/usr/bin/env bash
set -u

project_dir="$CLAUDE_PROJECT_DIR"
if [ -z "$project_dir" ]; then
  project_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
fi
script="$project_dir/.claude/hooks/guard_file_reservations.py"

if command -v python3 >/dev/null 2>&1; then
  exec python3 "$script"
fi
if command -v python >/dev/null 2>&1; then
  exec python "$script"
fi

printf '%s\n' "Python 3 es necesario; se bloquea la edición por seguridad." >&2
exit 2
