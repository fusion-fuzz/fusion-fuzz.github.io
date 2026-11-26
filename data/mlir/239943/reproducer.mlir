func.func @f(%src: tensor<128x256xf32>, %dest: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32> {
  %c0 = arith.constant 0 : index
  %pack = linalg.pack %src inner_dims_pos = [0, 1] inner_tiles = [%c0, %c0] into %dest
      : tensor<128x256xf32> -> tensor<?x?x?x?xf32>
  return %pack : tensor<?x?x?x?xf32>
}
