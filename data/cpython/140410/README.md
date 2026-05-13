# SystemError: invalid maximum character passed to PyUnicode_New

**Issue:** [https://github.com/python/cpython/issues/140410](https://github.com/python/cpython/issues/140410) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-21T10:36:27Z`

**Labels:** `type-bug`

## Description

# Bug report

### Bug description:

```python
import unittest
try:
    from _testcapi import PY_SSIZE_T_MIN, PY_SSIZE_T_MAX
except ImportError:
    _testcapi = None
class CAPITest(unittest.TestCase):
    def test_new(self):
        from _testcapi import unicode_new as new
        for maxchar in (0, 97, 4096, 20320, 128512, 1114111):
            self.assertRaises(MemoryError, new, PY_SSIZE_T_MAX, maxchar)
        self.assertEqual(new(-1, 1114112), '')
if __name__ == '__main__':
    unittest.main()
```


### CPython versions tested on:

3.15

### Operating systems tested on:

Linux

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
