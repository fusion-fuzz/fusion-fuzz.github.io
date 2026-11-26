spirv.module Logical GLSL450 {
    spirv.func @callee() -> () "None" {
      spirv.Kill
    }
    spirv.func @do_not_inline_kill() -> () "None" {
      spirv.FunctionCall @callee() : () -> ()
      spirv.Return
    }
  }
  func.func @fusion_bridge_698938439() -> i32 {
    %c = arith.constant 0 : i32
    return %c : i32
  }
  %fusion_tmp = func.call @fusion_bridge_698938439() : () -> i32
  "test.versionedC"() <{attribute = #test.attr_params<42, 24>}> : () -> ()
