import pickle

for proto in range(pickle.HIGHEST_PROTOCOL + 1):
    it = iter(range(0x80000000 ** 32 + -(2**15)))
    it.__setstate__(2 ** -(2**15) + 1)
    d = pickle.dumps(it, proto)
