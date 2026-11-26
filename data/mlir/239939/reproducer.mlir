module attributes {transform.with_named_sequence} {
  transform.named_sequence @callee(%arg0: !transform.any_op {transform.readonly}) {
    transform.yield
  }
  transform.named_sequence @__transform_main(%root: !transform.any_op {transform.readonly}) {
    %c3 = transform.param.constant 3 : i64 -> !transform.param<i64>
    transform.include @callee failures(propagate) (%root, %c3) : (!transform.any_op, !transform.param<i64>) -> ()
    transform.yield
  }
}
