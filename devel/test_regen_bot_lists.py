import pathlib
import subprocess
import sys
import tempfile
import unittest


class RegenerateBotListsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = pathlib.Path(self.temp.name)
        self.repo = self.root / "devstats"
        self.script = self.repo / "devel/regen_bot_lists.py"
        source = pathlib.Path(__file__).with_name("regen_bot_lists.py").read_text()
        self.put("devstats/devel/regen_bot_lists.py", source)
        self.master = "not like all(array['googlebot', 'mentatbot', 'github-harold_pins', '%[bot]%'])\n"
        self.put("devstats/util_sql/exclude_bots.sql", self.master)
        self.put("devstats/util_sql/only_bots.sql", "like any(array['googlebot'])\n")
        self.put("devstats/util_sql/exclude_bots_table_insert.sql", "select unnest(array['googlebot']);\n")
        self.put("devstats/util_sql/actors.sql", "select login not like all(array['googlebot']);\n")
        self.put("devstats/structure.sql", "COPY public.gha_bot_logins (pattern) FROM stdin;\ngooglebot\n\\.\n")
        self.put("devstats-reports/sql/report.sql", "select login not like all(array['googlebot']);\n")
        (self.root / "velocity/sql").mkdir(parents=True)
        self.query = (
            "select * from events where\n"
            "  org.login in ('praxis', 'airunway') and\n"
            "  (type = 'PushEvent' or (\n"
            "    actor.login not like 'k8s-%'\n"
            "  ));\n"
        )
        self.put("velocity/BigQuery/velocity_legacy.sql", self.query)
        self.put("velocity/BigQuery/velocity_standard_query.sql", "#standardSQL\n" + self.query)
        self.put("velocity/BigQuery/velocity_condition_cncf.sql", "org.login in ('praxis', 'airunway')\n")
        self.put("velocity/tools/enrich_authors/main.go", "var devstatsBotRE = regexp.MustCompile(`^$`)\n")
        self.put("devstatscode/rust/compat/fixtures/calc_metric/exclude_bots.sql", "old\n")

    def put(self, relative, contents):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(contents)

    def run_generator(self):
        return subprocess.run([sys.executable, str(self.script)], text=True, capture_output=True)

    def snapshot(self):
        return {p.relative_to(self.root): p.read_bytes() for p in self.root.rglob("*") if p.is_file()}

    def test_propagation_and_idempotence(self):
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for path in [
            "velocity/sql/exclude_bots.sql",
            "devstatscode/rust/compat/fixtures/calc_metric/exclude_bots.sql",
        ]:
            self.assertEqual((self.root / path).read_text(), self.master)
        structure = (self.repo / "structure.sql").read_text()
        self.assertIn("googlebot\nmentatbot\ngithub-harold_pins\n%[bot]%\n\\.", structure)
        for filename, function in [
            ("velocity_legacy.sql", "REGEXP_MATCH"),
            ("velocity_standard_query.sql", "REGEXP_CONTAINS"),
        ]:
            query = (self.root / "velocity/BigQuery" / filename).read_text()
            clause = next(line for line in query.splitlines(True) if "-- devstats bots" in line)
            self.assertIn(function, clause)
            self.assertIn(r"github-harold.pins|.*\[bot\].*", clause)
            expected = self.query if function == "REGEXP_MATCH" else "#standardSQL\n" + self.query
            self.assertEqual(query.replace(clause, ""), expected)
        self.assertEqual(
            (self.root / "velocity/BigQuery/velocity_condition_cncf.sql").read_text(),
            "org.login in ('praxis', 'airunway')\n",
        )
        before = self.snapshot()
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_invalid_patterns_do_not_write_files(self):
        for master in [
            "not like all(array['googlebot', 'googlebot'])\n",
            "not like all(array['googlebot', 'MentatBot'])\n",
        ]:
            with self.subTest(master=master):
                self.put("devstats/util_sql/exclude_bots.sql", master)
                before = self.snapshot()
                result = self.run_generator()
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.snapshot(), before)

    def test_broad_bot_substrings_are_replaced(self):
        for prefix in ("", "TRUE\n    AND "):
            with self.subTest(prefix=prefix):
                old = prefix + "LOWER(actor.login) not like '%bot%'"
                query = self.query.replace("actor.login not like 'k8s-%'", old)
                self.put("velocity/BigQuery/velocity_top30.sql", query)
                result = self.run_generator()
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                updated = (self.root / "velocity/BigQuery/velocity_top30.sql").read_text()
                self.assertNotIn("not like '%bot%'", updated)
                clause = next(line for line in updated.splitlines(True) if "-- devstats bots" in line)
                replacement = "    " + ("AND " if prefix else "") + "LOWER(actor.login) not like '%bot%'\n"
                self.assertEqual(updated.replace(clause, replacement), query)
                before = self.snapshot()
                result = self.run_generator()
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(self.snapshot(), before)


if __name__ == "__main__":
    unittest.main()
