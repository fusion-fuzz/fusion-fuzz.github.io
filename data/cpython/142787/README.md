# assertion failure at Modules/_sqlite/blob.c:146: `PyObject *read_multiple(pysqlite_Blob *, Py_ssize_t, Py_ssize_t): Assertion 'offset < sqlite3_blob_bytes(self->blob)' failed`

**Issue:** [https://github.com/python/cpython/issues/142787](https://github.com/python/cpython/issues/142787) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-16T07:17:35Z`

**Labels:** `extension-modules`, `type-crash`, `topic-sqlite3`

## Description

# Crash report

### What happened?

```python
import sqlite3

# 1. Setup an in-memory database with a BLOB column
con = sqlite3.connect(':memory:')
con.execute('create table test(b blob)')

# 2. Insert a small amount of data.
# The unicode character '\u2603' (Snowman) is 3 bytes in UTF-8 (b'\xe2\x98\x83').
# The blob size will be 3.
con.execute('insert into test(b) values (?)', ('\u2603',))

# 3. Open the BLOB for incremental I/O
# Table: 'test', Column: 'b', Row: 1
blob = con.blobopen('test', 'b', 1)

# 4. Trigger the crash
# We request a slice starting at index 5 (which is beyond the blob size of 3)
# and ending at index -5 (which wraps around to before the start).
# This combination causes the internal 'offset' calculation in C to assert
# failing that the offset (5) is not less than the blob bytes (3).
blob[5:-5]
```

```
python: ../Modules/_sqlite/blob.c:146: PyObject *read_multiple(pysqlite_Blob *, Py_ssize_t, Py_ssize_t): Assertion `offset < sqlite3_blob_bytes(self->blob)' failed.
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-142824
* gh-145297
* gh-145298
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
