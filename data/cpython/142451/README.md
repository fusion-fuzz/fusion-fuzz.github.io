# HMAC.copy() does not correctly copy its attributes

**Issue:** [https://github.com/python/cpython/issues/142451](https://github.com/python/cpython/issues/142451) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-09T11:00:42Z`

**Labels:** `stdlib`, `extension-modules`, `type-crash`

## Description

# Crash report

### What happened?

```python
import hmac
import hashlib

h = hmac.HMAC(b'key', digestmod=hashlib.sha256)
h_copy = h.copy()
print(h_copy.name)
```

```
python: ../Modules/_hashopenssl.c:610: const char *get_asn1_utf8name_by_nid(int): Assertion `ERR_peek_last_error() != 0' failed
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-142510
* gh-142698
* gh-142701
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
