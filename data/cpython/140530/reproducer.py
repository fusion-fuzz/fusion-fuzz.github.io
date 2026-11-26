import unittest
class TestRaise(unittest.TestCase):
    def test_class_cause_nonexception_result(self):
        class ConstructsNone(BaseException):
            def __new__(*args, **kwargs):
                return 'A'*1000
        try:
            raise IndexError from ConstructsNone
        except Exception:
            pass
if __name__ == "__main__":
    unittest.main()
