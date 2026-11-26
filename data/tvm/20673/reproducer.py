import tvm
from tvm.script import ir as I
from tvm.script import relax as R


@I.ir_module
class Module:
    @R.function
    def main(x: R.Tensor((8,), "float32")) -> R.Tensor((), "float32"):
        with R.dataflow():
            gv = R.median(x, axis=None, keepdims=False)
            R.output(gv)
        return gv


tvm.compile(Module, target="llvm")
print("llvm: OK")
for target in ({"kind": "cuda", "arch": "sm_80"}, {"kind": "nvptx", "mcpu": "sm_80"}):
    try:
        tvm.compile(Module, target=tvm.target.Target(target))
        print(target["kind"], ": OK")
    except tvm.error.InternalError as e:
        print(target["kind"], ":", str(e).strip().splitlines()[-1][:110])
