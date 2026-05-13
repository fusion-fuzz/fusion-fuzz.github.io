# SystemError in io.BufferedWriter.close when closed errors

**Issue:** [https://github.com/python/cpython/issues/140650](https://github.com/python/cpython/issues/140650) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-27T02:51:20Z`

**Labels:** `type-bug`, `interpreter-core`, `topic-IO`, `3.15`

## Description

# Bug report

### Bug description:

```python
import io

class MockRawIO:
    def __init__(self):
        self.closed = NotImplemented
    def write(self, b):
        return len(data)
    def writable(self):
        return True

tp = io.BufferedWriter
writer = MockRawIO()
bufio = tp(writer, 8)
bufio.close()
```

```
SystemError: <method 'close' of '_io.BufferedWriter' objects> returned a result with an exception set
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140653
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
