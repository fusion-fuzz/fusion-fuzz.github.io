# JIT executors are not properly freed

**Issue:** [https://github.com/python/cpython/issues/139540](https://github.com/python/cpython/issues/139540) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-03T08:40:38Z`

**Labels:** `type-bug`, `interpreter-core`, `3.14`, `topic-JIT`, `3.15`

## Description

# Bug report

### Bug description:

PoC:
```python
import bdb
code = 'a = 1\nb = 2\nc = a + b'
globals_dict = {}
locals_dict = {}
debugger = bdb.Bdb()
debugger.runctx(code, globals_dict, locals_dict)
for i in range(10):
    pass
with tempfile.NamedTemporaryFile() as tmpfile:
    tmpfile.seek(0)
```

Config: `--enable-experimental-jit=yes --with-address-sanitizer`

ASan:
```
Traceback (most recent call last):
  File "min.py", line 9, in <module>
    with tempfile.NamedTemporaryFile() as tmpfile:
         ^^^^^^^^
NameError: name 'tempfile' is not defined. Did you mean: 'compile'? Or did you forget to import 'tempfile'?

==3445760==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 600 byte(s) in 1 object(s) allocated from:
    #0 0x7ab0b95889c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5cc52547f6b7 in _PyObject_MallocWithType ../Include/internal/pycore_object_alloc.h:46
    #2 0x5cc52547f6b7 in gc_alloc ../Python/gc.c:2327
    #3 0x5cc52547f6b7 in _PyObject_GC_NewVar ../Python/gc.c:2369
    #4 0x5cc52555de54 in make_executor_from_uops ../Python/optimizer.c:1120
    #5 0x5cc52555de54 in uop_optimize ../Python/optimizer.c:1341
    #6 0x5cc52555de54 in _PyOptimizer_Optimize ../Python/optimizer.c:136
    #7 0x5cc524f27940 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:7656
    #8 0x5cc5253e9686 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #9 0x5cc5253e9686 in _PyEval_Vector ../Python/ceval.c:1997
    #10 0x5cc5253e9686 in PyEval_EvalCode ../Python/ceval.c:880
    #11 0x5cc5255a6b0e in run_eval_code_obj ../Python/pythonrun.c:1365
    #12 0x5cc5255a6b0e in run_mod ../Python/pythonrun.c:1459
    #13 0x5cc5255ab7b7 in pyrun_file ../Python/pythonrun.c:1293
    #14 0x5cc5255ab7b7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #15 0x5cc5255ac2dc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #16 0x5cc525628bdc in pymain_run_file_obj ../Modules/main.c:410
    #17 0x5cc525628bdc in pymain_run_file ../Modules/main.c:429
    #18 0x5cc525628bdc in pymain_run_python ../Modules/main.c:691
    #19 0x5cc52562a4be in Py_RunMain ../Modules/main.c:772
    #20 0x5cc52562a4be in pymain_main ../Modules/main.c:802
    #21 0x5cc52562a4be in Py_BytesMain ../Modules/main.c:826
    #22 0x7ab0b91ba1c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #23 0x7ab0b91ba28a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #24 0x5cc524f4cf54 in _start (cpython/build/python+0x218f54) (BuildId: 3087b1f6c97d85c049f8eaa36e3ac5b15eccf317)

SUMMARY: AddressSanitizer: 600 byte(s) leaked in 1 allocation(s).
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-139952
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
