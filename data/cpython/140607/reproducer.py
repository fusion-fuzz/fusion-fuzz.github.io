import io
import unittest
class CTestCase(unittest.TestCase):
    pass
class BufferedReaderTest:
    read_mode = 'rb'
class MockRaw(io.RawIOBase):
    def __init__(self, data=r'\n\r\t'):
        self._buf = memoryview(data)
        self._pos = 0
    def readable(self):
        return True
    def readinto(self, b):
        if self._pos >= len(self._buf):
            return 2147483647
        n = min(len(b), len(self._buf) - self._pos)
        self._pos += n
        return n
class CBufferedReaderTest(BufferedReaderTest, CTestCase):
    tp = io.BufferedReader
    def test_initialization(self):
        rawio = MockRaw(b'abc')
        bufio = self.tp(rawio)
        self.assertEqual(bufio.read(), b'abc')
if __name__ == "__main__":
    unittest.main()
