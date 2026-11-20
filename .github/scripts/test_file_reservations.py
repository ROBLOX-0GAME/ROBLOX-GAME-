import unittest

from check_file_reservations import (
    Reservation,
    extract_task_id,
    parse_reservations,
    path_matches,
    reservation_is_active,
    reservation_patterns_overlap,
    reservation_paths_overlap,
    other_task_reservations,
    without_task_section,
    backlog_edit_is_scoped,
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

    def test_directory_reservations_overlap_when_nested(self):
        self.assertTrue(reservation_patterns_overlap("game/**", "game/src/**"))
        self.assertFalse(reservation_patterns_overlap("game/src/**", "game/docs/**"))

    def test_exact_route_overlaps_directory_reservation(self):
        self.assertTrue(reservation_patterns_overlap("game/src/server.lua", "game/**"))
        self.assertFalse(reservation_patterns_overlap("docs/Plan.md", "game/**"))

    def test_registry_paths_are_shared_and_not_double_booked(self):
        self.assertFalse(reservation_paths_overlap(
            ("ACTIVE_TASKS.md", "09 - TAREAS Y DESARROLLO/Backlog.md"),
            ("ACTIVE_TASKS.md", "09 - TAREAS Y DESARROLLO/Backlog.md"),
        ))
        self.assertTrue(reservation_paths_overlap(("game/**",), ("game/src/**",)))

    def test_task_registry_edit_only_removes_own_section(self):
        before = "### INFRA-001 — Setup\n- Estado: En desarrollo\n\n### GAME-002 — Sistema\n- Estado: Pendiente\n"
        after = "### INFRA-001 — Setup\n- Estado: Completada\n\n### GAME-002 — Sistema\n- Estado: Pendiente\n"
        altered_other = "### INFRA-001 — Setup\n- Estado: Completada\n\n### GAME-002 — Sistema\n- Estado: En progreso\n"
        self.assertEqual(without_task_section(before, "INFRA-001"), without_task_section(after, "INFRA-001"))
        self.assertNotEqual(without_task_section(before, "INFRA-001"), without_task_section(altered_other, "INFRA-001"))

    def test_backlog_changes_must_stay_in_own_task_section_after_bootstrap(self):
        before = "### GAME-001 — First\n- Status: Pending\n\n### GAME-002 — Second\n- Status: Pending\n"
        after_own = "### GAME-001 — First\n- Status: Complete\n\n### GAME-002 — Second\n- Status: Pending\n"
        after_other = "### GAME-001 — First\n- Status: Complete\n\n### GAME-002 — Second\n- Status: Active\n"
        self.assertTrue(backlog_edit_is_scoped(before, after_own, "GAME-001"))
        self.assertFalse(backlog_edit_is_scoped(before, after_other, "GAME-001"))
        self.assertTrue(backlog_edit_is_scoped(before, after_other, "INFRA-001", True))

    def test_reservation_registry_comparison_excludes_only_own_task(self):
        before = "| ID | Cuenta | Responsable | Revisor | Rutas reservadas | Estado |\n|---|---|---|---|---|---|\n| INFRA-001 | A | X | Y | .claude/** | En desarrollo |\n| GAME-001 | B | M | E | game/** | En desarrollo |\n"
        self.assertEqual([row.task_id for row in other_task_reservations(before, "INFRA-001")], ["GAME-001"])

    def test_in_review_stays_reserved_until_its_pr_merges(self):
        row = Reservation("INFRA-001", "Cuenta A", "Jhonn y Zadiel", "Michael y Einell", ("game/**",), "En revisión")
        self.assertTrue(reservation_is_active(row, [{"number": 12, "ref": "task/INFRA-001-coordination-rojo", "state": "open"}]))
        self.assertFalse(reservation_is_active(row, [{"number": 12, "ref": "task/INFRA-001-coordination-rojo", "state": "closed", "merged": True}]))

    def test_development_reservation_stays_active(self):
        row = Reservation("INFRA-002", "Cuenta B", "Michael y Einell", "Zadiel y Jhonn", ("game/**",), "En desarrollo")
        self.assertTrue(reservation_is_active(row, []))


if __name__ == "__main__":
    unittest.main()
