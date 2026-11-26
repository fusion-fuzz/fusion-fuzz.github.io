# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #
#
# An end-to-end test case mocking a kernel invocation via a wrapper function
# that converts a C void** argument into a Mojo VariadicPack. The main feature
# being tested is that `wrapped_entry_point` is expressible.
#
# The wrapper is parameterized by the kernel signature so that the expected
# types can be extracted, and acted upon differently depending on how the driver
# encodes these arguments in the void** argument.
#
# ===----------------------------------------------------------------------=== #

# RUN: %mojo %s | FileCheck %s

from std.collections import Array
from std.reflection import reflect



@fieldwise_init
struct KernelFunction[
    declared_arg_types: TypeList[Trait=AnyType, ...],
    declared_ret_type: RegisterPassable,
    //,
    func: def(* args: * declared_arg_types) thin -> declared_ret_type,
]:
    pass



# A wrapped void** argument.
struct KernelArgPack[kernel: KernelFunction[_]]:
    var pointers: Array[
        MutOpaquePointer[MutUntrackedOrigin],
        Self.kernel.declared_arg_types.length,
    ]

    def __init__(out self):
        self.pointers = type_of(self.pointers)(
            fill=MutOpaquePointer[MutUntrackedOrigin].unsafe_dangling()
        )



# Rudimentary check to see if a type is an Pointer.
def looks_like_pointer[T: AnyType]() -> Bool:
    comptime base_name = reflect[T].base_name()
    return base_name == "Pointer"



# Wrapped kernel entry point parameterized by the actual kernel to be invoked.
# Takes in a void** argument and converts it into a Mojo VariadicPack and calls
# the actual kernel function.
def wrapped_entry_point[
    kernel: KernelFunction[_]
](
    pa: Pointer[KernelArgPack[kernel], MutAnyOrigin],
) -> kernel.declared_ret_type:
    comptime to_unsafe_pointer_mapper[
        T: AnyType
    ]: ImplicitlyCopyable & Deinitable = Pointer[T, MutUntrackedOrigin]
    comptime UnsafePointerTupleType = Tuple[
        *kernel.declared_arg_types.map[to_unsafe_pointer_mapper]()
    ]
    var ptr_tuple: UnsafePointerTupleType
    __mlir_op.`lit.ownership.mark_initialized`(
        __get_mvalue_as_litref(ptr_tuple)
    )

    comptime for i in range(kernel.declared_arg_types.length):
        comptime ArgType = kernel.declared_arg_types[i]
        comptime if looks_like_pointer[ArgType]():
            ptr_tuple[i] = rebind[type_of(ptr_tuple[i])](
                pa[].pointers.unsafe_ptr().unsafe_offset(i)
            )
        else:
            ptr_tuple[i] = rebind[type_of(ptr_tuple[i])](pa[].pointers[i])

    comptime PackType = VariadicPack[
        origin=MutUntrackedOrigin,
        element_trait=AnyType,
        False,
        *kernel.declared_arg_types,
    ]
    var raw_pack = __mlir_op.`lit.ref.pack.from_pointer_pack`[
        _type=PackType._mlir_type
    ](ptr_tuple._mlir_value)
    var pack = PackType(raw_pack)
    return kernel.func(*pack)



# Mimic invoking the wrapped kernel from FFI via a void** argument.
def invoke_kernel[
    kernel: KernelFunction[_]
](
    wrapped_kernel: def(
        Pointer[KernelArgPack[kernel], MutAnyOrigin],
    ) thin -> kernel.declared_ret_type,
    *args: *kernel.declared_arg_types,
) -> kernel.declared_ret_type:
    var pa = KernelArgPack[kernel]()
    comptime for i in range(kernel.declared_arg_types.length):
        comptime ArgType = kernel.declared_arg_types[i]
        comptime if looks_like_pointer[ArgType]():
            pa.pointers[i] = rebind[MutOpaquePointer[MutUntrackedOrigin]](
                args[i]
            )
        else:
            pa.pointers[i] = rebind[MutOpaquePointer[MutUntrackedOrigin]](
                Pointer(to=args[i])
            )
    return wrapped_kernel(
        Pointer(to=pa).as_unsafe_any_origin(),
    )



