# SystemError in _generate_tokens_from_c_tokenizer

**Issue:** [https://github.com/python/cpython/issues/140576](https://github.com/python/cpython/issues/140576) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-25T10:55:54Z`

**Labels:** `type-bug`, `interpreter-core`, `3.13`, `3.14`, `3.15`

## Description

# Bug report

### Bug description:

```python
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
```

```
...
File "/usr/lib/python3.12/tokenize.py", line 577, in _generate_tokens_from_c_tokenizer
    yield TokenInfo._make(info)
          ^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/collections/__init__.py", line 449, in _make
    result = tuple_new(cls, iterable)
             ^^^^^^^^^^^^^^^^^^^^^^^^
SystemError: <built-in method __new__ of type object at 0xa42c40> returned a result with an exception set

```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140583
* gh-140757
* gh-140762
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
