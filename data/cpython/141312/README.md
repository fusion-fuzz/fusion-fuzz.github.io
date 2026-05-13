# Assertion failure in Objects/rangeobject.c `compute_range_length: Assertion PyLong_Check(start)' failed`

**Issue:** [https://github.com/python/cpython/issues/141312](https://github.com/python/cpython/issues/141312) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-09T18:20:57Z`

**Labels:** `type-bug`, `interpreter-core`, `3.13`, `3.14`, `3.15`

## Description

# Bug report

### Bug description:

```python
import pickle

for proto in range(pickle.HIGHEST_PROTOCOL + 1):
    it = iter(range(0x80000000 ** 32 + -(2**15)))
    it.__setstate__(2 ** -(2**15) + 1)
    d = pickle.dumps(it, proto)
```

```
python: ../Objects/rangeobject.c:243: compute_range_length: Assertion `PyLong_Check(start)' failed.
Aborted (core dumped)
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-141317
* gh-141559
* gh-141568
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
