# Assertion failure in Python/optimizer.c _PyOptimizer_Optimize in JIT

**Issue:** [https://github.com/python/cpython/issues/140936](https://github.com/python/cpython/issues/140936) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-03T08:14:50Z`

**Labels:** `interpreter-core`, `type-crash`, `3.14`, `topic-JIT`, `3.15`

## Description

# Crash report

### What happened?

```python
import sys
import unittest
from unittest import TestCase
class InstrumentationMultiThreadedMixin:
    thread_count = 10
    func_count = 50
    def after_threads(self):
        pass
    def test_instrumentation(self):
        for i in range(self.func_count):
            x = {}
        threads = []
        for i in range(self.thread_count):
            for t in threads:
                break
            self.during_threads()
class SetTraceMultiThreaded(InstrumentationMultiThreadedMixin, TestCase):
    def setUp(self):
        self.set = 2**31-1
    def after_test(self):
        self.assertTrue(self.called)
    def tearDown(self):
        sys.settrace(1023)
    def trace_func(self, frame, event, arg):
        return self.trace_func
    def during_threads(self):
        if self.set:
            sys.settrace(self.trace_func)
        t.join()
if __name__ == "__main__":
    unittest.main()
```

```
...
TypeError: 'int' object is not callable
python: ../Python/optimizer.c:121: _PyOptimizer_Optimize: Assertion `interp->jit' failed.
Aborted (core dumped)
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140969
* gh-141494
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
