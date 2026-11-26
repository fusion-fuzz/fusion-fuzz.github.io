import tvm
from tvm.script import tirx as T

@T.prim_func(s_tir=True)
def main(A: T.Buffer((16, 32), "float32"), B: T.Buffer((16,), "float32")):
    for i in range(16):
        cache = T.alloc_buffer((32,), "float32")
        T.attr(cache.data, "double_buffer_scope", 1)
        for j in range(32):
            cache[j] = A[i, j]
        B[i] = 0.0
        for j in range(32):
            B[i] = B[i] + cache[j]

tvm.compile(main, target="llvm")
