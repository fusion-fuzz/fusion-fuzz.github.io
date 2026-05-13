# Assertion failure dis null byte

**Issue:** [https://github.com/python/cpython/issues/142736](https://github.com/python/cpython/issues/142736) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-15T05:03:06Z`

**Labels:** `type-crash`

## Description

# Crash report

### What happened?

```python
import dis
code = compile("pass", "", "exec")
test = code.replace(co_linetable=b'\x00')
dis.dis(test)
```

```
python: ../Objects/codeobject.c:1179: void advance(PyCodeAddressRange *): Assertion `bounds->opaque.lo_next <= bounds->opaque.limit && (bounds->ar_line == -1 || bounds->ar_line == bounds->opaque.computed_line) && (bounds->opaque.lo_next == bounds->opaque.limit || (*bounds->opaque.lo_next) & 128)' failed.
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
