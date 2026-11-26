#map = affine_map<(d0) -> (d0 + 6)>
func.func @f(%m: memref<32xf32>) {
  %max = arith.constant 9223372036854775807 : index
  %cst = arith.constant 1.0 : f32
  affine.for %j = 0 to #map(%max) {
    affine.store %cst, %m[%j] : memref<32xf32>
  }
  return
}
