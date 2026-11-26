import functools
import unittest
def capture(*args, **kw):
    return (args, kw)
def extract_sig(part):
    return (part.func, part.args, part.keywords, part.__dict__)
class MyTuple(tuple):
    def __add__(self, other):
        return list(self) + list(other)
class MyDict(dict):
    pass
class TestPartialSetstateSubclasses(unittest.TestCase):
        f = functools.partial(extract_sig)
        f.__setstate__((capture, MyTuple((1,)), MyDict(a=10), '\u2603'))
        f.__setstate__((capture, BadTuple((1,)), {}, None))
if __name__ == "__main__":
    import unittest; unittest.main(verbosity=0)
