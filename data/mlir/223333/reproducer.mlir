func.func @f(%t: tensor<8xf32>) -> tensor<4xf32> {
  %p = ub.poison : index
  %s = tensor.extract_slice %t[%p] [4] [1] : tensor<8xf32> to tensor<4xf32>
  return %s : tensor<4xf32>
}
