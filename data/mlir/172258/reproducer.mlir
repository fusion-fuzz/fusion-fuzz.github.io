#CSR = #sparse_tensor.encoding<{map = (d0, d1) -> (d0 : dense, d1 : compressed)}>

module {
  func.func @crash_target(%arg0: tensor<10x20xf16, #CSR>) {
    // The pass attempts to convert this arith op and potentially reconciles 
    // the function signature, crashing on the unhandled sparse tensor type.
    %0 = arith.constant 0.0 : f64
    return
  }
}
