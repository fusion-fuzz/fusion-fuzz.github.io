# memory leak in `_PyBytes_FormatEx` error path

**Issue:** [https://github.com/python/cpython/issues/140939](https://github.com/python/cpython/issues/140939) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-03T08:55:57Z`

**Labels:** `type-bug`, `interpreter-core`, `3.13`, `3.14`

## Description

# Bug report

### Bug description:

```python
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
```

```
=================================================================
==776798==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 60 byte(s) in 1 object(s) allocated from:
    #0 0x7a4877a6d9c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x55e03c01bdf1 in _PyMem_RawMalloc ../Objects/obmalloc.c:63
    #2 0x55e03c01b1c2 in _PyMem_DebugRawAlloc ../Objects/obmalloc.c:2887
    #3 0x55e03c01b22a in _PyMem_DebugRawMalloc ../Objects/obmalloc.c:2920
    #4 0x55e03c01caa8 in _PyMem_DebugMalloc ../Objects/obmalloc.c:3085
    #5 0x55e03c045a95 in PyObject_Malloc ../Objects/obmalloc.c:1493
    #6 0x55e03bf3d755 in _PyBytes_FromSize ../Objects/bytesobject.c:126
    #7 0x55e03bf42690 in PyBytes_FromStringAndSize ../Objects/bytesobject.c:156
    #8 0x55e03bf0bf70 in _PyPegen_parse_string ../Parser/string_parser.c:334
    #9 0x55e03bdf6370 in _PyPegen_constant_from_string ../Parser/action_helpers.c:1451
    #10 0x55e03be12662 in string_rule ../Parser/parser.c:17153
    #11 0x55e03be55755 in _tmp_154_rule ../Parser/parser.c:37189
    #12 0x55e03be55e08 in _loop1_80_rule ../Parser/parser.c:32749
    #13 0x55e03be5eede in strings_rule ../Parser/parser.c:17224
    #14 0x55e03be2f755 in atom_rule ../Parser/parser.c:15165
    #15 0x55e03be31f78 in primary_raw ../Parser/parser.c:14803
    #16 0x55e03be325a4 in primary_rule ../Parser/parser.c:14601
    #17 0x55e03be32f62 in await_primary_rule ../Parser/parser.c:14555
    #18 0x55e03be3351f in power_rule ../Parser/parser.c:14431
    #19 0x55e03be350b7 in factor_rule ../Parser/parser.c:14381
    #20 0x55e03be377b7 in term_raw ../Parser/parser.c:14222
    #21 0x55e03be37de3 in term_rule ../Parser/parser.c:13965
    #22 0x55e03be38aa7 in sum_raw ../Parser/parser.c:13918
    #23 0x55e03be39106 in sum_rule ../Parser/parser.c:13797
    #24 0x55e03be3a72f in shift_expr_raw ../Parser/parser.c:13757
    #25 0x55e03be3ad5b in shift_expr_rule ../Parser/parser.c:13617
    #26 0x55e03be3b55e in bitwise_and_raw ../Parser/parser.c:13577
    #27 0x55e03be3bbbd in bitwise_and_rule ../Parser/parser.c:13495
    #28 0x55e03be3c3c0 in bitwise_xor_raw ../Parser/parser.c:13455
    #29 0x55e03be3ca1f in bitwise_xor_rule ../Parser/parser.c:13373

SUMMARY: AddressSanitizer: 60 byte(s) leaked in 1 allocation(s).
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140957
* gh-141154
* gh-141155
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