comptime IntPtr = Pointer[Int, MutAnyOrigin]

comptime ScalarKernel = KernelFunction[scalar_kernel]()

comptime MixedKernel = KernelFunction[mixed_kernel]()



def scalar_kernel(x: Int) -> Int:
    return x + 1



def mixed_kernel(x: Int, p: IntPtr) -> Int:
    return x + p[]



# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #

# RUN: %parse-mojo-isolated -verify-diagnostics %s

# expected-error @+1 {{'__d' cannot be used as a function name in this context}}
def __d():
    pass



# expected-error @+1 {{'and' cannot be used as a function name in this context}}
def and():
    pass



# expected-error @+1 {{'as' cannot be used as a function name in this context}}
def as():
    pass



# expected-error @+1 {{'assert' cannot be used as a function name in this context}}
def assert():
    pass



# expected-error @+1 {{'break' cannot be used as a function name in this context}}
def break():
    pass



# expected-error @+1 {{'case_d' cannot be used as a function name in this context}}
def case_d():
    pass



# expected-error @+1 {{'class' cannot be used as a function name in this context}}
def class():
    pass



# expected-error @+1 {{'comptime' cannot be used as a function name in this context}}
def comptime():
    pass



# expected-error @+1 {{'continue' cannot be used as a function name in this context}}
def continue():
    pass



# expected-error @+1 {{'def' cannot be used as a function name in this context}}
def def():
    pass



# expected-error @+1 {{'del' cannot be used as a function name in this context}}
def del():
    pass



# expected-error @+1 {{'elif' cannot be used as a function name in this context}}
def elif():
    pass



# expected-error @+1 {{'else' cannot be used as a function name in this context}}
def else():
    pass



# expected-error @+1 {{'except' cannot be used as a function name in this context}}
def except():
    pass



# expected-error @+1 {{'False' cannot be used as a function name in this context}}
def False():
    pass



# expected-error @+1 {{'finally' cannot be used as a function name in this context}}
def finally():
    pass



# expected-error @+1 {{'for' cannot be used as a function name in this context}}
def for():
    pass



# expected-error @+1 {{'from' cannot be used as a function name in this context}}
def from():
    pass



# expected-error @+1 {{'global' cannot be used as a function name in this context}}
def global():
    pass



# expected-error @+1 {{'if' cannot be used as a function name in this context}}
def if():
    pass



# expected-error @+1 {{'import' cannot be used as a function name in this context}}
def import():
    pass



# expected-error @+1 {{'in' cannot be used as a function name in this context}}
def in():
    pass



# expected-error @+1 {{'is' cannot be used as a function name in this context}}
def is():
    pass



# expected-error @+1 {{'lambda' cannot be used as a function name in this context}}
def lambda():
    pass



# expected-error @+1 {{'match_d' cannot be used as a function name in this context}}
def match_d():
    pass



# expected-error @+1 {{'None' cannot be used as a function name in this context}}
def None():
    pass



# expected-error @+1 {{'nonlocal' cannot be used as a function name in this context}}
def nonlocal():
    pass



# expected-error @+1 {{'not' cannot be used as a function name in this context}}
def not():
    pass



# expected-error @+1 {{'or' cannot be used as a function name in this context}}
def or():
    pass



# expected-error @+1 {{'pass' cannot be used as a function name in this context}}
def pass():
    pass



# expected-error @+1 {{'raise' cannot be used as a function name in this context}}
def raise():
    pass



# expected-error @+1 {{'ref' cannot be used as a function name in this context}}
def ref():
    pass



# expected-error @+1 {{'return' cannot be used as a function name in this context}}
def return():
    pass



# expected-error @+1 {{'Self' cannot be used as a function name in this context}}
def Self():
    pass



# expected-error @+1 {{'struct' cannot be used as a function name in this context}}
def struct():
    pass



