module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%m: !transform.any_op {transform.readonly}) {
    transform.foreach %m : !transform.any_op {
      %c0 = arith.constant 0 : i32
    }
    transform.yield
  }
}
