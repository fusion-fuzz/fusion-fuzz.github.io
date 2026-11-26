func.func @B_concat(%arg0: tensor<4x7x3xf32>, %arg1 : tensor<4x4x3xf32>, %arg2: tensor<?x?x?xf32>) {
    %3 = tensor.concat dim(1) %arg2, %arg2 : (tensor<?x?x?xf32>, tensor<?x?x?xf32>) -> tensor<?x10x?xf32>
    return
  }
