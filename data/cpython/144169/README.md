# ast: Segfault in node constructor when passing non-string keyword arguments

**Issue:** [https://github.com/python/cpython/issues/144169](https://github.com/python/cpython/issues/144169) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-23T08:04:21Z`

**Labels:** `interpreter-core`, `type-crash`, `topic-parser`

## Description

# Crash report

### What happened?

```python
import ast

# Create a non-string object to use as a dictionary key.
# A generic object() is sufficient to trigger the type confusion.
bad_key = object()

# The crash happens when:
# 1. We instantiate an AST node (e.g., ast.Pass, which accepts no arguments).
# 2. We pass a keyword argument where the KEY is not a string.
#    (Standard Python calls block this, but 'ast' constructors bypass the check).
# 3. The 'ast' internal init finds the unknown key and tries to format a 
#    warning message using the key, assuming it is a string.
ast.Pass(**{bad_key: 'value'})
```

```
=================================================================
==2127711==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x7a672cc21fc0 at pc 0x60c1d21173eb bp 0x7ffccfbd5d90 sp 0x7ffccfbd5d88
READ of size 8 at 0x7a672cc21fc0 thread T0
    #0 0x60c1d21173ea in unicode_fromformat_write_str /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/unicodeobject.c:2521:14
    #1 0x60c1d20cda38 in unicode_fromformat_arg /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/unicodeobject.c
    #2 0x60c1d20cda38 in unicode_from_format /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/unicodeobject.c:3075:17
    #3 0x60c1d20cc3d5 in PyUnicode_FromFormatV /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/unicodeobject.c:3109:9
    #4 0x60c1d21b655a in _PyErr_WarnFormatV /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/_warnings.c:1348:15
    #5 0x60c1d21b655a in PyErr_WarnFormat /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/_warnings.c:1365:11
    #6 0x60c1d21f9dc8 in ast_type_init /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/Python-ast.c:5250:25
    #7 0x60c1d206d36f in type_call /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/typeobject.c:2472:19
    #8 0x60c1d1efdf43 in _PyObject_Call /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/call.c:361:18
    #9 0x60c1d227896e in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/generated_cases.c.h:2887:32
    #10 0x60c1d225dafd in _PyEval_EvalFrame /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_ceval.h:118:16
    #11 0x60c1d225dafd in _PyEval_Vector /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:2094:12
    #12 0x60c1d225dafd in PyEval_EvalCode /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:673:21
    #13 0x60c1d248e2bc in run_eval_code_obj /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1366:12
    #14 0x60c1d248e2bc in run_mod /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1469:19
    #15 0x60c1d2487fd7 in pyrun_file /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1294:15
    #16 0x60c1d2487fd7 in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:518:13
    #17 0x60c1d24873f5 in _PyRun_AnyFileObject /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:81:15
    #18 0x60c1d24f554d in pymain_run_file_obj /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:410:15
    #19 0x60c1d24f554d in pymain_run_file /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:429:15
    #20 0x60c1d24f3e31 in pymain_run_python /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:691:21
    #21 0x60c1d24f3e31 in Py_RunMain /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:772:5
    #22 0x60c1d24f4943 in pymain_main /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:802:12
    #23 0x60c1d24f4aa2 in Py_BytesMain /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:826:12
    #24 0x7e472dc22d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #25 0x7e472dc22e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #26 0x60c1d1d0de94 in _start (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x1fce94) (BuildId: 0e20bf7695762228d93d1548a3b79cafed8ba475)

0x7a672cc21fc0 is located 0 bytes after 16-byte region [0x7a672cc21fb0,0x7a672cc21fc0)
allocated by thread T0 here:
    #0 0x60c1d1db2984 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x2a1984) (BuildId: 0e20bf7695762228d93d1548a3b79cafed8ba475)
    #1 0x60c1d20628c4 in _PyObject_MallocWithType /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_object_alloc.h:46:17
    #2 0x60c1d20628c4 in _PyType_AllocNoTrack /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/typeobject.c:2516:19
    #3 0x60c1d206257d in PyType_GenericAlloc /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/typeobject.c:2547:21
    #4 0x60c1d2072d77 in object_new /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/typeobject.c:7227:21
    #5 0x60c1d206d0e1 in type_call /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/typeobject.c:2460:11
    #6 0x60c1d1efc71a in _PyObject_MakeTpCall /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/call.c:242:18
    #7 0x60c1d225f551 in _Py_VectorCallInstrumentation_StackRefSteal /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:762:11
    #8 0x60c1d2280357 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/generated_cases.c.h:1788:35
    #9 0x60c1d225dafd in _PyEval_EvalFrame /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_ceval.h:118:16
    #10 0x60c1d225dafd in _PyEval_Vector /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:2094:12
    #11 0x60c1d225dafd in PyEval_EvalCode /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:673:21
    #12 0x60c1d248e2bc in run_eval_code_obj /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1366:12
    #13 0x60c1d248e2bc in run_mod /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1469:19
    #14 0x60c1d2487fd7 in pyrun_file /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:1294:15
    #15 0x60c1d2487fd7 in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:518:13
    #16 0x60c1d24873f5 in _PyRun_AnyFileObject /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/pythonrun.c:81:15
    #17 0x60c1d24f554d in pymain_run_file_obj /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:410:15
    #18 0x60c1d24f554d in pymain_run_file /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:429:15
    #19 0x60c1d24f3e31 in pymain_run_python /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:691:21
    #20 0x60c1d24f3e31 in Py_RunMain /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:772:5
    #21 0x60c1d24f4943 in pymain_main /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:802:12
    #22 0x60c1d24f4aa2 in Py_BytesMain /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/main.c:826:12
    #23 0x7e472dc22d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16

SUMMARY: AddressSanitizer: heap-buffer-overflow /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/unicodeobject.c:2521:14 in unicode_fromformat_write_str
Shadow bytes around the buggy address:
  0x7a672cc21d00: fa fa 04 fa fa fa 07 fa fa fa 07 fa fa fa 06 fa
  0x7a672cc21d80: fa fa 07 fa fa fa 07 fa fa fa 00 01 fa fa 07 fa
  0x7a672cc21e00: fa fa 04 fa fa fa 05 fa fa fa 05 fa fa fa 03 fa
  0x7a672cc21e80: fa fa 06 fa fa fa 03 fa fa fa 04 fa fa fa 03 fa
  0x7a672cc21f00: fa fa 04 fa fa fa 03 fa fa fa 06 fa fa fa 03 fa
=>0x7a672cc21f80: fa fa 06 fa fa fa 00 00[fa]fa fa fa fa fa fa fa
  0x7a672cc22000: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x7a672cc22080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x7a672cc22100: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x7a672cc22180: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x7a672cc22200: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-144177
* gh-144178
* gh-144227
* gh-144260
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
