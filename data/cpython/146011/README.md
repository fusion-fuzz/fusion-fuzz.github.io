# heap-use-after-free in signaldict_repr: signaldict outlives its parent Context after explicit del

**Issue:** [https://github.com/python/cpython/issues/146011](https://github.com/python/cpython/issues/146011) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2026-03-16T07:07:09Z`

**Labels:** `type-bug`, `extension-modules`

## Description

# Bug report

### Bug description:

**Description**

A `decimal.Context` object's `flags` (and `traps`) attribute returns a `signaldict` that holds a borrowed reference to the parent `Context`. When the parent `Context` is explicitly deleted, its refcount drops to zero and `context_dealloc` frees it. However, the `signaldict` object remains alive and accessible. Any subsequent operation that calls `signaldict_repr` — such as `print()`, `str()`, or `repr()` — reads through the now-freed `Context` pointer, causing a heap-use-after-free.

**Reproducer**

```python
import decimal

ctx = decimal.Context(prec=7)
mapping = ctx.flags
del ctx
print(mapping)
```

**Expected behavior**

Either `signaldict` holds a strong reference to its parent `Context` (keeping it alive as long as the `signaldict` is alive), or accessing a `signaldict` whose parent has been freed raises a `RuntimeError` or similar safe error. Under no circumstances should `signaldict_repr` read through a freed pointer.

**Actual behavior**

```
=================================================================
==ERROR: AddressSanitizer: heap-use-after-free on address ... in signaldict_repr
READ of size 4 at ... thread T0
    #0 signaldict_repr  Include/internal/pycore_moduleobject.h
    #1 PyObject_Str     Objects/object.c:823
    #2 PyFile_WriteObject
    #3 builtin_print_impl
...
freed by thread T0 here:
    #0 free
    #1 context_dealloc  Modules/_decimal/_decimal.c:1512
    #2 _Py_Dealloc
    #3 Py_DECREF / Py_XDECREF
    #4 insertdict        Objects/dictobject.c:1998
```

**Root cause**

`signaldict` is implemented as a view over its parent `Context`'s internal C struct fields. It stores a raw pointer (or borrowed reference) to the `Context` but does not increment the `Context`'s refcount. When the user holds the last Python reference to the `Context` and deletes it, `context_dealloc` immediately frees the underlying C struct. The `signaldict` is left with a dangling pointer. Any call to `signaldict_repr` (or other `signaldict` methods that dereference the parent pointer) then constitutes a use-after-free.

The fix should ensure `signaldict` holds a strong (`Py_INCREF`) reference to its parent `Context`, releasing it only in `signaldict`'s own dealloc.

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

_No response_

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
