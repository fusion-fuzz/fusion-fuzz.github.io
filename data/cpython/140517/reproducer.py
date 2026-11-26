def pack(*args):
    return args
tuple(map(pack, (1, 999999999999, 3), '\u2603', strict=True))
