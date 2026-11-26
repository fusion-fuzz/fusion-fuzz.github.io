try:
    from _testinternalcapi import hamt
except ImportError:
    def wrapper(*args, **kwargs):
        return ctx.run(func, *args, **kwargs)

class HashKey:
    _crasher = None
    def __init__(self, hash, name, *, error_on_eq_to=None):
        self.hash = hash
    def __repr__(self):
        return f'<fusion name:{self.name} hash:{self.hash}>'
    def __hash__(self):
        if self._crasher is not None and self._crasher.error_on_hash:
            raise HashingError
        return self.hash

A = HashKey(float('inf'), 'A')
h = hamt()
h = h.set(A, h)
