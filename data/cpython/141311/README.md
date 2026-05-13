# Assertion failure in Modules/_io/bytesio.c `_io_BytesIO_readinto_impl: Assertion 'self->pos + len < PY_SSIZE_T_MAX' failed.`

**Issue:** [https://github.com/python/cpython/issues/141311](https://github.com/python/cpython/issues/141311) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-09T18:08:44Z`

**Labels:** `extension-modules`, `topic-IO`, `type-crash`, `3.13`

## Description

# Bug report

### Bug description:

```python
import io

input_lines = ['windows\r\n']
joined = ''.join(input_lines)

encoding = 'utf-8'
newline = None
bufsize = 1

raw = io.BytesIO(joined.encode(encoding))
buf = io.BufferedReader(raw, buffer_size=bufsize)
textio = io.TextIOWrapper(buf, encoding=encoding, newline=newline)

textio.seek(2**63 - 1)
_ = textio.read(2)
```

```
python: ../Modules/_io/bytesio.c:616: _io_BytesIO_readinto_impl: Assertion `self->pos + len < PY_SSIZE_T_MAX' failed.
Aborted (core dumped)
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-141333
* gh-141457
* gh-141478
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
