func.func @f() -> index {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %0 = affine.linearize_index disjoint [%c1, %c0] by (2, 4611686018427387904) : index
  return %0 : index
}
