# SEGV when changing `co_consts` of a function definition

**Issue:** [https://github.com/python/cpython/issues/140776](https://github.com/python/cpython/issues/140776) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-30T04:22:29Z`

**Labels:** `interpreter-core`, `type-crash`, `pending`

## Description

# Crash report

### What happened?

```python
import encodings.kz1048
import textwrap
obj = encodings.kz1048.IncrementalEncoder()
input_str = 'A'
result5 = obj.encode(input_str, final=True)
fusion = result5
num_names = 300
assignments = '; '.join((f'x{i} = {i}' for i in range(num_names)))
name_list = ', '.join((f'x{i}' for i in range(num_names)))
code = f'\n            {assignments}\n            [({name_list}) for {name_list} in (range(300),)]\n            dir()\n            y = [{name_list}]\n        '
newcode = textwrap.dedent('\n                        class _C:\n                            {code}\n                    ').format(
            code=textwrap.indent(code, '    ')
        )
newns = {}
co = compile(newcode, '<string>', 'exec')
co = co.replace(co_consts=tuple((fusion for _ in co.co_consts)))
exec(co, newns)
```

```
=================================================================
==2585162==ERROR: AddressSanitizer: SEGV on unknown address (pc 0x645bcafe6ac3 bp 0x7ffd863f5d70 sp 0x7ffd863f5ca0 T0)
==2585162==The signal is caused by a READ memory access.
==2585162==Hint: this fault was caused by a dereference of a high value address (see register values below).  Disassemble the provided pc to learn which register was used.
    #0 0x645bcafe6ac3 in Py_INCREF ../Include/refcount.h:281
    #1 0x645bcafe6ac3 in _Py_NewRef ../Include/refcount.h:529
    #2 0x645bcafe6ac3 in PyFunction_NewWithQualName ../Objects/funcobject.c:159
    #3 0x645bcae14f6b in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:9736
    #4 0x645bcb2e8fb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #5 0x645bcb2e8fb6 in _PyEval_Vector ../Python/ceval.c:2005
    #6 0x645bcb2e8fb6 in PyEval_EvalCode ../Python/ceval.c:888
    #7 0x645bcb2d3628 in builtin_exec_impl ../Python/bltinmodule.c:1180
    #8 0x645bcb2d3628 in builtin_exec ../Python/clinic/bltinmodule.c.h:571
    #9 0x645bcaf68677 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #10 0x645bcaf68677 in PyObject_Vectorcall ../Objects/call.c:327
    #11 0x645bcae09ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #12 0x645bcb2e8fb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #13 0x645bcb2e8fb6 in _PyEval_Vector ../Python/ceval.c:2005
    #14 0x645bcb2e8fb6 in PyEval_EvalCode ../Python/ceval.c:888
    #15 0x645bcb4a73fe in run_eval_code_obj ../Python/pythonrun.c:1365
    #16 0x645bcb4a73fe in run_mod ../Python/pythonrun.c:1459
    #17 0x645bcb4ac0a7 in pyrun_file ../Python/pythonrun.c:1293
    #18 0x645bcb4ac0a7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #19 0x645bcb4acbcc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #20 0x645bcb51f3cc in pymain_run_file_obj ../Modules/main.c:410
    #21 0x645bcb51f3cc in pymain_run_file ../Modules/main.c:429
    #22 0x645bcb51f3cc in pymain_run_python ../Modules/main.c:691
    #23 0x645bcb520cae in Py_RunMain ../Modules/main.c:772
    #24 0x645bcb520cae in pymain_main ../Modules/main.c:802
    #25 0x645bcb520cae in Py_BytesMain ../Modules/main.c:826
    #26 0x72a0f4dc81c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #27 0x72a0f4dc828a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV ../Include/refcount.h:281 in Py_INCREF
==2585162==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
