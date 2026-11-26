spirv.ARM.Graph @g() -> (!spirv.arm.tensor<1xi8>) {
  %0 = spirv.ARM.GraphConstant {graph_constant_id = 0 : i32} : !spirv.arm.tensor<1xi8>
  spirv.ARM.GraphOutputs %0 : !spirv.arm.tensor<1xi8>
}
