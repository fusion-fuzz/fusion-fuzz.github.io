module {
  func.func @get_tile() -> index {
    %c256 = arith.constant 256 : index
    return %c256 : index
  }

  func.func @f(%A: tensor<1x3x8x1xi32>) -> tensor<7x3xi32> {
    %tile_size = func.call @get_tile() : () -> index
    %empty = tensor.empty() : tensor<7x3xi32>
    %cast = tensor.cast %A : tensor<1x3x8x1xi32> to tensor<?x3x?x1xi32>
    %unpack = linalg.unpack %cast
      inner_dims_pos = [0, 1]
      inner_tiles = [%tile_size, 1]
      into %empty : tensor<?x3x?x1xi32> -> tensor<7x3xi32>
    return %unpack : tensor<7x3xi32>
  }
}
