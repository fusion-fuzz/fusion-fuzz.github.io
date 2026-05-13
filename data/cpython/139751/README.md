# symtable ValueError and memory leak

**Issue:** [https://github.com/python/cpython/issues/139751](https://github.com/python/cpython/issues/139751) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-08T07:24:32Z`

**Labels:** `type-bug`, `pending`

## Description

# Bug report

### Bug description:

```python
import symtable
source_code = '\ndef demoFunc(arg):\n    x = arg + 1\n    return x\n'
table = symtable.symtable(source_code, '<string>', '\x00')
for fusion in table.get_children():
        func_table = child
```

```
Traceback (most recent call last):
  File "/home/fuzz/WorkSpace/flowfusion-cpython/leak_pocs/1937/./min.py", line 3, in <module>
    table = symtable.symtable(source_code, '<string>', '\x00')
  File "/home/fuzz/WorkSpace/flowfusion-cpython/cpython/Lib/symtable.py", line 26, in symtable
    top = _symtable.symtable(code, filename, compile_type)
ValueError: embedded null character

=================================================================
==1760594==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 49 byte(s) in 1 object(s) allocated from:
    #0 0x70d8592459c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x58cdc7c601ae in PyUnicode_New ../Objects/unicodeobject.c:1406
    #2 0x58cdc7ccfa83 in PyUnicode_New ../Objects/unicodeobject.c:1355
    #3 0x58cdc7ccfa83 in unicode_decode_utf8 ../Objects/unicodeobject.c:5412
    #4 0x58cdc79f46c6 in _PyPegen_decode_string ../Parser/string_parser.c:245
    #5 0x58cdc79f46c6 in _PyPegen_decode_string ../Parser/string_parser.c:242
    #6 0x58cdc79f4f9c in _PyPegen_parse_string ../Parser/string_parser.c:338
    #7 0x58cdc7955e82 in _PyPegen_constant_from_string ../Parser/action_helpers.c:1451
    #8 0x58cdc79a9ab5 in string_rule ../Parser/parser.c:17129
    #9 0x58cdc79a9ab5 in _tmp_153_rule ../Parser/parser.c:37022
    #10 0x58cdc79aa584 in _loop1_80_rule ../Parser/parser.c:32623
    #11 0x58cdc79afe2f in strings_rule ../Parser/parser.c:17200
    #12 0x58cdc7966a9b in atom_rule ../Parser/parser.c:15141
    #13 0x58cdc796bf2f in primary_raw ../Parser/parser.c:14779
    #14 0x58cdc796bf2f in primary_rule ../Parser/parser.c:14577
    #15 0x58cdc796ce89 in await_primary_rule ../Parser/parser.c:14531
    #16 0x58cdc796dde7 in power_rule ../Parser/parser.c:14407
    #17 0x58cdc796dde7 in factor_rule ../Parser/parser.c:14357
    #18 0x58cdc796f55f in term_raw ../Parser/parser.c:14198
    #19 0x58cdc796f55f in term_rule ../Parser/parser.c:13941
    #20 0x58cdc7971044 in sum_raw ../Parser/parser.c:13894
    #21 0x58cdc7971044 in sum_rule ../Parser/parser.c:13773
    #22 0x58cdc7972307 in shift_expr_raw ../Parser/parser.c:13733
    #23 0x58cdc7972307 in shift_expr_rule ../Parser/parser.c:13593
    #24 0x58cdc7973964 in bitwise_and_raw ../Parser/parser.c:13553
    #25 0x58cdc7973964 in bitwise_and_rule ../Parser/parser.c:13471
    #26 0x58cdc7974594 in bitwise_xor_raw ../Parser/parser.c:13431
    #27 0x58cdc7974594 in bitwise_xor_rule ../Parser/parser.c:13349
    #28 0x58cdc79751c4 in bitwise_or_raw ../Parser/parser.c:13309
    #29 0x58cdc79751c4 in bitwise_or_rule ../Parser/parser.c:13227
    #30 0x58cdc7975e90 in comparison_rule ../Parser/parser.c:12467
    #31 0x58cdc7975e90 in inversion_rule ../Parser/parser.c:12418
    #32 0x58cdc7979125 in conjunction_rule ../Parser/parser.c:12295
    #33 0x58cdc797a125 in disjunction_rule ../Parser/parser.c:12207
    #34 0x58cdc798d084 in expression_rule ../Parser/parser.c:11495
    #35 0x58cdc7990b6c in _tmp_87_rule ../Parser/parser.c:33082
    #36 0x58cdc7991f58 in _tmp_164_rule ../Parser/parser.c:37700
    #37 0x58cdc7991f58 in _loop0_88_rule ../Parser/parser.c:33134
    #38 0x58cdc7991f58 in _gather_89_rule ../Parser/parser.c:33202
    #39 0x58cdc799638c in args_rule ../Parser/parser.c:18376
    #40 0x58cdc797cf50 in arguments_rule ../Parser/parser.c:18297
    #41 0x58cdc7980724 in t_primary_raw ../Parser/parser.c:19887
    #42 0x58cdc7980724 in t_primary_rule ../Parser/parser.c:19714
    #43 0x58cdc799e38d in target_with_star_atom_rule ../Parser/parser.c:19214
    #44 0x58cdc79a1229 in star_target_rule ../Parser/parser.c:19157

SUMMARY: AddressSanitizer: 49 byte(s) leaked in 1 allocation(s).
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
