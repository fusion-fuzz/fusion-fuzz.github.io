wasmssa.func @f() -> i32 {
  "test.fold_to_call_op"() {callee = @g} : () -> ()
  %r = wasmssa.const 0 : i32
  wasmssa.return %r : i32
}
