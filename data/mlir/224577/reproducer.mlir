module {
  func.func @index_boundary() -> f32 {
    %large = arith.constant 9223372036854775807 : i64
    %idx = arith.index_cast %large : i64 to index
    %c1 = arith.constant 1 : index
    %r = arith.addi %idx, %c1 : index
    %A = memref.alloc() : memref<64x64xf32>
    %0 = affine.load %A[%r, %r - 1] : memref<64x64xf32>
    return %0 : f32
  }
}
