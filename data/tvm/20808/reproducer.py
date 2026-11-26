import tvm
from tvm import relax
from tvm.script import ir as I
from tvm.script import relax as R


@I.ir_module
class Module:
    @R.function
    def main(
        x: R.Tensor((8, 8), "float32"),
        begin: R.Tensor((2,), "int64"),
        end: R.Tensor((2,), "int64"),
        strides: R.Tensor((2,), "int64"),
    ):
        with R.dataflow():
            gv = R.dynamic_strided_slice(x, begin, end, strides)
            R.output(gv)
        return gv


tvm.compile(Module, target="llvm")  # OK

mod = relax.transform.FoldConstant()(Module)
mod.show()  # leftover call_tir(Module.shape_func, ...) + match_cast bindings; no shape_func in the module
print([gv.name_hint for gv in mod.functions.keys()])  # ['main']
# relax.analysis.well_formed(mod) -> ValueError: GlobalVar Module.shape_func is not defined.
tvm.compile(mod, target="llvm")
# tvm.error.InternalError: Check failed: (it != functions.end()) is false: There is no definition of Module.shape_func
