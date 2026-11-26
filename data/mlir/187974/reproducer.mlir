module {
  func.func @f(%arg0: tensor<3x2xi32>) -> tensor<*xi32> {
    %0 = tosa.transpose %arg0 {perms = array<i32: 0, 1>}: (tensor<3x2xi32>) -> tensor<*xi32>
    return %0 : tensor<*xi32>
  }
}
