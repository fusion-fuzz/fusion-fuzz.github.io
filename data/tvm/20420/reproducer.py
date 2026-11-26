import tvm
from tvm import relax
from tvm.script import ir as I, relax as R, tirx as T

@I.ir_module
class Module:
    @R.function
    def main(A: R.Tensor((16,), "float16"), scale: R.Prim("float32"), C: R.Tensor((16,), "float16")):
        B = R.call_tir(Module.add_scaled, (A, scale, C), out_ty=R.Tensor((16,), "float16"))
        return B

    @T.prim_func
    def add_scaled(A: T.Buffer((16,), "float16"), scale: T.float32,
                   C: T.Buffer((16,), "float16"), B: T.Buffer((16,), "float16")):
        for i in range(16):
            B[i] = A[i] + T.Cast("float16", scale) * C[i]

relax.analysis.well_formed(Module)  # passes
relax.transform.SpecializePrimFuncBasedOnCallSite()(Module)
