func.func @f(%c: index) -> i32 {
  return %4 : i32
  %b = tensor.generate %c {
    %4 = arith.constant 0 : i32
}
