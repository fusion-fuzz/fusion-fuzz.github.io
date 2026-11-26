import tvm
from tvm.script import ir as I
from tvm.script import relax as R


@I.ir_module
class Module:
    @R.function
    def main(boxes: R.Tensor((1, 5, 4), "float32"), scores: R.Tensor((1, 2, 5), "float32")):
        with R.dataflow():
            gv = R.vision.all_class_non_max_suppression(
                boxes, scores, R.const(3, "int64"), R.const(0.5, "float32"),
                R.const(0.1, "float32"), "onnx")
            R.output(gv)
        return gv


tvm.compile(Module, target="llvm")
print("llvm: OK")
target = tvm.target.Target({"kind": "cuda", "arch": "sm_80"})
# Check failed: (it != flat_map_.end()) is false: Tensor T_gather is used before its definition
tvm.compile(Module, target=target)
print("cuda: OK")
