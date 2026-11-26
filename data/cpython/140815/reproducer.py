import faulthandler
import sys
import unittest

class Test(unittest.TestCase):
    def setUp(self):
        faulthandler.dump_traceback_later(10 * 1e-308, exit=True, file=sys.__stderr__)
    def test_sendall(self):
        os.mkfifo(filename)

if __name__ == '__main__':
    unittest.main()
