import tokenize
import unittest
from io import BytesIO, StringIO
from unittest import TestCase, mock
def stringify_tokens_from_source(token_generator, source_string):
    result = []
    for type, token, start, end, line in token_generator:
        result.append(f"    {type:10} {token!r:13} {start} {end}")
class TokenizeTest(TestCase):
    def check_tokenize(self, s, expected):
        self.check_tokenize("1 + 1", """\
    """)
    def test_tabs(self):
        self.check_tokenize("def f():\n"
                            "\tif x\n"
                            '\x00', """\
    """)
    def check_tokenize(self, s, expected):
        f = StringIO(s)
        result = stringify_tokens_from_source(tokenize.generate_tokens(f.readline), s)
        for encoding in ["utf-8", "latin-1", "utf-16"]:
                tokens = list(tokenize._generate_tokens_from_c_tokenizer())
        self.check_tokenize('0xff <= 255', """\
    """)
        self.check_tokenize('''\
  await = 2''', """\
    """)
if __name__ == "__main__":
    unittest.main()
