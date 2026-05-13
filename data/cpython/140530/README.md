# Reference leak when failing to raise from an exception cause

**Issue:** [https://github.com/python/cpython/issues/140530](https://github.com/python/cpython/issues/140530) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-24T10:55:59Z`

**Labels:** `type-bug`, `interpreter-core`, `3.13`, `3.14`, `3.15`

## Description

# Bug report

### Bug description:

```python
import unittest
class TestRaise(unittest.TestCase):
    def test_class_cause_nonexception_result(self):
        class ConstructsNone(BaseException):
            def __new__(*args, **kwargs):
                return 'A'*1000
        try:
            raise IndexError from ConstructsNone
        except Exception:
            pass
if __name__ == "__main__":
    unittest.main()
```

```
=================================================================
==1055698==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 1041 byte(s) in 1 object(s) allocated from:
    #0 0x7dd09269b9c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x599b8469b90e in PyUnicode_New ../Objects/unicodeobject.c:1358
    #2 0x599b846d8ad8 in PyUnicode_New ../Objects/unicodeobject.c:1307
    #3 0x599b846d8ad8 in unicode_repeat ../Objects/unicodeobject.c:12640
    #4 0x599b846d8ad8 in unicode_repeat ../Objects/unicodeobject.c:12621
    #5 0x599b8488cdff in const_folding_safe_multiply ../Python/flowgraph.c:1727
    #6 0x599b8488cdff in eval_const_binop ../Python/flowgraph.c:1795
    #7 0x599b8488cdff in fold_const_binop ../Python/flowgraph.c:1867
    #8 0x599b8488cdff in optimize_basic_block ../Python/flowgraph.c:2489
    #9 0x599b8488fe2d in optimize_cfg ../Python/flowgraph.c:2543
    #10 0x599b8488fe2d in _PyCfg_OptimizeCodeUnit ../Python/flowgraph.c:3655
    #11 0x599b84851cd9 in optimize_and_assemble_code_unit ../Python/compile.c:1432
    #12 0x599b84851cd9 in _PyCompile_OptimizeAndAssemble ../Python/compile.c:1474
    #13 0x599b848478ac in codegen_function_body ../Python/codegen.c:1388
    #14 0x599b848478ac in codegen_function ../Python/codegen.c:1480
    #15 0x599b84839bf3 in codegen_visit_stmt ../Python/codegen.c:3095
    #16 0x599b8483edd6 in codegen_body ../Python/codegen.c:911
    #17 0x599b84840f42 in codegen_class_body ../Python/codegen.c:1569
    #18 0x599b84840f42 in codegen_class ../Python/codegen.c:1662
    #19 0x599b84839bc9 in codegen_visit_stmt ../Python/codegen.c:3008
    #20 0x599b8484786a in codegen_function_body ../Python/codegen.c:1382
    #21 0x599b8484786a in codegen_function ../Python/codegen.c:1480
    #22 0x599b84839bf3 in codegen_visit_stmt ../Python/codegen.c:3095
    #23 0x599b8483edd6 in codegen_body ../Python/codegen.c:911
    #24 0x599b84840f42 in codegen_class_body ../Python/codegen.c:1569
    #25 0x599b84840f42 in codegen_class ../Python/codegen.c:1662
    #26 0x599b84839bc9 in codegen_visit_stmt ../Python/codegen.c:3008
    #27 0x599b8483edd6 in codegen_body ../Python/codegen.c:911
    #28 0x599b8484a094 in _PyCodegen_Module ../Python/codegen.c:874
    #29 0x599b8484bd18 in compiler_codegen ../Python/compile.c:835
    #30 0x599b84852481 in compiler_mod ../Python/compile.c:856
    #31 0x599b84852481 in _PyAST_Compile ../Python/compile.c:1487
    #32 0x599b84954e1c in run_mod ../Python/pythonrun.c:1411
    #33 0x599b84959977 in pyrun_file ../Python/pythonrun.c:1293
    #34 0x599b84959977 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #35 0x599b8495a49c in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #36 0x599b849cd7fc in pymain_run_file_obj ../Modules/main.c:410
    #37 0x599b849cd7fc in pymain_run_file ../Modules/main.c:429
    #38 0x599b849cd7fc in pymain_run_python ../Modules/main.c:691
    #39 0x599b849cf0de in Py_RunMain ../Modules/main.c:772
    #40 0x599b849cf0de in pymain_main ../Modules/main.c:802
    #41 0x599b849cf0de in Py_BytesMain ../Modules/main.c:826
    #42 0x7dd0922cd1c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #43 0x7dd0922cd28a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #44 0x599b84369524 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython-normal/build/python+0x20e524) (BuildId: b922665a0e7afc8ee52df7c3eac25a643025109e)

SUMMARY: AddressSanitizer: 1041 byte(s) leaked in 1 allocation(s).
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140908
* gh-141282
* gh-141283
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
