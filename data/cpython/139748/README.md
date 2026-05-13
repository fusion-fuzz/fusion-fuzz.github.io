# Argument Clinic does not handle error paths for converters creating a strong reference to a PyObject

**Issue:** [https://github.com/python/cpython/issues/139748](https://github.com/python/cpython/issues/139748) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-08T06:47:01Z`

**Labels:** `type-bug`, `interpreter-core`

## Description

# Bug report

### Bug description:

```console
$ ./python -X showrefcount -c "compile(b'a = 1\n', 'crash.py', 'exec', dont_inherit=True, optimize=99999999999)"
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    compile(b'a = 1\n', 'crash.py', 'exec', dont_inherit=True, optimize=99999999999)
    ~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
OverflowError: Python int too large to convert to C int
[1 refs, 1 blocks]
```

```console
$ ./python -X showrefcount -c 'import _symtable; _symtable.symtable("", "hello", 1)'
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    import _symtable; _symtable.symtable("", "hello", 1)
                      ~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^
TypeError: symtable() argument 3 must be str, not int
[3 refs, 1 blocks]
```

<details>
<summary>Originally tracked from the following reproducer</summary>

```python
import compileall
import tempfile
import os
tmpdir = tempfile.TemporaryDirectory()
src_dir = tmpdir.name
src_file = os.path.join(src_dir, 'test_module.py')
with open(src_file, 'w', encoding='utf-8') as f:
    f.write('a = 1\n')
ret = compileall.compile_dir(src_dir, maxlevels=1, ddir=None, force=False, rx=None, quiet=2, legacy=False, optimize=--999999999999, workers=1, invalidation_mode=None)
```

Edits: `Config: --enable-experimental-jit=yes --with-address-sanitizer`

```
=================================================================
==1571305==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 72 byte(s) in 1 object(s) allocated from:
    #0 0x796ca65c29c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5abe30ba41ae in PyUnicode_New ../Objects/unicodeobject.c:1406
    #2 0x5abe30bfbb79 in PyUnicode_New ../Objects/unicodeobject.c:1355
    #3 0x5abe30bfbb79 in PyUnicode_Append ../Objects/unicodeobject.c:11719
    #4 0x5abe3087af86 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:391
    #5 0x5abe30a04394 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #6 0x5abe30a04394 in gen_send_ex2 ../Objects/genobject.c:259
    #7 0x5abe30a04394 in gen_iternext ../Objects/genobject.c:634
    #8 0x5abe30d248a3 in _PyForIter_VirtualIteratorNext ../Python/ceval.c:3583
    #9 0x5abe3086d1a2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:5649
    #10 0x5abe30d25686 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #11 0x5abe30d25686 in _PyEval_Vector ../Python/ceval.c:1997
    #12 0x5abe30d25686 in PyEval_EvalCode ../Python/ceval.c:880
    #13 0x5abe30ee2b0e in run_eval_code_obj ../Python/pythonrun.c:1365
    #14 0x5abe30ee2b0e in run_mod ../Python/pythonrun.c:1459
    #15 0x5abe30ee77b7 in pyrun_file ../Python/pythonrun.c:1293
    #16 0x5abe30ee77b7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #17 0x5abe30ee82dc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #18 0x5abe30f64bdc in pymain_run_file_obj ../Modules/main.c:410
    #19 0x5abe30f64bdc in pymain_run_file ../Modules/main.c:429
    #20 0x5abe30f64bdc in pymain_run_python ../Modules/main.c:691
    #21 0x5abe30f664be in Py_RunMain ../Modules/main.c:772
    #22 0x5abe30f664be in pymain_main ../Modules/main.c:802
    #23 0x5abe30f664be in Py_BytesMain ../Modules/main.c:826
    #24 0x796ca61f41c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #25 0x796ca61f428a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #26 0x5abe30888f54 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x218f54) (BuildId: 3087b1f6c97d85c049f8eaa36e3ac5b15eccf317)

SUMMARY: AddressSanitizer: 72 byte(s) leaked in 1 allocation(s).
```

tempfile seems to be related to #139540, however, this has no NameError

</details>

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-139765
* gh-139789
* gh-139792
* gh-139815
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
