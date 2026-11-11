"""Unprivileged regression tests for the imperative rebuild workflow."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "modules/core/configs/common/scripts"


class RebuildHelpersTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.repo = self.root / "current checkout"
        self.repo.mkdir()
        self.target = self.root / "etc-nixos"
        self.target.symlink_to(self.repo)
        self.log = self.root / "commands"
        self.env = dict(os.environ, PATH=f"{self.bin}:{os.environ['PATH']}",
                        HOME=str(self.root), XDG_CACHE_HOME=str(self.root / "cache"),
                        NIX_SYSTEM="omnix", TEST_REPO=str(self.repo), TEST_LOG=str(self.log))
        self.helper("hostname", 'echo omnix\n')
        (self.root / "nixos-config-sync").write_text('printf "%s\\n" "$TEST_REPO"\n')
        self.helper("sudo", '''printf '%s\\n' "$*" >> "$TEST_LOG"
case "$*" in
  *nixos-rebuild*) exit "${BUILD_STATUS:-0}" ;;
  *systemctl*) exit "${SYNC_STATUS:-0}" ;;
  ln*) exit "${LINK_STATUS:-0}" ;;
esac
''')

    def helper(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env bash\nset -eu\n" + body)
        path.chmod(0o755)

    def run_script(self, name, *args):
        # Redirect the fixed system path into the fixture; never touch real /etc.
        script = self.root / name
        script.write_text((SCRIPTS / name).read_text().replace("/etc/nixos", str(self.target)))
        return subprocess.run(["bash", str(script), *args], env=self.env,
                              cwd=self.repo, capture_output=True, text=True)

    def commands(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_switch_updates_link_then_waits_for_sync(self):
        result = self.run_script("sysrebuild", "--show-trace")
        self.assertEqual(result.returncode, 0, result.stderr)
        commands = self.commands()
        self.assertEqual(commands, [
            f"NIX_CONFIG_DIR={self.repo} nixos-rebuild switch --flake {self.repo}#omnix --impure --show-trace",
            f"ln -sfnT -- {self.repo} {self.target}",
            "systemctl restart nix-repo-sync.service",
        ])

    def test_failed_switch_does_not_relink_or_sync(self):
        self.env["BUILD_STATUS"] = "42"
        result = self.run_script("sysrebuild")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(self.commands()), 1)

    def test_sync_failure_is_reported(self):
        self.env["SYNC_STATUS"] = "7"
        result = self.run_script("sysrebuild")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("switched", result.stderr)
        self.assertIn("sync", result.stderr)

    def test_refuses_real_config_directory(self):
        self.target.unlink()
        self.target.mkdir()
        result = self.run_script("sysrebuild")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.commands(), [])
        self.assertTrue(self.target.is_dir())

    def test_failed_relink_does_not_sync(self):
        self.env["LINK_STATUS"] = "1"
        result = self.run_script("sysrebuild")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(self.commands()), 2)

    def test_dry_run_does_not_relink_or_sync(self):
        result = self.run_script("sysrebuild", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.commands()), 1)

    def test_current_worktree_beats_valid_cache(self):
        (self.repo / "hosts/omnix").mkdir(parents=True)
        (self.repo / "flake.nix").touch()
        old = self.root / "old"
        (old / "hosts/omnix").mkdir(parents=True)
        (old / "flake.nix").touch()
        cache = self.root / "cache/nix-systems-repo"
        cache.parent.mkdir()
        cache.write_text(str(old) + "\n")
        self.helper("git", 'printf "%s\\n" "$TEST_REPO"\n')
        result = self.run_script("nixos-config-sync")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.repo))
        self.assertEqual(cache.read_text().strip(), str(self.repo))

    def test_discovery_uses_requested_host(self):
        (self.repo / "hosts/other-host").mkdir(parents=True)
        (self.repo / "flake.nix").touch()
        self.env["NIX_SYSTEM"] = "other-host"
        self.helper("git", 'printf "%s\\n" "$TEST_REPO"\n')
        result = self.run_script("nixos-config-sync")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.repo))


if __name__ == "__main__":
    unittest.main()
