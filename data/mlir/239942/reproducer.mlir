module attributes {transform.with_named_sequence} {
  transform.named_sequence @s(%arg0: !transform.any_op {transform.readonly}) {
    %p = transform.param.constant 42 -> !transform.param<i64>
    transform.smt.constrain_params(%p) : (!transform.param<i64>) -> () {
    ^bb0(%v: !smt.int):
      "foo.bar"() : () -> ()
    }
    transform.yield
  }
}
// -----
func.func @f() {
  %0 = smt.exists ["a"] {
  ^bb0(%a: !smt.int):
    %c = smt.int.constant 0
    %e = smt.eq %a, %c : !smt.int
    smt.yield %e : !smt.bool
  } patterns {
  ^bb0(%a: !smt.int):
    "foo.bar"() : () -> ()
    smt.yield %a : !smt.int
  }
  return
}
