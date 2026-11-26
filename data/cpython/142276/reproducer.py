from concurrent.futures import ThreadPoolExecutor
from unittest import TestCase
NTHREADS = 6
BOTTOM = 0
TOP = 0xffffffffffffffff
class A:
    attr = 10**1000
class TestType(TestCase):
        def read(id0):
                for _ in range(BOTTOM, TOP):
                    A.attr
        def write(id0):
                    x = A.attr
                    x += 1
                    A.attr = x
        with ThreadPoolExecutor(NTHREADS) as pool:
            pool.submit(read, (1,))
            pool.submit(write, (1,))
