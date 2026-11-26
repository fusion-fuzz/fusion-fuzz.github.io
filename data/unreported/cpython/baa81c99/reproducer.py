import collections, functools

d = collections.defaultdict(functools.partial(dict, a=1))
d[0]   # defaultdict calls the partial with no args (args == NULL)
