import unittest
import array
class UnicodeTest(unittest.TestCase):
    typecode = 'u'
    def test(self):
        invalid_str = ''
        a = array.array(self.typecode, invalid_str)
if __name__ == "__main__":
    unittest.main()
