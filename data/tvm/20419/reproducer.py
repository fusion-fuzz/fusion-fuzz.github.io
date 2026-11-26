import tvm
from tvm import relax
from tvm.script import ir as I, relax as R

@I.ir_module
class Module:
    @R.function
    def main(x: R.Tensor((), "float32")):
        with R.dataflow():
            @R.function
            def bar(y: R.Tensor((), "float32")) -> R.Tensor((), "float32"):
                return R.add(y, y)
            gv = bar(x)
            R.output(gv)
        return gv

relax.analysis.well_formed(Module)  # passes
relax.transform.ToMixedPrecision()(Module)
