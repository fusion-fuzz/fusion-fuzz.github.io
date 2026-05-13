# Memory leak when `object.__hash__` returns a non-`int` value

**Issue:** [https://github.com/python/cpython/issues/140406](https://github.com/python/cpython/issues/140406) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-21T09:37:55Z`

**Labels:** `type-bug`, `interpreter-core`, `3.13`, `3.14`, `3.15`

## Description

# Bug report

### Bug description:

```python
try:
    from _testinternalcapi import hamt
except ImportError:
    def wrapper(*args, **kwargs):
        return ctx.run(func, *args, **kwargs)

class HashKey:
    _crasher = None
    def __init__(self, hash, name, *, error_on_eq_to=None):
        self.hash = hash
    def __repr__(self):
        return f'<fusion name:{self.name} hash:{self.hash}>'
    def __hash__(self):
        if self._crasher is not None and self._crasher.error_on_hash:
            raise HashingError
        return self.hash

A = HashKey(float('inf'), 'A')
h = hamt()
h = h.set(A, h)
```

```
TypeError: __hash__ method should return an integer

=================================================================
==332029==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 24 byte(s) in 1 object(s) allocated from:
    #0 0x7b04299839c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5665f9652ed9 in PyFloat_FromDouble ../Objects/floatobject.c:128
    #2 0x5665f9bdb081 in fill_time ../Modules/posixmodule.c:2681
    #3 0x5665f9bdb79e in _pystat_fromstructstat ../Modules/posixmodule.c:2796
    #4 0x5665f9bdd5bc in posix_do_stat ../Modules/posixmodule.c:2918
    #5 0x5665f9be7ccc in os_stat_impl ../Modules/posixmodule.c:3285
    #6 0x5665f9be7ccc in os_stat ../Modules/clinic/posixmodule.c.h:105
    #7 0x5665f94b1e79 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2361
    #8 0x5665f99698e5 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #9 0x5665f99698e5 in _PyEval_Vector ../Python/ceval.c:2001
    #10 0x5665f95e9da2 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #11 0x5665f95e9da2 in object_vacall ../Objects/call.c:819
    #12 0x5665f95ed3f1 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #13 0x5665f9a318c3 in import_find_and_load ../Python/import.c:3701
    #14 0x5665f9a318c3 in PyImport_ImportModuleLevelObject ../Python/import.c:3783
    #15 0x5665f994c0fc in builtin___import___impl ../Python/bltinmodule.c:285
    #16 0x5665f994c0fc in builtin___import__ ../Python/clinic/bltinmodule.c.h:110
    #17 0x5665f95eac27 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #18 0x5665f95eac27 in PyObject_Vectorcall ../Objects/call.c:327
    #19 0x5665f948ef80 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:3188
    #20 0x5665f99698e5 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #21 0x5665f99698e5 in _PyEval_Vector ../Python/ceval.c:2001
    #22 0x5665f95eaf6d in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #23 0x5665f95eaf6d in PyObject_CallOneArg ../Objects/call.c:395
    #24 0x5665f996f6bd in _PyCodec_Lookup ../Python/codecs.c:184
    #25 0x5665f9971185 in _PyCodec_LookupTextEncoding ../Python/codecs.c:519
    #26 0x5665f9971185 in codec_getitem_checked ../Python/codecs.c:568
    #27 0x5665f9971185 in _PyCodec_TextDecoder ../Python/codecs.c:584
    #28 0x5665f9971185 in _PyCodec_DecodeText ../Python/codecs.c:606
    #29 0x5665f9875f13 in PyUnicode_Decode ../Objects/unicodeobject.c:3662
    #30 0x5665f9876942 in PyUnicode_FromEncodedObject ../Objects/unicodeobject.c:3511
    #31 0x5665f95c83e9 in bytes_decode_impl ../Objects/bytesobject.c:2488
    #32 0x5665f95c83e9 in bytes_decode ../Objects/clinic/bytesobject.c.h:1130
    #33 0x5665f95eac27 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #34 0x5665f95eac27 in PyObject_Vectorcall ../Objects/call.c:327
    #35 0x5665f948cad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #36 0x5665f9969116 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #37 0x5665f9969116 in _PyEval_Vector ../Python/ceval.c:2001
    #38 0x5665f9969116 in PyEval_EvalCode ../Python/ceval.c:884
    #39 0x5665f99534e8 in builtin_exec_impl ../Python/bltinmodule.c:1180
    #40 0x5665f99534e8 in builtin_exec ../Python/clinic/bltinmodule.c.h:571
    #41 0x5665f94b1e79 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2361
    #42 0x5665f99698e5 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #43 0x5665f99698e5 in _PyEval_Vector ../Python/ceval.c:2001
    #44 0x5665f95e9da2 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #45 0x5665f95e9da2 in object_vacall ../Objects/call.c:819
    #46 0x5665f95ed3f1 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #47 0x5665f9a318c3 in import_find_and_load ../Python/import.c:3701
    #48 0x5665f9a318c3 in PyImport_ImportModuleLevelObject ../Python/import.c:3783

SUMMARY: AddressSanitizer: 24 byte(s) leaked in 1 allocation(s).
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140411
* gh-140417
* gh-140441
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
