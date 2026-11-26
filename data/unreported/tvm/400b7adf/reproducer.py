import tvm
from tvm.script import ir as I
from tvm.script import tirx as T
from tvm.script import relax as R

@I.ir_module(s_tir=True)
class Module:
    @T.prim_func(s_tir=True)
    def main(A: T.Buffer((4, 0), "float32"), B: T.Buffer((4, 0), "float32")):
        for i, j in T.grid(4, 0):
            with T.sblock("copy"):
                vi, vj = T.axis.remap("SS", [i, j])
                B[vi, vj] = A[vi, vj]

        A_data_1 = T.bind(T.address_of(A[0, 0]), T.handle("float32"))

        for i, j in T.grid(4, 0):
            with T.sblock("copy"):
                vi, vj = T.axis.remap("SS", [i, j])
                B[vi, vj] = A[vi, vj]
        A_1_d = T.decl_buffer(16, "float32", data=A_data_1)
        B_data_1: T.let[T.handle("float32")] = T.address_of(B[0, 0])
        B_1_d = T.decl_buffer(16, "float32", data=B_data_1)
        for i in range(16):
            with T.sblock("scalar_mul_1"):
                B_1_d[i] = A_1_d[i] * 2.0

        A_data_2 = T.bind(T.address_of(A[1, 0]), T.handle("float32"))
        A_2_d = T.decl_buffer(16, "float32", data=A_data_2)
        B_data_2: T.let[T.handle("float32")] = T.address_of(B[1, 0])
        B_2_d = T.decl_buffer(16, "float32", data=B_data_2)
        for i in range(16):
            with T.sblock("scalar_mul_2"):
                B_2_d[i] = A_2_d[i] * 2.0
