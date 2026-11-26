func.func @mul_negative_shift(%a: tensor<1x8x8x8xi32>, %b: tensor<1x8x8x8xi32>) -> tensor<1x8x8x8xi32> {
  %shift = "tosa.const"() <{values = dense<-1> : tensor<1xi8>}> : () -> tensor<1xi8>
  %mul = tosa.mul %a, %b, %shift : (tensor<1x8x8x8xi32>, tensor<1x8x8x8xi32>, tensor<1xi8>) -> tensor<1x8x8x8xi32>
  return %mul : tensor<1x8x8x8xi32>
}
