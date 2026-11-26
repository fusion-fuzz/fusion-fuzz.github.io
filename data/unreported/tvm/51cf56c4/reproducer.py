import tvm
from tvm.script import ir as I
from tvm.script import s_tir as Ts
from tvm.script import tirx as T
from tvm.s_tir import dlight as dl


@I.ir_module
class Module:
    @Ts.function
    def main(x: T.Tensor((3, 5), "float32"), out: T.Tensor((), "float32")):
        with Ts.sblock("root"):
            red = Ts.sblock_alloc_tensor((), "float32")
            for k0, k1 in T.grid(3, 5):
                with Ts.sblock("red"):
                    v0, v1 = Ts.axis.remap("RR", [k0, k1])
                    with Ts.init():
                        red[()] = T.float32(0)
                    red[()] = red[()] + x[v0, v1]
            with Ts.sblock("epilogue"):
                out[()] = red[()] / T.float32(3)


target = tvm.target.Target({"kind": "cuda", "arch": "sm_80"})
with target:
    # Check failed: block_realize == old_block_realize_.get()
    dl.ApplyDefaultSchedule(dl.gpu.Reduction())(Module)
print("scheduled OK")
