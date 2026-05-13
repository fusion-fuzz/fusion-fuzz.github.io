# Assertion failure in Objects/unicodeobject.c `_PyUnicode_DecodeUnicodeEscapeInternal2: Assertion 'end - s <= writer.size - writer.pos' failed`

**Issue:** [https://github.com/python/cpython/issues/141336](https://github.com/python/cpython/issues/141336) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2025-11-10T07:49:22Z`

**Labels:** `interpreter-core`, `topic-unicode`, `type-crash`

## Description

# Bug report

### Bug description:

```python
import codecs

decode = codecs.unicode_escape_decode
data = {b'\\x0': (b'\xe2\x98\x83', 0)}

def mutating(exc):
    key = exc.object[:exc.end]
    r = data.get(key)
    if r is not None:
        return ('Є', r[1])

codecs.register_error('test.mutating2', mutating)

input_obj = b'\\x0n\\z'
result, length = decode(input_obj, 'test.mutating2')
```

```
python: ../Objects/unicodeobject.c:6687: _PyUnicode_DecodeUnicodeEscapeInternal2: Assertion `end - s <= writer.size - writer.pos' failed.
Aborted (core dumped)
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-141344
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
