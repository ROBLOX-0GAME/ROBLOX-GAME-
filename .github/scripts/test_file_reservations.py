import unittest

from check_file_reservations import (
    Reservation,
    extract_task_id,
    parse_reservations,
    path_matches,
    reservation_is_active,
)


class ReservationTests(unittest.TestCase):
    def test_extracts_task_id_from_per_task_branch(self):
        self.assertEqual(extract_task_id("task/INFRA-001-coordination-rojo"), "INFRA-001")
        self.assertIsNone(extract_task_id("feature/combat"))

    def test_parses_markdown_registry(self):
        text = """| ID | Cuenta | Responsable | Revisor | Rutas reservadas | Estado |
|---|---|---|---|---|---|
| INFRA-001 | Cuenta A | Jhonn y Zadiel | Michael y Einell | game/**<br>ACTIVE_TASKS.md | En desarrollo |
"""
        rows = parse_reservations(text)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0].task_id, "INFRA-001")
        self.assertEqual(rows[0].paths, ("game/**", "ACTIVE_TASKS.md"))

    def test_directory_glob_covers_nested_files(self):
        self.assertTrue(path_matches("game/src/server/Main.server.lua", "game/**"))
        self.assertFalse(path_matches("other/game/file.lua", "game/**"))

    def test_exact_path_reservation(self):
        self.assertTrue(path_matches("ACTIVE_TASKS.md", "ACTIVE_TASKS.md"))
        self.assertFalse(path_matches("Backlog.md", "ACTIVE_TASKS.md"))

    def test_in_review_stays_reserved_until_its_pr_merges(self):
        row = Reservation("INFRA-001", "Cuenta A", "Jhonn y Zadiel", "Michael y Einell", ("game/**",), "En revisión")
        self.assertTrue(reservation_is_active(row, [{"number": 12, "ref": "task/INFRA-001-coordination-rojo", "state": "open"}]))
        self.assertFalse(reservation_is_active(row, [{"number": 12, "ref": "task/INFRA-001-coordination-rojo", "state": "closed", "merged": True}]))

    def test_development_reservation_stays_active(self):
        row = Reservation("INFRA-002", "Cuenta B", "Michael y Einell", "Zadiel y Jhonn", ("game/**",), "En desarrollo")
        self.assertTrue(reservation_is_active(row, []))


if __name__ == "__main__":
    unittest.main()
