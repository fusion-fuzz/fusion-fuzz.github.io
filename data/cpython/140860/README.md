# indirect memory leak with audit hook

**Issue:** [https://github.com/python/cpython/issues/140860](https://github.com/python/cpython/issues/140860) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2025-10-31T16:56:05Z`

**Labels:** `type-bug`, `interpreter-core`, `3.14`, `3.15`

## Description

# Bug report

### Bug description:

```python
import sys
import time

time_tuple = time.localtime()

events = []
def hook(event, *args):
    events.append((event, args))
sys.addaudithook(hook)

roundtrip('%x', slice(0, 3), tt2)
```

```
NameError: name 'roundtrip' is not defined

=================================================================
==1926743==ERROR: LeakSanitizer: detected memory leaks

Indirect leak of 1432 byte(s) in 1 object(s) allocated from:
    #0 0x772dcd8179c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x572d4af0c8fe in _PyObject_MallocWithType ../Include/internal/pycore_object_alloc.h:46
    #2 0x572d4af0c8fe in _PyType_AllocNoTrack ../Objects/typeobject.c:2505
    #3 0x572d4af0cb64 in PyType_GenericAlloc ../Objects/typeobject.c:2536
    #4 0x572d4af4245d in PyType_FromMetaclass ../Objects/typeobject.c:5475
    #5 0x572d4aeea458 in _PyStructSequence_NewType ../Objects/structseq.c:774
    #6 0x572d4b4725b9 in time_exec ../Modules/timemodule.c:2102
    #7 0x572d4ae7b4ad in PyModule_ExecDef ../Objects/moduleobject.c:555
    #8 0x572d4b1a202a in _imp_exec_builtin (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x78102a) (BuildId: dac7ae6d6ed5f3a14d0cfdafb4721e2e3be18e94)
    #9 0x572d4ad6978e in _PyVectorcall_Call ../Objects/call.c:273
    #10 0x572d4ad6978e in _PyObject_Call ../Objects/call.c:348
    #11 0x572d4ad6978e in PyObject_Call ../Objects/call.c:373
    #12 0x572d4ac08e9c in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #13 0x572d4b0e5785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #14 0x572d4b0e5785 in _PyEval_Vector ../Python/ceval.c:2005
    #15 0x572d4ad637f2 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #16 0x572d4ad637f2 in object_vacall ../Objects/call.c:819
    #17 0x572d4ad66e41 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #18 0x572d4b1ad9c3 in import_find_and_load ../Python/import.c:3688
    #19 0x572d4b1ad9c3 in PyImport_ImportModuleLevelObject ../Python/import.c:3770
    #20 0x572d4b0e05f5 in _PyEval_ImportName ../Python/ceval.c:3021
    #21 0x572d4ac1aa3e in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:6219
    #22 0x572d4b0e4fb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #23 0x572d4b0e4fb6 in _PyEval_Vector ../Python/ceval.c:2005
    #24 0x572d4b0e4fb6 in PyEval_EvalCode ../Python/ceval.c:888
    #25 0x572d4b0cf628 in builtin_exec_impl ../Python/bltinmodule.c:1180
    #26 0x572d4b0cf628 in builtin_exec ../Python/clinic/bltinmodule.c.h:571
    #27 0x572d4ac2adf3 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2361
    #28 0x572d4b0e5785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #29 0x572d4b0e5785 in _PyEval_Vector ../Python/ceval.c:2005
    #30 0x572d4ad637f2 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #31 0x572d4ad637f2 in object_vacall ../Objects/call.c:819
    #32 0x572d4ad66e41 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #33 0x572d4b1ad9c3 in import_find_and_load ../Python/import.c:3688
    #34 0x572d4b1ad9c3 in PyImport_ImportModuleLevelObject ../Python/import.c:3770
    #35 0x572d4b0c7a2c in builtin___import___impl ../Python/bltinmodule.c:285
    #36 0x572d4b0c7a2c in builtin___import__ ../Python/clinic/bltinmodule.c.h:110
    #37 0x572d4ad640b8 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #38 0x572d4ad640b8 in _PyObject_CallFunctionVa ../Objects/call.c:552
    #39 0x572d4ad65149 in PyObject_CallFunction ../Objects/call.c:574
    #40 0x572d4b1aeefb in PyImport_Import ../Python/import.c:3962
    #41 0x572d4b1b0d5e in PyImport_ImportModuleAttr ../Python/import.c:4173
    #42 0x572d4b1b0d5e in PyImport_ImportModuleAttrString ../Python/import.c:4194
    #43 0x572d4b1b0fd3 in init_zipimport ../Python/import.c:4104
    #44 0x572d4b1b0fd3 in _PyImport_InitExternal ../Python/import.c:4140
    #45 0x572d4b28cf1c in init_interp_main ../Python/pylifecycle.c:1216

Indirect leak of 704 byte(s) in 11 object(s) allocated from:
    #0 0x772dcd8179c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x572d4af0c8fe in _PyObject_MallocWithType ../Include/internal/pycore_object_alloc.h:46
    #2 0x572d4af0c8fe in _PyType_AllocNoTrack ../Objects/typeobject.c:2505
    #3 0x572d4af0cb64 in PyType_GenericAlloc ../Objects/typeobject.c:2536
    #4 0x572d4ad94a93 in descr_new ../Objects/descrobject.c:911
    #5 0x572d4ad94a93 in PyDescr_NewMember ../Objects/descrobject.c:995
    #6 0x572d4af303bd in type_add_members ../Objects/typeobject.c:8389
    #7 0x572d4af303bd in type_ready_fill_dict ../Objects/typeobject.c:8878
    #8 0x572d4af303bd in type_ready ../Objects/typeobject.c:9239
    #9 0x572d4af4338c in PyType_FromMetaclass ../Objects/typeobject.c:5591
    #10 0x572d4aeea458 in _PyStructSequence_NewType ../Objects/structseq.c:774
    #11 0x572d4b4725b9 in time_exec ../Modules/timemodule.c:2102
    #12 0x572d4ae7b4ad in PyModule_ExecDef ../Objects/moduleobject.c:555
    #13 0x572d4b1a202a in _imp_exec_builtin (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x78102a) (BuildId: dac7ae6d6ed5f3a14d0cfdafb4721e2e3be18e94)
    #14 0x572d4ad6978e in _PyVectorcall_Call ../Objects/call.c:273
    #15 0x572d4ad6978e in _PyObject_Call ../Objects/call.c:348
    #16 0x572d4ad6978e in PyObject_Call ../Objects/call.c:373
    #17 0x572d4ac08e9c in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #18 0x572d4b0e5785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #19 0x572d4b0e5785 in _PyEval_Vector ../Python/ceval.c:2005
    #20 0x572d4ad637f2 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #21 0x572d4ad637f2 in object_vacall ../Objects/call.c:819
    #22 0x572d4ad66e41 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #23 0x572d4b1ad9c3 in import_find_and_load ../Python/import.c:3688
    #24 0x572d4b1ad9c3 in PyImport_ImportModuleLevelObject ../Python/import.c:3770
    #25 0x572d4b0e05f5 in _PyEval_ImportName ../Python/ceval.c:3021
    #26 0x572d4ac1aa3e in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:6219
    #27 0x572d4b0e4fb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #28 0x572d4b0e4fb6 in _PyEval_Vector ../Python/ceval.c:2005
    #29 0x572d4b0e4fb6 in PyEval_EvalCode ../Python/ceval.c:888
    #30 0x572d4b0cf628 in builtin_exec_impl ../Python/bltinmodule.c:1180
    #31 0x572d4b0cf628 in builtin_exec ../Python/clinic/bltinmodule.c.h:571
    #32 0x572d4ac2adf3 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2361
    #33 0x572d4b0e5785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #34 0x572d4b0e5785 in _PyEval_Vector ../Python/ceval.c:2005
    #35 0x572d4ad637f2 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #36 0x572d4ad637f2 in object_vacall ../Objects/call.c:819
    #37 0x572d4ad66e41 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #38 0x572d4b1ad9c3 in import_find_and_load ../Python/import.c:3688
    #39 0x572d4b1ad9c3 in PyImport_ImportModuleLevelObject ../Python/import.c:3770
    #40 0x572d4b0c7a2c in builtin___import___impl ../Python/bltinmodule.c:285
    #41 0x572d4b0c7a2c in builtin___import__ ../Python/clinic/bltinmodule.c.h:110
    #42 0x572d4ad640b8 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #43 0x572d4ad640b8 in _PyObject_CallFunctionVa ../Objects/call.c:552
    #44 0x572d4ad65149 in PyObject_CallFunction ../Objects/call.c:574
    #45 0x572d4b1aeefb in PyImport_Import ../Python/import.c:3962
    #46 0x572d4b1b0d5e in PyImport_ImportModuleAttr ../Python/import.c:4173
    #47 0x572d4b1b0d5e in PyImport_ImportModuleAttrString ../Python/import.c:4194
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140861
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
