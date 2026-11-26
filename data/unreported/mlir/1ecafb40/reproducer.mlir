#BSR = #sparse_tensor.encoding<{
  map = (i, j) -> (i floordiv 2 : dense, j floordiv 3 : compressed,
                   i mod 2 : dense, j mod 3 : dense)
}>

func.func @f(%t: tensor<?x?xi32, #BSR>, %n: index) -> index {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %lvl = arith.constant 3 : index
  %r = scf.for %i = %c0 to %n step %c1 iter_args(%a = %c0) -> (index) {
    %l = sparse_tensor.lvl %t, %lvl : tensor<?x?xi32, #BSR>
    scf.yield %l : index
  }
  return %r : index
}
