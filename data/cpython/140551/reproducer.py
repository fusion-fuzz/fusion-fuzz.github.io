import unittest
class Test(unittest.TestCase):
    def test(self):
        class X(object):
            def __hash__(self):
                return -1
            def __eq__(self, other):
                    d.clear()
        d = {}
        d[X()] = 3
        d[X()] = 4
        d[0.0] = 6
        self.assertIn(9, d)
if __name__ == "__main__":
    unittest.main()
