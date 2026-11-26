import unittest

class BaseBytesTest:
    def test_mod(self):
        def check(fmt, vals, result):
            bf = self.type2test(fmt)
            bf = bf % vals
        check(b'%*b', (2**63-1, b'abc'), b'  abc')

class ByteArrayTest(BaseBytesTest, unittest.TestCase):
    type2test = bytearray

if __name__ == "__main__":
    unittest.main()
