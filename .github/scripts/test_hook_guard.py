import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / ".claude" / "hooks"))

from check_file_reservations import Reservation
from guard_file_reservations import validate_file_edit


def row(task_id, paths, status="En desarrollo"):
    return Reservation(task_id, "Cuenta A", "Jhonn", "Zadiel", tuple(paths), status)


class ClaudeEditGuardTests(unittest.TestCase):
    def test_main_is_never_editable(self):
        allowed, _ = validate_file_edit("main", "game/src/Server.lua", [])
        self.assertFalse(allowed)

    def test_only_task_branches_are_editable(self):
        allowed, _ = validate_file_edit("feature/work", "game/src/Server.lua", [])
        self.assertFalse(allowed)

    def test_registry_can_be_reserved_before_implementation(self):
        allowed, _ = validate_file_edit("task/GAME-001-new-system", "ACTIVE_TASKS.md", [])
        self.assertTrue(allowed)

    def test_reserved_route_is_editable(self):
        reservations = [row("GAME-001", ["game/**"])]
        allowed, _ = validate_file_edit(
            "task/GAME-001-new-system", "game/src/Server.lua", reservations
        )
        self.assertTrue(allowed)

    def test_unreserved_route_is_blocked(self):
        reservations = [row("GAME-001", ["game/src/Server.lua"])]
        allowed, _ = validate_file_edit(
            "task/GAME-001-new-system", "game/src/Client.lua", reservations
        )
        self.assertFalse(allowed)

    def test_route_reserved_by_another_active_task_is_blocked(self):
        reservations = [
            row("GAME-001", ["game/**"]),
            row("WORLD-002", ["game/src/**"]),
        ]
        allowed, _ = validate_file_edit(
            "task/GAME-001-new-system", "game/src/Server.lua", reservations
        )
        self.assertFalse(allowed)

    def test_completed_reservation_cannot_be_used_to_edit(self):
        reservations = [row("GAME-001", ["game/**"], "Completada")]
        allowed, _ = validate_file_edit(
            "task/GAME-001-new-system", "game/src/Server.lua", reservations
        )
        self.assertFalse(allowed)


if __name__ == "__main__":
    unittest.main()
