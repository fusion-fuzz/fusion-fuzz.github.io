func.func private @B_foo(tensor<64xf32>)
  func.func private @B_bar(%A : tensor<64xf32>) {
    call @B_foo(%A) : (tensor<64xf32>) -> ()
    return
  }
