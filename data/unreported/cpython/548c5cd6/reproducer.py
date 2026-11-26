import functools

f = functools.partial(print)
f.__setstate__((f, (), {}, {}))   # partial whose func is itself
f()
