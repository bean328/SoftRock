"""Tests for the SoftRock design tokens and generator."""

import re
import unittest

import generate

HEX = re.compile(r"^#[0-9A-Fa-f]{6}$")


def luminance(color):
    def channel(v):
        v = v / 255
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4

    r, g, b = (int(color[i:i + 2], 16) for i in (1, 3, 5))
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)


def contrast(a, b):
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


class TokenTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.t = generate.load_tokens()

    def test_every_color_has_valid_light_and_dark(self):
        for name, pair in self.t["colors"].items():
            self.assertEqual(set(pair), {"light", "dark"}, name)
            for mode, value in pair.items():
                self.assertRegex(value, HEX, f"{name}.{mode}")

    def test_terminal_palette(self):
        term = self.t["terminal"]["dark"]
        self.assertEqual(len(term["regular"]), 8)
        self.assertEqual(len(term["bright"]), 8)
        for value in term["regular"] + term["bright"] + [term["background"], term["foreground"]]:
            self.assertRegex(value, HEX)

    def test_text_contrast_meets_wcag_aa(self):
        c = self.t["colors"]
        checks = [
            ("text", "background", 4.5),
            ("text", "surface", 4.5),
            ("text", "surfaceAlt", 4.5),
            ("textMuted", "background", 4.5),
            ("textMuted", "surface", 4.5),
            ("accentText", "accent", 4.5),
            ("accent", "surface", 3.0),
            ("good", "surface", 3.0),
            ("warn", "surface", 3.0),
            ("bad", "surface", 3.0),
        ]
        for fg, bg, minimum in checks:
            for mode in ("light", "dark"):
                ratio = contrast(c[fg][mode], c[bg][mode])
                self.assertGreaterEqual(
                    ratio, minimum, f"{fg} on {bg} ({mode}) is {ratio:.2f}, needs {minimum}"
                )

    def test_tiers_scale_up(self):
        tiers = self.t["tiers"]
        self.assertEqual(list(tiers), ["lite", "standard", "ultra"])
        self.assertFalse(tiers["lite"]["blur"])
        self.assertLessEqual(tiers["standard"]["blurPasses"], tiers["ultra"]["blurPasses"])
        self.assertLessEqual(tiers["lite"]["shadowRange"], tiers["standard"]["shadowRange"])


class GeneratorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.files = generate.outputs(generate.load_tokens())

    def test_generated_files_are_committed_and_current(self):
        for path, content in self.files.items():
            self.assertTrue(path.exists(), f"{path} missing, run make tokens")
            self.assertEqual(path.read_text(encoding="utf-8"), content, f"{path} stale, run make tokens")

    def test_qml_is_a_singleton_with_every_color(self):
        qml = next(v for k, v in self.files.items() if k.name == "Theme.qml")
        self.assertIn("pragma Singleton", qml)
        for name in generate.load_tokens()["colors"]:
            self.assertIn(f"property color {name}:", qml)
        self.assertEqual(qml.count("{"), qml.count("}"))

    def test_hyprland_snippets_balance_braces(self):
        for path, content in self.files.items():
            if path.suffix == ".conf":
                self.assertEqual(content.count("{"), content.count("}"), path.name)

    def test_lite_tier_disables_blur_and_shadow(self):
        lite = next(v for k, v in self.files.items() if k.name == "tier-lite.conf")
        self.assertRegex(lite, r"blur \{\n\s+enabled = false")
        self.assertRegex(lite, r"shadow \{\n\s+enabled = false")


if __name__ == "__main__":
    unittest.main()
