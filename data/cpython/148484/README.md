# incomplete fix for memory leak in array.array

**Issue:** [https://github.com/python/cpython/issues/148484](https://github.com/python/cpython/issues/148484) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-04-13T02:41:52Z`

**Labels:** `type-bug`, `extension-modules`, `easy`

## Description

# Bug report

### Bug description:

#140474

The array.array constructor leaks a range_iterator object (64 bytes) when it is given an invalid typecode along with a range object as the initializer. The constructor calls PyObject_GetIter() on the initializer before validating the typecode, allocating a range_iterator via fast_range_iter. When the typecode validation subsequently fails with ValueError: bad typecode, the iterator is not decremented and is leaked.

```python
import array

array.array('\u200e', range(5))
```

```
ValueError: bad typecode (must be b, B, u, w, h, H, i, I, l, L, q, Q, f or d)

=================================================================
==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 64 byte(s) in 1 object(s) allocated from:
    #0 malloc
    #1 _PyMem_DebugRawAlloc  Objects/obmalloc.c:3097
    #2 _PyObject_New          Objects/object.c:556
    #3 fast_range_iter        Objects/rangeobject.c:1024
    #4 PyObject_GetIter       Objects/abstract.c:2825
    #5 cfunction_vectorcall_FASTCALL  Objects/methodobject.c:449

SUMMARY: AddressSanitizer: 64 byte(s) leaked in 1 allocation(s).
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-148523
* gh-148678
* gh-148679
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
