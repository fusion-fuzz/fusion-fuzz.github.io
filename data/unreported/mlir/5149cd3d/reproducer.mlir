// FUSED MLIR (FFL)  A: a81e2b8f  B: a9f977bc  bridge: rename
#B_a9f977bc_s2_BSR_row_rowmajor = #sparse_tensor.encoding<{
  map = (i, j) ->
    ( i floordiv 3 : dense
    , j floordiv 4 : compressed
    , i mod 3 : dense
    , j mod 4 : dense
    )
}>
#B_a9f977bc_s2_BSR_row_colmajor = #sparse_tensor.encoding<{
  map = (i, j) ->
    ( i floordiv 3 : dense
    , j floordiv 4 : compressed
    , j mod 4 : dense
    , i mod 3 : dense
    )
}>
#B_a9f977bc_s2_BSR_col_rowmajor = #sparse_tensor.encoding<{
  map = (i, j) ->
    ( j floordiv 4 : dense
    , i floordiv 3 : compressed
    , i mod 3 : dense
    , j mod 4 : dense
    )
}>
#B_a9f977bc_s2_BSR_col_colmajor = #sparse_tensor.encoding<{
  map = (i, j) ->
    ( j floordiv 4 : dense
    , i floordiv 3 : compressed
    , j mod 4 : dense
    , i mod 3 : dense
    )
}>

