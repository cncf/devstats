import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import unittest


class FlagsReportTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="devstats-flags-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = pathlib.Path(self.temp.name)
        (self.root / "devel").mkdir()
        (self.root / "bin").mkdir()
        for name in ("devstats-flags-report.sh", "mega_health_check.sh"):
            shutil.copy2(pathlib.Path(__file__).with_name(name), self.root / "devel" / name)
        for stage in ("prod", "test"):
            (self.root / "devel" / f"all_{stage}_dbs.txt").write_text("cii\n")
        self.fixture = self.root / "fixture.json"
        self.trace = self.root / "calls.jsonl"
        self.mutation = self.root / "mutation"
        repair = self.root / "devel/rebuild-table.sh"
        repair.write_text('#!/usr/bin/env bash\nprintf "unexpected repair\\n" > "$FLAGS_MUTATION"\nexit 99\n')
        repair.chmod(0o755)
        kubectl = self.root / "bin/kubectl"
        kubectl.write_text(
            f"#!{sys.executable}\n"
            """import json, os, sys
from pathlib import Path
a = sys.argv[1:]
f = json.loads(Path(os.environ["FLAGS_FIXTURE"]).read_text())
with open(os.environ["FLAGS_TRACE"], "a") as out:
    out.write(json.dumps(a) + "\\n")
if a[:3] == ["config", "get-contexts", "-o"]:
    print("prod\\ntest")
elif "get" in a and a[a.index("get") + 1] == "pods":
    if any(v.startswith("jsonpath=") for v in a):
        if not f.get("missing_primary"):
            print("devstats-postgres-0")
    elif "--no-headers" in a:
        print(f.get("pods", ""), end="")
    else:
        print(json.dumps({"items": f.get("provisioning", [])}))
elif "exec" in a:
    command = a[a.index("--") + 1:]
    if command[:2] == ["bash", "-s"]:
        assert "select substr(metric, 11)" in sys.stdin.read()
        print("\\n".join(f.get("affiliations", [])))
    elif command[0] == "psql":
        db = command[command.index("ON_ERROR_STOP=1") + 1]
        sql = command[command.index("-c") + 1]
        if "row_number() OVER" in sql:
            if db not in f.get("missing_provisioned", []):
                print("provisioned|2026-10-19 00:00:00|0|00:00:00")
        elif "total_attribute_slots" in sql:
            print("\\n".join(f.get("slots", {}).get(db, [])))
        elif not any(s in sql for s in ("from gha_computed", "from gha_locks", "pg_stat_activity")):
            raise AssertionError("Unexpected SQL: " + sql)
    else:
        raise AssertionError("Unexpected exec: " + repr(command))
else:
    raise AssertionError("Unexpected kubectl call: " + repr(a))
"""
        )
        kubectl.chmod(0o755)

    def run_report(self, fixture, stage="test", mega=False):
        self.fixture.write_text(json.dumps(fixture))
        self.trace.write_text("")
        env = os.environ.copy()
        for key in ("POD", "PROVISIONING_RE", "COLS_SLOTS_THRESHOLD"):
            env.pop(key, None)
        env.update(
            PATH=str(self.root / "bin") + os.pathsep + env["PATH"],
            FLAGS_FIXTURE=str(self.fixture),
            FLAGS_TRACE=str(self.trace),
            FLAGS_MUTATION=str(self.mutation),
            STAGES=stage,
            ONLY="flags",
            SKIP="",
            DEBUG="0",
            VERBOSE="0",
            CONTAINER="devstats-postgres",
        )
        script = "mega_health_check.sh" if mega else "devstats-flags-report.sh"
        command = ["bash", str(self.root / "devel" / script)]
        if not mega:
            command.append(stage)
        result = subprocess.run(command, cwd=self.root, env=env, text=True, capture_output=True)
        self.assertFalse(self.mutation.exists(), "Health checking must never execute repairs")
        for line in self.trace.read_text().splitlines():
            args = json.loads(line)
            self.assertFalse(set(args) & {"delete", "patch", "apply", "create", "replace"})
        return result

    def test_healthy_reports_remain_successful(self):
        for mega in (False, True):
            with self.subTest(mega=mega):
                result = self.run_report({}, mega=mega)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertNotIn("NOT OK", result.stdout)
                self.assertNotIn("repair after", result.stdout)

    def test_failed_pod_is_identified_in_both_summaries(self):
        pod = "devstats-backup-gha-20261009-0544-v896v"
        fixture = {"pods": f"{pod} 0/1 Error 0 10d\n"}
        for mega in (False, True):
            with self.subTest(mega=mega):
                result = self.run_report(fixture, stage="prod", mega=mega)
                self.assertEqual(result.returncode, 3 if mega else 10, result.stdout + result.stderr)
                summary = result.stdout.split("NOT OK: prod")[-1]
                self.assertIn(f"devstats-prod/{pod} (Error)", summary)
                self.assertIn("DEBUG=1 ./devel/devstats-flags-report.sh prod", summary)

    def test_all_column_targets_and_commands_survive_summary(self):
        fixture = {
            "slots": {
                "cii": ["public|sact|1438|1286|152", "metrics|other_table|1500|1400|100"],
                "devstats": ["public|sgh_stats_r|1518|1400|118"],
            }
        }
        for stage in ("prod", "test"):
            for mega in (False, True):
                with self.subTest(stage=stage, mega=mega):
                    result = self.run_report(fixture, stage=stage, mega=mega)
                    self.assertEqual(result.returncode, 3 if mega else 10, result.stdout + result.stderr)
                    summary = result.stdout.split(f"NOT OK: {stage}")[-1]
                    for db, table in (("cii", "public.sact"), ("cii", "metrics.other_table"),
                                      ("devstats", "public.sgh_stats_r")):
                        self.assertIn(f"namespace=devstats-{stage} db={db} table={table}", summary)
                        self.assertIn(
                            f"NS=devstats-{stage} POD=devstats-postgres-0 "
                            f"CONTAINER=devstats-postgres devel/rebuild-table.sh {db} {table}",
                            summary,
                        )
                    self.assertIn(f"check context {stage}", summary)
                    self.assertIn("pause writers", summary)

    def test_early_helper_failure_keeps_actual_error(self):
        result = self.run_report({"missing_primary": True}, stage="prod", mega=True)
        self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
        self.assertIn("rc=4", result.stdout)
        self.assertIn("could not resolve the Patroni primary pod in devstats-prod", result.stdout)

    def test_affiliation_import_stays_a_notice(self):
        fixture = {"missing_provisioned": ["cii"], "affiliations": ["cii"]}
        result = self.run_report(fixture, mega=True)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("affiliations import holds affs_lock", result.stdout)
        self.assertNotIn("CRIT  [flags]", result.stdout)

    def test_provisioning_stays_a_notice(self):
        fixture = {
            "missing_provisioned": ["cii"],
            "provisioning": [{
                "metadata": {"name": "devstats-provision-cii", "labels": {"type": "provision", "proj": "cii"}},
                "spec": {},
                "status": {"phase": "Running"},
            }],
        }
        result = self.run_report(fixture, mega=True)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("while being provisioned/merged", result.stdout)
        self.assertNotIn("CRIT  [flags]", result.stdout)

    def test_real_failure_is_not_hidden_by_affiliation_import(self):
        fixture = {
            "missing_provisioned": ["cii"],
            "affiliations": ["cii"],
            "pods": "broken-pod 0/1 CrashLoopBackOff 4 1h\n",
        }
        result = self.run_report(fixture, mega=True)
        self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
        self.assertIn("devstats-test/broken-pod (CrashLoopBackOff)", result.stdout)
        self.assertIn("affiliations import in progress", result.stdout)


if __name__ == "__main__":
    unittest.main()