# expected-error @+1 {{'trait' cannot be used as a function name in this context}}
def trait():
    pass



# expected-error @+1 {{'__async_d' cannot be used as a function name in this context}}
def __async_d():
    pass



# expected-error @+1 {{'__await_d' cannot be used as a function name in this context}}
def __await_d():
    pass



# expected-error @+1 {{'async' cannot be used as a function name in this context}}
def async():
    pass



# expected-error @+1 {{'await' cannot be used as a function name in this context}}
def await():
    pass



# expected-error @+1 {{'__extension_d' cannot be used as a function name in this context}}
def __extension_d():
    pass



# expected-error @+1 {{'True' cannot be used as a function name in this context}}
def True():
    pass



# expected-error @+1 {{'try' cannot be used as a function name in this context}}
def try():
    pass



# expected-error @+1 {{'var' cannot be used as a function name in this context}}
def var():
    pass



# expected-error @+1 {{'while' cannot be used as a function name in this context}}
def while():
    pass



# expected-error @+1 {{'with' cannot be used as a function name in this context}}
def with():
    pass



# expected-error @+1 {{'yield' cannot be used as a function name in this context}}
def yield():
    pass



# expected-error @+1 {{'__mlir_region_d' cannot be used as a function name in this context}}
def __mlir_region_d():
    pass



# expected-error @+1 {{'__get_address_as_uninit_lvalue_d' cannot be used as a function name in this context}}
def __get_address_as_uninit_lvalue_d():
    pass



# expected-error @+1 {{'__get_mvalue_as_litref_d' cannot be used as a function name in this context}}
def __get_mvalue_as_litref_d():
    pass



# expected-error @+1 {{'__get_litref_as_mvalue_d' cannot be used as a function name in this context}}
def __get_litref_as_mvalue_d():
    pass



# expected-error @+1 {{'__get_address_as_owned_value_d' cannot be used as a function name in this context}}
def __get_address_as_owned_value_d():
    pass



# expected-error @+1 {{'origin_of_d' cannot be used as a function name in this context}}
def origin_of_d():
    pass



# expected-error @+1 {{'type_of_d' cannot be used as a function name in this context}}
def type_of_d():
    pass



# expected-error @+1 {{'conforms_to_d' cannot be used as a function name in this context}}
def conforms_to_d():
    pass



# expected-error @+1 {{'__functions_in_module_d' cannot be used as a function name in this context}}
def __functions_in_module_d():
    pass



# expected-error @+1 {{'__get_current_function_name_d' cannot be used as a function name in this context}}
def __get_current_function_name_d():
    pass



# expected-error @+1 {{'__struct_field_ref_d' cannot be used as a function name in this context}}
def __struct_field_ref_d():
    pass



# expected-error @+1 {{'__is_run_in_comptime_interpreter_d' cannot be used as a function name in this context}}
def __is_run_in_comptime_interpreter_d():
    pass



# expected-error @+1 {{'__match_d' cannot be used as a function name in this context}}
def __match_d():
    pass




# Nested free functions are rejected too.
def outer_d():
    # expected-error @+1 {{'match_d' cannot be used as a function name in this context}}
    def match_d():
        pass




# Keyword method names are allowed (reached via `.name()`).
struct Bar_d:
    def __init__(out self):
        pass

    def match_d(self):
        pass

    def class(self):
        pass

    def yield(self):
        pass


@fieldwise_init
struct KernelFunction_d_d[
    declared_arg_types: TypeList[Trait=AnyType, ...],
    declared_ret_type: RegisterPassable,
    //,
    func: def(* args: * declared_arg_types) thin -> declared_ret_type,
]:
    pass




# A wrapped void** argument.
struct KernelArgPack_d_d[kernel: KernelFunction_d_d[__d]]:
    var pointers: Array[
        MutOpaquePointer[MutUntrackedOrigin],
        Self.kernel.declared_arg_types.length,
    ]

    def __init__(out self):
        self.pointers = type_of_d(self.pointers)(
            fill=MutOpaquePointer[MutUntrackedOrigin].unsafe_dangling()
        )




