module attributes {dlti.dl_spec = #dlti.dl_spec<
  #dlti.dl_entry<!ptr.ptr<#test.const_memory_space>, #ptr.spec<size = 32, abi = 32, preferred = 64>>,
  #dlti.dl_entry<!ptr.ptr<#test.const_memory_space<5>>,#ptr.spec<size = 64, abi = 64, preferred = 64>>,
  #dlti.dl_entry<!ptr.ptr<#test.const_memory_space<4>>, #ptr.spec<size = 32, abi = 64, preferred = 64, index = 24>>,
  #dlti.dl_entry<"dlti.default_memory_space", #test.const_memory_space<7>>,
  #dlti.dl_entry<"dlti.alloca_memory_space", #test.const_memory_space<5>>,
  #dlti.dl_entry<"dlti.global_memory_space", #test.const_memory_space<2>>,
  #dlti.dl_entry<"dlti.program_memory_space", #test.const_memory_space<3>>,
  #dlti.dl_entry<"dlti.stack_alignment", 128 : i64>
>} {
// FUSED MLIR (FFL)  A: f73f1bd6  B: 04d3a7db  bridge: rename

module attributes {dlti.dl_spec = #dlti.dl_spec<
  #dlti.dl_entry<!ptr.ptr<#test.const_memory_space>, #ptr.spec<size = 32, abi = 32, preferred = 64>>,
  #dlti.dl_entry<!ptr.ptr<#test.const_memory_space<5>>,#ptr.spec<size = 64, abi = 64, preferred = 64>>,
  #dlti.dl_entry<!ptr.ptr<#test.const_memory_space<4>>, #ptr.spec<size = 32, abi = 64, preferred = 64, index = 24>>,
  #dlti.dl_entry<"dlti.default_memory_space", #test.const_memory_space<7>>,
  #dlti.dl_entry<"dlti.alloca_memory_space", #test.const_memory_space<5>>,
  #dlti.dl_entry<"dlti.global_memory_space", #test.const_memory_space<2>>,
  #dlti.dl_entry<"dlti.program_memory_space", #test.const_memory_space<3>>,
  #dlti.dl_entry<"dlti.stack_alignment", 128 : i64>
>} {
  // ===== Seed A =====
  // Test producer is after user.
  // CHECK-ANALYSIS-LABEL: test.graph_region
  test.graph_region attributes{"root"} {

    // CHECK-ANALYSIS-NEXT: test.foo{{.*}} {pos = 0
    // CHECK-ANALYSIS-NEXT: test.bar{{.*}} {pos = 2
    // CHECK-ANALYSIS-NEXT: test.baz{{.*}} {pos = 1
    %0 = "test.foo"() {selected} : () -> i32
    "test.bar"(%1, %0) {selected} : (i32, i32) -> ()
    %1 = "test.baz"() {selected} : () -> i32
  }

  // Test cycles.
  // CHECK-ANALYSIS-LABEL: test.graph_region
  test.graph_region attributes{"root"} {

    // CHECK-ANALYSIS-NEXT: test.c{{.*}} {pos = 0
    // CHECK-ANALYSIS-NEXT: test.b{{.*}} : (
    // CHECK-ANALYSIS-NEXT: test.a{{.*}} {pos = 2
    // CHECK-ANALYSIS-NEXT: test.d{{.*}} {pos = 1
    %2 = "test.c"(%1) {selected} : (i32) -> i32
    %1 = "test.b"(%0, %2) : (i32, i32) -> i32
    %0 = "test.a"(%3) {selected} : (i32) -> i32
    %3 = "test.d"() {selected} : () -> i32
  }

  // Test not all scheduled.
  // CHECK-ANALYSIS-LABEL: test.graph_region
  test.graph_region attributes{"root"} {
    %0 = "test.a"(%1) {selected} : (i32) -> i32
    %1 = "test.b"(%0) {selected} : (i32) -> i32
  }

  // CHECK-ANALYSIS-LABEL: func.func @H_e284f5b4_A_f73f1bd6_test_multiple_blocks
  func.func @H_e284f5b4_A_f73f1bd6_test_multiple_blocks() -> (i32) attributes{"root", "ordered"} {
    // CHECK-ANALYSIS-NEXT: test.foo{{.*}} {pos = 0
    %0 = "test.foo"() {selected = 2} : () -> (i32)
    // CHECK-ANALYSIS-NEXT: test.foo
    %1 = "test.foo"() : () -> (i32)
    cf.br ^bb0
  ^bb0:
    %2 = "test.foo"() {selected = 3} : () -> (i32)
    // CHECK-ANALYSIS-NEXT: test.bar{{.*}} {pos = 2
    %3 = "test.bar"(%0, %1, %2) {selected = 0} : (i32, i32, i32) -> (i32)
    cf.br ^bb1 (%2 : i32)
  ^bb1(%arg0: i32):
    %4 = "test.qux"(%arg0, %0) {selected = 1} : (i32, i32) -> (i32)
    return %4 : i32
  }

  // Test block arguments.
  test.graph_region {
  ^entry(%arg0: i32):
    %0 = "test.foo"(%arg0) : (i32) -> i32
    "test.bar"(%1, %0) : (i32, i32) -> ()
    %1 = "test.baz"(%arg0) : (i32) -> i32
  }

  // Test implicit block capture (and sort nested region).
  func.func @H_e284f5b4_A_f73f1bd6_test_graph_cfg() -> () {
    %0 = "test.foo"() : () -> i32
    cf.br ^next(%0 : i32)

  ^next(%1: i32):
    test.graph_region {
      %2 = "test.foo"(%1) : (i32) -> i32
      "test.bar"(%3, %2) : (i32, i32) -> ()
      %3 = "test.baz"(%0) : (i32) -> i32
    }
    return
  }

  // Test region ops (and recursive sort).
  test.graph_region {
    %0 = "test.foo"(%1) : (i32) -> i32
    test.graph_region attributes {a} {
      %a = "test.a"(%b) : (i32) -> i32
      %b = "test.b"(%2) : (i32) -> i32
    }
    %1 = "test.bar"(%2) : (i32) -> i32
    %2 = "test.baz"() : () -> i32
    "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space>
    "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space<3>>
    "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space<5>>
    "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space<4>>
  }

  // ===== Seed B =====
  func.func @H_e284f5b4_B_04d3a7db_spec() {
      "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space>
      "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space<3>>
      "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space<5>>
      "test.data_layout_query"() : () -> !ptr.ptr<#test.const_memory_space<4>>
      return
    }


  // P5: Float conversion & NaN/Inf constant folding
  func.func @H_e284f5b4__ffl_p5_float() -> f64 {
    %imin = arith.constant -2147483648 : i32    // INT_MIN
    %f32  = arith.sitofp %imin : i32 to f32
    %f64  = arith.extf %f32 : f32 to f64
    // 0.0 / 0.0 produces NaN — constant folder must not crash
    %zero = arith.constant 0.0 : f64
    %nan  = arith.divf %zero, %zero : f64
    // minimumf with NaN: result must be NaN per IEEE 754-2019
    %r    = arith.minimumf %f64, %nan : f64
    // extf then truncf roundtrip: must be idempotent for finite values
    %back = arith.truncf %r : f64 to f32
    %out  = arith.extf %back : f32 to f64
    return %out : f64
  }
}
}
