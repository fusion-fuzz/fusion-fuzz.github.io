# Memory leak in `map_next` in strict mode in case of error

**Issue:** [https://github.com/python/cpython/issues/140517](https://github.com/python/cpython/issues/140517) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-23T19:47:18Z`

**Labels:** `type-bug`, `interpreter-core`, `easy`, `3.14`, `3.15`

## Description

# Bug report

### Bug description:

```python
def pack(*args):
    return args
tuple(map(pack, (1, 999999999999, 3), '\u2603', strict=True))
```

```
=================================================================
==2066743==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 32 byte(s) in 1 object(s) allocated from:
    #0 0x76cd190b39c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5f18b4d0c06b in long_alloc ../Objects/longobject.c:180
    #2 0x5f18b4d0c06b in PyLong_FromLong ../Objects/longobject.c:403
    #3 0x5f18b4b3c73d in parsenumber_raw ../Parser/pegen.c:640
    #4 0x5f18b4b401f9 in parsenumber ../Parser/pegen.c:668
    #5 0x5f18b4b401f9 in _PyPegen_number_token ../Parser/pegen.c:707
    #6 0x5f18b4b5d749 in atom_rule ../Parser/parser.c:15160
    #7 0x5f18b4b62f2f in primary_raw ../Parser/parser.c:14779
    #8 0x5f18b4b62f2f in primary_rule ../Parser/parser.c:14577
    #9 0x5f18b4b63e89 in await_primary_rule ../Parser/parser.c:14531
    #10 0x5f18b4b64de7 in power_rule ../Parser/parser.c:14407
    #11 0x5f18b4b64de7 in factor_rule ../Parser/parser.c:14357
    #12 0x5f18b4b6655f in term_raw ../Parser/parser.c:14198
    #13 0x5f18b4b6655f in term_rule ../Parser/parser.c:13941
    #14 0x5f18b4b68044 in sum_raw ../Parser/parser.c:13894
    #15 0x5f18b4b68044 in sum_rule ../Parser/parser.c:13773
    #16 0x5f18b4b69307 in shift_expr_raw ../Parser/parser.c:13733
    #17 0x5f18b4b69307 in shift_expr_rule ../Parser/parser.c:13593
    #18 0x5f18b4b6a964 in bitwise_and_raw ../Parser/parser.c:13553
    #19 0x5f18b4b6a964 in bitwise_and_rule ../Parser/parser.c:13471
    #20 0x5f18b4b6b594 in bitwise_xor_raw ../Parser/parser.c:13431
    #21 0x5f18b4b6b594 in bitwise_xor_rule ../Parser/parser.c:13349
    #22 0x5f18b4b6c1c4 in bitwise_or_raw ../Parser/parser.c:13309
    #23 0x5f18b4b6c1c4 in bitwise_or_rule ../Parser/parser.c:13227
    #24 0x5f18b4b6ce90 in comparison_rule ../Parser/parser.c:12467
    #25 0x5f18b4b6ce90 in inversion_rule ../Parser/parser.c:12418
    #26 0x5f18b4b70125 in conjunction_rule ../Parser/parser.c:12295
    #27 0x5f18b4b71125 in disjunction_rule ../Parser/parser.c:12207
    #28 0x5f18b4b84084 in expression_rule ../Parser/parser.c:11495
    #29 0x5f18b4b8e017 in named_expression_rule ../Parser/parser.c:12153
    #30 0x5f18b4b8f83b in star_named_expression_rule ../Parser/parser.c:12003
    #31 0x5f18b4b8fc6c in _gather_58_rule ../Parser/parser.c:31182
    #32 0x5f18b4b8fc6c in star_named_expressions_rule ../Parser/parser.c:11913
    #33 0x5f18b4b90adc in _tmp_82_rule ../Parser/parser.c:32764
    #34 0x5f18b4b90adc in tuple_rule ../Parser/parser.c:17366
    #35 0x5f18b4b5dbda in _tmp_66_rule ../Parser/parser.c:31644
    #36 0x5f18b4b5dbda in atom_rule ../Parser/parser.c:15181
    #37 0x5f18b4b62f2f in primary_raw ../Parser/parser.c:14779
    #38 0x5f18b4b62f2f in primary_rule ../Parser/parser.c:14577
    #39 0x5f18b4b63e89 in await_primary_rule ../Parser/parser.c:14531
    #40 0x5f18b4b64de7 in power_rule ../Parser/parser.c:14407
    #41 0x5f18b4b64de7 in factor_rule ../Parser/parser.c:14357
    #42 0x5f18b4b6655f in term_raw ../Parser/parser.c:14198
    #43 0x5f18b4b6655f in term_rule ../Parser/parser.c:13941
    #44 0x5f18b4b68044 in sum_raw ../Parser/parser.c:13894
    #45 0x5f18b4b68044 in sum_rule ../Parser/parser.c:13773
    #46 0x5f18b4b69307 in shift_expr_raw ../Parser/parser.c:13733
    #47 0x5f18b4b69307 in shift_expr_rule ../Parser/parser.c:13593
    #48 0x5f18b4b6a964 in bitwise_and_raw ../Parser/parser.c:13553
    #49 0x5f18b4b6a964 in bitwise_and_rule ../Parser/parser.c:13471

SUMMARY: AddressSanitizer: 32 byte(s) leaked in 1 allocation(s).
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140543
* gh-140554
* gh-140560
* gh-140565
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
