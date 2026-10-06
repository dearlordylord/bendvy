"""Decision controls: slowdown, improvement, noise, ties and invalid samples."""
import unittest
from decision import assess


def rows(js, native):
    return [{"backend": backend, "pair": i, "baselineMs": 100,
             "candidateMs": value} for backend, values in (("JS", js), ("Native", native))
            for i, value in enumerate(values)]


class DecisionControls(unittest.TestCase):
    def test_confirmed_slowdown(self):
        result = assess(rows([101]*20, [100]*20), 20, .05)
        self.assertEqual(result["status"], "REGRESSION")
        self.assertTrue(result["endpoints"]["JS"]["confirmedRegression"])
        self.assertFalse(result["endpoints"]["Native"]["confirmedRegression"])

    def test_improvement_noise_and_ties(self):
        for samples in ([99]*20, [99, 101]*10, [100]*20):
            self.assertEqual(assess(rows(samples, [100]*20), 20, .05)["status"], "NO_CONFIRMED_REGRESSION")

    def test_holm_rejects_unadjusted_false_alarm(self):
        result = assess(rows([101]*17+[99]*7, [100]*24), 24, .05)
        self.assertLess(result["endpoints"]["JS"]["pValue"], .05)
        self.assertEqual(result["status"], "NO_CONFIRMED_REGRESSION")
        # 14/20 slower has p≈.0577; 15/20 p≈.0207 passes the .025 first cutoff.
        for slower, status in ((14, "NO_CONFIRMED_REGRESSION"), (15, "REGRESSION")):
            self.assertEqual(assess(rows([101]*slower+[99]*(20-slower), [100]*20), 20, .05)["status"], status)

    def test_invalid_or_missing_measurements_fail(self):
        for samples in ([101]*19, [float("nan")]*20, [0]*20):
            with self.assertRaises(ValueError):
                assess(rows(samples, [100]*20), 20, .05)


if __name__ == "__main__":
    unittest.main()
