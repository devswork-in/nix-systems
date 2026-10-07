import subprocess
import unittest
from unittest.mock import patch

import power_profile


class PowerProfileMenuTest(unittest.TestCase):
    def test_icons_do_not_reach_the_kernel_profile_value(self):
        label = f"{power_profile.ICONS['performance']}\u2003performance"
        with patch.object(power_profile, "get_choices", return_value=["balanced", "performance"]), patch.object(
            power_profile, "get_current_profile", return_value="balanced"
        ), patch.object(power_profile.subprocess, "run") as run:
            run.return_value = subprocess.CompletedProcess([], 0, label + "\n")
            power_profile.show_menu()
            self.assertEqual(run.call_args_list[0].kwargs["input"], "\u2003balanced\n\u2003performance")
            self.assertEqual(run.call_args_list[1].kwargs["input"], "performance\n")

    def test_cancelled_or_unknown_selection_does_not_write(self):
        for status, output in [(1, "\u2003performance"), (0, "unknown"), (0, "")]:
            with self.subTest(status=status, output=output), patch.object(
                power_profile, "get_choices", return_value=["balanced", "performance"]
            ), patch.object(power_profile, "get_current_profile", return_value="balanced"), patch.object(
                power_profile.subprocess, "run", return_value=subprocess.CompletedProcess([], status, output)
            ) as run:
                power_profile.show_menu()
                self.assertEqual(run.call_count, 1)


if __name__ == "__main__":
    unittest.main()
