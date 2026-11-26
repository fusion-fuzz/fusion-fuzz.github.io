func.func @transfer_read_index_overflow(%m: memref<3x3xf32>) -> vector<3x3xf32> {
  %c = arith.constant 9223372036854775807 : index
  %p = arith.constant 0.0 : f32
  %v = vector.transfer_read %m[%c, %c], %p : memref<3x3xf32>, vector<3x3xf32>
  return %v : vector<3x3xf32>
}
