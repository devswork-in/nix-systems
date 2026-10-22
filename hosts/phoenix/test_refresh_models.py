"""Run with: python3 -m unittest discover -s hosts/phoenix -p 'test_*.py'."""
import importlib.util
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("refresh_models", Path(__file__).with_name("refresh-models.py"))
refresh = importlib.util.module_from_spec(spec)
spec.loader.exec_module(refresh)


class RefreshModelsTest(unittest.TestCase):
    def test_only_current_cli_models_are_used(self):
        catalog = {"opencode": {"models": {
            "current": {"cost": {"input": 0, "output": 0}},
            "retired": {"cost": {"input": 0, "output": 0}},
        }}}
        self.assertEqual(refresh.free_models("opencode/current\nopencode/current\n", catalog), ["current"])

    def test_empty_paid_and_unknown_models_fail_closed(self):
        for output, metadata in [
            ("", {}),
            ("opencode/paid", {"paid": {"cost": {"input": 1, "output": 0}}}),
            ("opencode/unknown", {}),
            ("opencode/missing", {"missing": {"cost": {"input": 0}}}),
            ("opencode/invalid", {"invalid": {"cost": {"input": False, "output": 0}}}),
        ]:
            with self.subTest(output=output), self.assertRaises((ValueError, KeyError)):
                refresh.free_models(output, {"opencode": {"models": metadata}})

    def test_update_preserves_operator_fields_and_input(self):
        provider = {"adapter": "opencode-cli", "defaultModel": "retired", "apiKey": "test-only",
                    "disabled": True, "customHeaders": {"X-Example": "value"},
                    "models": ["retired"], "selectedModels": ["retired"],
                    "modelCapabilities": {"current": {"inputModalities": ["image"], "contextWindow": 123}}}
        updated = refresh.provider_update(provider, ["current"])
        self.assertEqual(provider["models"], ["retired"])
        self.assertEqual(updated["apiKey"], "test-only")
        self.assertTrue(updated["disabled"])
        self.assertEqual(updated["customHeaders"], provider["customHeaders"])
        self.assertEqual(updated["defaultModel"], "current")
        self.assertEqual(updated["models"], ["current"])
        self.assertEqual(updated["selectedModels"], ["current"])
        self.assertFalse(updated["liveModels"])
        self.assertEqual(updated["modelCapabilities"]["current"],
                         {"inputModalities": ["text"], "contextWindow": 123})

    def test_failed_discovery_never_calls_management_api(self):
        with patch.object(refresh, "bundled_opencode", return_value="/nix/store/test/bin/opencode"), \
             patch.object(refresh.subprocess, "run", side_effect=TimeoutError), \
             patch.dict(refresh.os.environ, {"HOME": "/tmp", "OPENCODEX_HOME": "/tmp", "OPENCODE_BIN": "opencode"}), \
             patch.object(refresh, "request") as request:
            with self.assertRaises(TimeoutError):
                refresh.main()
            request.assert_not_called()


if __name__ == "__main__":
    unittest.main()