# Rudimentary check to see if a type is an Pointer.
def looks_like_pointer_d_d[T: AnyType]() -> Bool:
    comptime base_name = reflect[T].base_name()
    return base_name == "Pointer"




# Wrapped kernel entry point parameterized by the actual kernel to be invoked.
# Takes in a void** argument and converts it into a Mojo VariadicPack and calls
# the actual kernel function.
def wrapped_entry_point_d_d[
    kernel: KernelFunction_d_d[__d]
](
    pa: Pointer[KernelArgPack_d_d[kernel], MutAnyOrigin],
) -> kernel.declared_ret_type:
    comptime to_unsafe_pointer_mapper[
        T: AnyType
    ]: ImplicitlyCopyable & Deinitable = Pointer[T, MutUntrackedOrigin]
    comptime UnsafePointerTupleType = Tuple[
        *kernel.declared_arg_types.map[to_unsafe_pointer_mapper]()
    ]
    var ptr_tuple: UnsafePointerTupleType
    __mlir_op.`lit.ownership.mark_initialized`(
        __get_mvalue_as_litref_d(ptr_tuple)
    )

    comptime for i in range(kernel.declared_arg_types.length):
        comptime ArgType = kernel.declared_arg_types[i]
        comptime if looks_like_pointer_d_d[ArgType]():
            ptr_tuple[i] = rebind[type_of_d(ptr_tuple[i])](
                pa[].pointers.unsafe_ptr().unsafe_offset(i)
            )
        else:
            ptr_tuple[i] = rebind[type_of_d(ptr_tuple[i])](pa[].pointers[i])

    comptime PackType = VariadicPack[
        origin=MutUntrackedOrigin,
        element_trait=AnyType,
        False,
        *kernel.declared_arg_types,
    ]
    var raw_pack = __mlir_op.`lit.ref.pack.from_pointer_pack`[
        _type=PackType._mlir_type
    ](ptr_tuple._mlir_value)
    var pack = PackType(raw_pack)
    return kernel.func(*pack)




# Mimic invoking the wrapped kernel from FFI via a void** argument.
def invoke_kernel_d_d[
    kernel: KernelFunction_d_d[__d]
](
    wrapped_kernel: def(
        Pointer[KernelArgPack_d_d[kernel], MutAnyOrigin],
    ) thin -> kernel.declared_ret_type,
    *args: *kernel.declared_arg_types,
) -> kernel.declared_ret_type:
    var pa = KernelArgPack_d_d[kernel]()
    comptime for i in range(kernel.declared_arg_types.length):
        comptime ArgType = kernel.declared_arg_types[i]
        comptime if looks_like_pointer_d_d[ArgType]():
            pa.pointers[i] = rebind[MutOpaquePointer[MutUntrackedOrigin]](
                args[i]
            )
        else:
            pa.pointers[i] = rebind[MutOpaquePointer[MutUntrackedOrigin]](
                Pointer(to=args[i])
            )
    return wrapped_kernel(
        Pointer(to=pa).as_unsafe_any_origin(),
    )




comptime IntPtr_d_d = Pointer[Int, MutAnyOrigin]


comptime ScalarKernel_d_d = KernelFunction_d_d[scalar_kernel_d_d]()


comptime MixedKernel_d_d = KernelFunction_d_d[mixed_kernel_d_d]()




def scalar_kernel_d_d(x: Int) -> Int:
    return x + 1




def mixed_kernel_d_d(x: Int, p: IntPtr_d_d) -> Int:
    return x + p[]




def main():
    comptime WrappedScalarKernel = wrapped_entry_point[ScalarKernel]
    # CHECK: 42
    print(invoke_kernel[ScalarKernel](WrappedScalarKernel, 41))

    var value = 7
    comptime WrappedMixedKernel = wrapped_entry_point[MixedKernel]
    # CHECK: 11
    conforms_to_d()
    print(
        invoke_kernel[MixedKernel](
            WrappedMixedKernel,
            4,
            Pointer(to=value).as_unsafe_any_origin(),
        )
    )
