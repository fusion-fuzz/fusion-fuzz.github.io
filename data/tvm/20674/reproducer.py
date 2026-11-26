import tvm
from tvm.script import ir as I
from tvm.script import tirx as T


@I.ir_module
class StoreParam:  # store into a bool kernel parameter
    @T.function
    def main(A: T.Tensor((64,), "float32"), B: T.Tensor((64,), "bool")):
        with T.launch_thread("threadIdx.x", 64) as i:
            B[i] = A[i] > T.float32(0)


@I.ir_module
class LocalBool:  # a local bool scratch buffer, stored then loaded
    @T.function
    def main(A: T.Tensor((64,), "float32"), B: T.Tensor((64,), "float32")):
        with T.launch_thread("threadIdx.x", 64) as i:
            m = T.alloc_tensor(ty_args=[T.Tensor((1,), "bool", scope="local")])
            m[0] = A[i] > T.float32(0)
            B[i] = T.Select(m[0], A[i], T.float32(0))


target = tvm.target.Target({"kind": "vulkan", "supports_int8": True, "supports_8bit_buffer": True,
                            "supports_storage_buffer_storage_class": True})
for name, mod in (("StoreParam", StoreParam), ("LocalBool", LocalBool)):
    try:
        tvm.compile(mod, target=target)
        print(name, ": OK")
    except tvm.error.InternalError as e:
        print(name, ":", str(e).strip().splitlines()[-1][:160])
