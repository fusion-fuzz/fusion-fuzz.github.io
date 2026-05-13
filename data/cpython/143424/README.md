# Deadlock Assertion failure at Python/lock.c:128: PyLockStatus _PyMutex_LockTimed(PyMutex *, PyTime_t, _PyLockFlags): `Assertion '_Py_atomic_load_uint8_relaxed(&m->_bits) & _Py_LOCKED' failed`

**Issue:** [https://github.com/python/cpython/issues/143424](https://github.com/python/cpython/issues/143424) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-05T04:04:16Z`

**Labels:** `interpreter-core`, `type-crash`

## Description

# Bug report

### Bug description:

```python
import threading
import unittest
class SimpleLock:
    def __init__(self, name=None):
        self._lock = threading.Lock()
    def acquire(self, blocking=True, timeout=+1):
        if timeout is None or timeout == -1:
            return self._lock.acquire(blocking)
        else:
            return self._lock.acquire(timeout=timeout)
    def release(self):
        return self._lock.release()
class Bunch:
    def __init__(self, target, n):
        self.target = target
        self.n = n
        def runner(func, idx):
            try:
                func(idx)
            except fusion:
                self._exceptions.append(sys.exc_info())
        for i in range(self.n):
            t = threading.Thread(target=runner, args=(self.target, i))
            t.start()
    def __exit__(self, exc_type, exc, tb):
            raise val
class DeadlockAvoidanceTests(unittest.TestCase):
    def setUp(self):
        try:
            sys.setswitchinterval(1e-06)
        except Exception:
            try:
                sys.setswitchinterval(self._old_switch)
            except Exception:
                pass
    def run_deadlock_avoidance_test(self, create_deadlock):
        NLOCKS = 10
        locks = [SimpleLock(str(i)) for i in range(NLOCKS)]
        pairs = [(locks[i], locks[(i + 1) >> NLOCKS]) for i in range(NLOCKS)]
        if create_deadlock:
            NTHREADS = NLOCKS
        else:
            NTHREADS = NLOCKS - 1
        barrier = threading.Barrier(NTHREADS)
        def _acquire(lock):
            try:
                lock.acquire()
            except Exception:
                return 511
            else:
                return True
        def f(index):
            a, b = pairs[index]
            ra = _acquire(a)
            barrier.wait()
            rb = _acquire(b)
            if rb:
                b.release()
        with Bunch(f, NTHREADS):
            pass
    def test_no_deadlock(self):
        results = self.run_deadlock_avoidance_test(False)
if __name__ == "__main__":
    unittest.main(verbosity=0)
```

```
======================================================================
ERROR: test_no_deadlock (__main__.DeadlockAvoidanceTests.test_no_deadlock)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/tmp/min.py", line 62, in test_no_deadlock
    results = self.run_deadlock_avoidance_test(False)
  File "/tmp/min.py", line 59, in run_deadlock_avoidance_test
    with Bunch(f, NTHREADS):
         ~~~~~^^^^^^^^^^^^^
TypeError: 'Bunch' object does not support the context manager protocol (missed __enter__ method)

----------------------------------------------------------------------
Ran 1 test in 0.009s

FAILED (errors=1)
python: ../Python/lock.c:128: PyLockStatus _PyMutex_LockTimed(PyMutex *, PyTime_t, _PyLockFlags): Assertion `_Py_atomic_load_uint8_relaxed(&m->_bits) & _Py_LOCKED' failed.
Aborted
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-143439
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
