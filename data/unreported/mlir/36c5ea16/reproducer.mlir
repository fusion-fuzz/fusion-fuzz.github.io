module attributes {transform.with_named_sequence} {
  transform.named_sequence @m(%arg0: !transform.any_op) {
    %0 = transform.irdl.collect_matching in %arg0 : (!transform.any_op) -> (!transform.any_op) {
      func.call @callee() : () -> ()
    ^bb0(%arg1: !transform.any_op):
      irdl.dialect @test {
        irdl.operation @whatever {
          %1 = irdl.is i32
          irdl.results(foo: %1)
        }
      }
    }
    transform.yield
  }
  func.func @callee() { return }
}