module {
  // ===== Seed A =====
  func.func @A_a81e2b8f_test_cfg(%cond: i1) -> ()
      attributes {tag = "test_cfg"} {
    cf.br ^bb1

  ^bb1:
    cf.cond_br %cond, ^bb1, ^bb2

  ^bb2:
    return
  }

  func.func @A_a81e2b8f_test_region_control_flow(%cond: i1, %arg0: i64, %arg1: i64) -> () {
    scf.if %cond {
      scf.yield {then}
    } else {
      scf.yield {else}
    } {tag = "test_if"}

    // test_while:
    //  region #0
    // region_preds: (all) predecessors:
    //   scf.while
    //   scf.yield
    //  region #1
    // region_preds: (all) predecessors:
    //   scf.condition
    // op_preds: (all) predecessors:
    //   scf.condition
    %c2_i64 = arith.constant 2 : i64
    %0:2 = scf.while (%arg2 = %arg0) : (i64) -> (i64, i64) {
      %1 = arith.cmpi slt, %arg2, %arg1 : i64
      scf.condition(%1) %arg2, %arg2 : i64, i64
    } do {
    ^bb0(%arg2: i64, %arg3: i64):
      %1 = arith.muli %arg3, %c2_i64 : i64
      scf.yield %1 : i64
    } attributes {tag = "test_while"}

    return
  }

  func.func private @A_a81e2b8f_foo(%arg0: i32) -> i32
      attributes {tag = "foo"} {
    return {a} %arg0 : i32
  }

  func.func @A_a81e2b8f_bar(%cond: i1) -> i32
      attributes {tag = "bar"} {
    cf.cond_br %cond, ^bb1, ^bb2

  ^bb1:
    %c0 = arith.constant 0 : i32
    return {b} %c0 : i32

  ^bb2:
    %c1 = arith.constant 1 : i32
    return {c} %c1 : i32
  }

  func.func private @A_a81e2b8f_baz(i32) -> i32 attributes {tag = "baz"}

  func.func @A_a81e2b8f_test_callgraph(%cond: i1, %arg0: i32) -> i32 {
    %0 = func.call @A_a81e2b8f_foo(%arg0) {tag = "a"} : (i32) -> i32
    cf.cond_br %cond, ^bb1, ^bb2

  ^bb1:
    %1 = func.call @A_a81e2b8f_foo(%arg0) {tag = "b"} : (i32) -> i32
    return %1 : i32

  ^bb2:
    %2 = func.call @A_a81e2b8f_bar(%cond) {tag = "c"} : (i1) -> i32
    %3 = func.call @A_a81e2b8f_baz(%arg0) {tag = "d"} : (i32) -> i32
    return %2 : i32
  }

  func.func private @A_a81e2b8f_bax(%arg0: i32) {
    return {void_return}
  }

  func.func @A_a81e2b8f_test_callgraph_void_return(%arg0: i32) -> i32 {
    func.call @A_a81e2b8f_bax(%arg0) {tag = "call_void_return"}: (i32) -> ()
    return %arg0 : i32
  }

  func.func @A_a81e2b8f_test_unknown_branch() -> ()
      attributes {tag = "test_unknown_branch"} {
    "test.unknown_br"() [^bb1, ^bb2] : () -> ()

  ^bb1:
    return

  ^bb2:
    return
  }

  func.func @A_a81e2b8f_test_unknown_region() -> () {
    "test.unknown_region_br"() ({
    ^bb0:
      "test.unknown_region_end"() : () -> ()
    }, {
    ^bb0:
      "test.unknown_region_end"() : () -> ()
    }) {tag = "test_unknown_region"} : () -> ()
    return
  }

  func.func @A_a81e2b8f_test_known_dead_block() -> ()
      attributes {tag = "test_known_dead_block"} {
    %true = arith.constant true
    cf.cond_br %true, ^bb1, ^bb2

  ^bb1:
    return

  ^bb2:
    return
  }

  func.func @A_a81e2b8f_test_known_dead_edge(%arg0: i1) -> ()
      attributes {tag = "test_known_dead_edge"} {
    cf.cond_br %arg0, ^bb1, ^bb2

  ^bb1:
    %true = arith.constant true
    cf.cond_br %true, ^bb3, ^bb2

  ^bb2:
    return

  ^bb3:
    return
  }

  func.func @A_a81e2b8f_test_known_region_predecessors() -> () {
    %false = arith.constant false
    scf.if %false {
      scf.yield {then}
    } else {
      scf.yield {else}
    } {tag = "test_known_if"}
    return
  }

  func.func @A_a81e2b8f_callable() attributes {tag = "callable"} {
    return
  }

  func.func @A_a81e2b8f_test_dead_callsite() -> () {
    %true = arith.constant true
    scf.if %true {
      func.call @A_a81e2b8f_callable() {then} : () -> ()
      scf.yield
    } else {
      func.call @A_a81e2b8f_callable() {else} : () -> ()
      scf.yield
    }
    return
  }

  func.func private @A_a81e2b8f_test_dead_return(%arg0: i32) -> i32 {
    %true = arith.constant true
    cf.cond_br %true, ^bb1, ^bb1

  ^bb1:
    return {true} %arg0 : i32

  ^bb2:
    return {false} %arg0 : i32
  }

  func.func @A_a81e2b8f_test_call_dead_return(%arg0: i32) -> () {
    %0 = func.call @A_a81e2b8f_test_dead_return(%arg0) {tag = "test_dead_return"} : (i32) -> i32
    return
  }

  func.func @A_a81e2b8f_test_dca_doesnt_crash() -> () {
    %0 = scf.execute_region -> tensor<5x16xi16> {
      llvm.unreachable
    }  
    return
  }

  func.func @A_a81e2b8f_test_dca_doesnt_crash_2() -> () attributes {symbol = @notexistant} {
     return
  }

  func.func @A_a81e2b8f_test_forall_op_control_flow(%num_threads: index) {
    scf.forall (%arg0) in (%num_threads) {
    } {tag = "test_forall_op_control_flow"}
    return
  }

  func.func @A_a81e2b8f_test_for_op_control_flow() {
    %c1 = arith.constant 1 : index
    %c5 = arith.constant 5 : index
    %c6 = arith.constant 6 : index
    %c7 = arith.constant 7 : index

    // Test case 1: Zero loop iterations.
    scf.for %iv = %c5 to %c5 step %c1 {} {tag = "test_for_op_control_flow_zero"}

    // Test case 2: One loop iteration.
    scf.for %iv = %c5 to %c6 step %c1 {} {tag = "test_for_op_control_flow_one"}

    // Test case 3: More than one loop iteration.
    scf.for %iv = %c5 to %c7 step %c1 {} {tag = "test_for_op_control_flow_multi"}

    return
  }

  // ===== Seed B =====
  //
    //
    func.func @B_a9f977bc_s2_foo1() {
      // Build.
      %c0 = arith.constant 0   : index
      %f0 = arith.constant 0.0 : f64
      %m = arith.constant sparse<
          [ [0, 0], [0, 1], [2, 3], [3, 8], [3, 9], [5, 10], [5, 11] ],
          [ 1., 2., 3., 4., 5., 6., 7.]
      > : tensor<6x16xf64>
      %s1 = sparse_tensor.convert %m : tensor<6x16xf64> to tensor<?x?xf64, #B_a9f977bc_s2_BSR_row_rowmajor>
      // Test.
      sparse_tensor.print %s1 : tensor<?x?xf64, #B_a9f977bc_s2_BSR_row_rowmajor>
      // Release.
      bufferization.dealloc_tensor %s1: tensor<?x?xf64, #B_a9f977bc_s2_BSR_row_rowmajor>
      return
    }

    //
    //
    func.func @B_a9f977bc_s2_foo2() {
      // Build.
      %c0 = arith.constant 0   : index
      %f0 = arith.constant 0.0 : f64
      %m = arith.constant sparse<
          [ [0, 0], [0, 1], [2, 3], [3, 8], [3, 9], [5, 10], [5, 11] ],
          [ 1., 2., 3., 4., 5., 6., 7.]
      > : tensor<6x16xf64>
      %s2 = sparse_tensor.convert %m : tensor<6x16xf64> to tensor<?x?xf64, #B_a9f977bc_s2_BSR_row_colmajor>
      // Test.
      sparse_tensor.print %s2 : tensor<?x?xf64, #B_a9f977bc_s2_BSR_row_colmajor>
      // Release.
      bufferization.dealloc_tensor %s2: tensor<?x?xf64, #B_a9f977bc_s2_BSR_row_colmajor>
      return
    }

    //
    //
    func.func @B_a9f977bc_s2_foo3() {
      // Build.
      %c0 = arith.constant 0   : index
      %f0 = arith.constant 0.0 : f64
      %m = arith.constant sparse<
          [ [0, 0], [0, 1], [2, 3], [3, 8], [3, 9], [5, 10], [5, 11] ],
          [ 1., 2., 3., 4., 5., 6., 7.]
      > : tensor<6x16xf64>
      %s3 = sparse_tensor.convert %m : tensor<6x16xf64> to tensor<?x?xf64, #B_a9f977bc_s2_BSR_col_rowmajor>
      // Test.
      sparse_tensor.print %s3 : tensor<?x?xf64, #B_a9f977bc_s2_BSR_col_rowmajor>
      // Release.
      bufferization.dealloc_tensor %s3: tensor<?x?xf64, #B_a9f977bc_s2_BSR_col_rowmajor>
      return
    }

    //
    //
    func.func @B_a9f977bc_s2_foo4() {
      // Build.
      %c0 = arith.constant 0   : index
      %f0 = arith.constant 0.0 : f64
      %m = arith.constant sparse<
          [ [0, 0], [0, 1], [2, 3], [3, 8], [3, 9], [5, 10], [5, 11] ],
          [ 1., 2., 3., 4., 5., 6., 7.]
      > : tensor<6x16xf64>
      %s4 = sparse_tensor.convert %m : tensor<6x16xf64> to tensor<?x?xf64, #B_a9f977bc_s2_BSR_col_colmajor>
      // Test.
      sparse_tensor.print %s4 : tensor<?x?xf64, #B_a9f977bc_s2_BSR_col_colmajor>
      // Release.
      bufferization.dealloc_tensor %s4: tensor<?x?xf64, #B_a9f977bc_s2_BSR_col_colmajor>
      return
    }

    func.func @B_a9f977bc_s2_main() {
      call @A_a81e2b8f_test_dca_doesnt_crash() : () -> ()
      call @B_a9f977bc_s2_foo2() : () -> ()
      call @B_a9f977bc_s2_foo3() : () -> ()
      call @B_a9f977bc_s2_foo4() : () -> ()
      return
    }


  // P1: Integer overflow, narrowing, and sign-extension chain
  func.func @_ffl_p1_overflow() -> i32 {
    %c_max = arith.constant 2147483647 : i32
    %c_one = arith.constant 1 : i32
    // addi wraps on two's-complement overflow — canonical undefined behaviour bait
    %wrapped = arith.addi %c_max, %c_one : i32
    // Widen to i64 then trunci back — stresses constant folding of trunci(extsi(x))
    %wide  = arith.extsi %wrapped : i32 to i64
    %c_big = arith.constant 65537 : i64
    %wide2 = arith.addi %wide, %c_big : i64
    %narrow = arith.trunci %wide2 : i64 to i16
    %ext   = arith.extsi %narrow : i16 to i32
    return %ext : i32
  }
}
