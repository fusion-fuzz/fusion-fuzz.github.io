# SystemError PyState_AddModule called on module with slots in testmultiphase

**Issue:** [https://github.com/python/cpython/issues/140751](https://github.com/python/cpython/issues/140751) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-29T11:14:20Z`

**Labels:** `type-bug`, `tests`, `topic-C-API`

## Description

# Bug report

### Bug description:

```python
import _testmultiphase
_testmultiphase.call_state_registration_func(1)
```
```
    _testmultiphase.call_state_registration_func(1)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^
SystemError: PyState_AddModule called on module with slots
```

Not sure if this is interesting, as it is a test lib.


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
