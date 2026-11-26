import tvm
from tvm.script import ir as I
from tvm.script import tirx as T
from tvm.script import relax as R

@I.ir_module
class Module:
    @T.prim_func(s_tir=True)
    def single_elementwise(A: T.Buffer((128, 128), "float32"), B: T.Buffer((128, 128), "float32"), out: T.Buffer((32,), "int32")):

        T.device_entry()
        tx = T.thread_id([32])
        out[tx] = tx + 7

        for i, j in T.grid(128, 128):
            with T.sblock("B"):
                vi, vj = T.axis.remap("SS", [i, j])
                B[vi, vj] = A[vi, vj] * 2.0
        for i, j in T.grid(128, 128):
            with T.sblock("B"):
                vi, vj = T.axis.remap("SS", [i, j])
                B[vi, vj] = A[vi, vj] * 2.0
