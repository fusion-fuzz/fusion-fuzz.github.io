from itertools import chain

it = chain.from_iterable(list(it) for _ in [0])
next(it)
