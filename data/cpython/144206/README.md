# fcntl.ioctl raises SystemError: buffer overflow instead of ValueError when mutating undersized buffers

**Issue:** [https://github.com/python/cpython/issues/144206](https://github.com/python/cpython/issues/144206) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-24T07:43:40Z`

**Labels:** `type-bug`, `extension-modules`, `pending`

## Description

# Bug report

### Bug description:

```python
import fcntl
import termios

with open('/dev/tty', 'rb') as fd:
    fcntl.ioctl(fd, termios.TIOCGPGRP, b'', True)
```

```
fcntl.ioctl(fd, termios.TIOCGPGRP, b'', True)
    ~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
SystemError: buffer overflow
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-144273
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
