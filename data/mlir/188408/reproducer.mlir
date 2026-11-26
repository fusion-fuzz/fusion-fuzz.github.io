module {
  func.func @fusion_bridge() -> index {
    %c = arith.constant 128 : index
    return %c : index
  }

  func.func @f(%data: memref<8xi32>) {
    acc.kernel_environment {
      acc.compute_region {
        acc.yield
      } {origin = "acc.parallel"}
    }
    return
  }

  %fusion_tmp = func.call @fusion_bridge() : () -> index
}
