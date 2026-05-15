// FUSED MLIR (FFL)  A: aa1bdd52  B: 9a707715

// ===== Section A =====
module {
  // (seed A not plausible MLIR — omitted)
}

// -----

// ===== Section B =====
module {
  // Note: Listener notifications appear after the pattern application because
  // the conversion driver sends all notifications at the end of the conversion
  // in bulk.
  func.func @B_9a707715_verifyDirectPattern() -> i32 {
    %result = "test.illegal_op_a"() : () -> (i32)
    return %result : i32
  }


  // Note: func.return is modified a second time when running in no-rollback
  //       mode.

  func.func @B_9a707715_verifyLargerBenefit() -> i32 {
    %result = "test.illegal_op_c"() : () -> (i32)
    return %result : i32
  }


  // Note: No block insertion because this function is external and no block
  // signature conversion is performed.

  func.func private @remap_input_1_to_0(i16)


  func.func @B_9a707715_remap_input_1_to_1(%arg0: i64) {
    "test.invalid"(%arg0) : (i64) -> ()
  }

  func.func @B_9a707715_remap_call_1_to_1(%arg0: i64) {
    call @B_9a707715_remap_input_1_to_1(%arg0) : (i64) -> ()
    return
  }


  // Block signature conversion: new block is inserted.

  // Contents of the old block are moved to the new block.

  // The old block is erased.

  // The function op gets a new type attribute.

  // "test.return" is replaced.

  func.func @B_9a707715_remap_input_1_to_N(%arg0: f32) -> f32 {
    "test.return"(%arg0) : (f32) -> ()
  }


  func.func @B_9a707715_remap_input_1_to_N_remaining_use(%arg0: f32) {
    "work"(%arg0) : (f32) -> ()
  }

  func.func @B_9a707715_remap_materialize_1_to_1(%arg0: i42) {
    "work"(%arg0) : (i42) -> ()
    "test.return"() : () -> ()
  }


  func.func @B_9a707715_remap_input_to_self(%arg0: index) {
    "work"(%arg0) : (index) -> ()
  }

  func.func @B_9a707715_remap_multi(%arg0: i64, %unused: i16, %arg1: i64) -> (i64, i64) {
   "test.invalid"(%arg0, %arg1) : (i64, i64) -> ()
  }


  func.func @B_9a707715_no_remap_nested() {
    "foo.region"() ({
      ^bb0(%i0: f64, %unused: i16, %i1: f64):
        "test.invalid"(%i0, %i1) : (f64, f64) -> ()
    }) : () -> ()
    return
  }


  func.func @B_9a707715_remap_drop_region() {
    "test.drop_region_op"() ({
      ^bb1(%i0: i64, %unused: i16, %i1: i64, %2: f32):
        "test.invalid"(%i0, %i1, %2) : (i64, i64, f32) -> ()
    }) : () -> ()
    return
  }


  func.func @B_9a707715_dropped_input_in_use(%arg: i16, %arg2: i64) {
    "work"(%arg) : (i16) -> ()
  }


  func.func @B_9a707715_up_to_date_replacement(%arg: i8) -> i8 {
    %repl_1 = "test.rewrite"(%arg) : (i8) -> i8
    %repl_2 = "test.rewrite"(%repl_1) : (i8) -> i8
    return %repl_2 : i8
  }


  func.func @B_9a707715_remove_foldable_op(%arg0 : i32) -> (i32) {
    %0 = "test.op_with_region_fold"(%arg0) ({
      "foo.op_with_region_terminator"() : () -> ()
    }) : (i32) -> (i32)
    return %0 : i32
  }


  func.func @B_9a707715_create_block() {
    // Check that we created a block with arguments.
    "test.create_block"() : () -> ()

    return
  }



  func.func @B_9a707715_bounded_recursion() {
    test.recursive_rewrite 3
    return
  }


  builtin.module {

    func.func @B_9a707715_fail_to_convert_illegal_op() -> i32 {
      %result = "test.illegal_op_f"() : () -> (i32)
      return %result : i32
    }

  }


  func.func @B_9a707715_replace_block_arg_1_to_n() {
    "test.legal_op"() ({
    ^bb0(%arg0: i32, %arg1: i16):
      "test.value_replace"(%arg0, %arg1) : (i32, i16) -> ()
      "test.return"(%arg0) : (i32) -> ()
    }) : () -> ()
    "test.return"() : () -> ()
  }


  func.func @B_9a707715_replace_op_result_1_to_n() -> i32 {
    %0 = "test.legal_op"() : () -> i32
    %1 = "test.legal_op"() : () -> i16

    "test.value_replace"(%0, %1) : (i32, i16) -> ()
    "test.return"(%0) : (i32) -> ()
  }


  // Check that a conversion pattern on `test.blackhole` can mark the producer
  // for deletion.
  func.func @B_9a707715_blackhole() {
    %input = "test.blackhole_producer"() : () -> (i32)
    "test.blackhole"(%input) : (i32) -> ()
    return
  }


  module {
  func.func private @callee() -> (f32, i24)

  func.func @B_9a707715_caller() {
    // f32 is converted to (f16, f16).
    // i24 is converted to ().
    %0:2 = func.call @callee() : () -> (f32, i24)

    "test.some_user"(%0#0, %0#1) : (f32, i24) -> ()
    "test.return"() : () -> ()
  }
  }


  func.func @B_9a707715_use_of_replaced_bbarg(%arg0: i64) {
    %0 = "test.op_with_region_fold"(%arg0) ({
      "foo.op_with_region_terminator"() : () -> ()
    }) : (i64) -> (i64)
    "test.invalid"(%0) : (i64) -> ()
  }


  func.func @B_9a707715_fold_legalization() -> i32 {
    %1 = "test.op_in_place_self_fold"() : () -> (i32)
    "test.return"(%1) : (i32) -> ()
  }


  func.func @B_9a707715_convert_detached_signature() {
    "test.detached_signature_conversion"() ({
    ^bb0(%arg0: i64):
      "test.return"() : () -> ()
    }) : () -> ()
    "test.return"() : () -> ()
  }



  func.func @B_9a707715_circular_mapping() {
    // Regression test that used to crash due to circular
    // unrealized_conversion_cast ops. 
    %0 = "test.erase_op"() ({
      "test.dummy_op_lvl_1"() ({
        "test.dummy_op_lvl_2"() : () -> ()
      }) : () -> ()
    }): () -> (i64)
    "test.drop_operands_and_replace_with_valid"(%0) : (i64) -> ()
  }


  func.func @B_9a707715_test_duplicate_block_arg() {
    test.convert_block_args duplicate {
    ^bb0(%arg0: i64):
      "test.repetitive_1_to_n_consumer"(%arg0) : (i64) -> ()
    } : () -> ()
    "test.return"() : () -> ()
  }


  func.func @B_9a707715_test_remap_block_arg() {
    %0 = "test.legal_op"() : () -> (i32)
    test.convert_block_args %0 replace_with_operand {
    ^bb0(%arg0: i32):
      "test.repetitive_1_to_n_consumer"(%arg0) : (i32) -> ()
    } : (i32) -> ()
    "test.return"() : () -> ()
  }



  // Note: There is a bug in the rollback-based conversion driver: it emits a
  // "test.cast" : (f16, f16, f16, f16) -> f16, when it should be emitting
  // three consecutive casts of (f16, f16) -> f16.
  func.func @B_9a707715_test_multiple_1_to_n_replacement() {
    %0 = "test.multiple_1_to_n_replacement"() : () -> (f16)
    "test.invalid"(%0) : (f16) -> ()
  }


  func.func @B_9a707715_test_lookup_without_converter() {
    %0 = "test.replace_with_valid_producer"() {type = i16} : () -> (i64)
    "test.replace_with_valid_consumer"(%0) {with_converter} : (i64) -> ()
    // Make sure that the second "replace_with_valid_consumer" lowering does not
    // lookup the materialization that was created for the above op.
    "test.replace_with_valid_consumer"(%0) : (i64) -> ()
    return
  }


  func.func @B_9a707715_test_skip_1to1_pattern(%arg0: f32) {
    "test.type_consumer"(%arg0) : (f32) -> ()
    return
  }


  // Demonstrate that the pattern generally works, but only for 1:1 type
  // conversions.

  func.func @B_9a707715_test_working_1to1_pattern(%arg0: f16) {
    "test.type_consumer"(%arg0) : (f16) -> ()
    "test.return"() : () -> ()
  }


  // The region of "test.post_order_legalization" is converted before the op.


  // Note: The survival of a not-explicitly-invalid operation does *not* cause
  // a conversion failure in when applying a partial conversion.
  func.func @B_9a707715_test_preorder_legalization() {
    "test.post_order_legalization"() ({
    ^bb0(%arg0: i64):
      "test.remaining_consumer"(%arg0) : (i64) -> ()
      "test.legal_op"() ({
        "test.invalid"(%arg0) : (i64) -> ()
      }) : () -> ()
      "test.invalid"(%arg0) : (i64) -> ()
    }) : () -> ()
    return
  }
}

// -----

// ===== FFL Bridge + Bug Primitives =====
module {

  // P9: Multi-result function & call — multi-value SSA lowering
  func.func @_ffl_p9_divmod(%a : i32, %b : i32) -> (i32, i32) {
    %q = arith.divsi %a, %b : i32
    %r = arith.remsi %a, %b : i32
    return %q, %r : i32, i32
  }

  func.func @_ffl_p9_call() -> i32 {
    %num = arith.constant 1000000007 : i32
    %den = arith.constant 998244353 : i32
    %q, %r = func.call @_ffl_p9_divmod(%num, %den) : (i32, i32) -> (i32, i32)
    %res = arith.addi %q, %r : i32
    return %res : i32
  }
}
