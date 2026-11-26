// FUSED MLIR (FFL)  A: 78ed9cd0  B: 99cc48bf  bridge: rename

module {
  // ===== Seed A =====
  func.func @A_78ed9cd0_H_bf98bc54_matmul_divisible(%A: tensor<1024x1024xf32>,
                              %B: tensor<1024x1024xf32>,
                              %C: tensor<1024x1024xf32>)
      -> tensor<1024x1024xf32>
  {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = linalg.fill ins(%cst : f32)
                     outs(%C : tensor<1024x1024xf32>)
        -> tensor<1024x1024xf32>
    %1 = linalg.matmul ins(%A, %B : tensor<1024x1024xf32>, tensor<1024x1024xf32>)
                       outs(%0 : tensor<1024x1024xf32>)
        -> tensor<1024x1024xf32>
    return %1 : tensor<1024x1024xf32>
  }

  module attributes {transform.with_named_sequence} {
    transform.named_sequence @A_78ed9cd0_H_bf98bc54___transform_main(%arg1: !transform.any_op {transform.consumed}) {
      // Fuse linalg.fill into linalg.matmul and tile.
      %matmul_op = transform.structured.match ops{["linalg.matmul"]} in %arg1
          : (!transform.any_op) -> !transform.any_op
      %fill_op = transform.structured.match ops{["linalg.fill"]} in %arg1
          : (!transform.any_op) -> !transform.any_op
      %tiled_matmul_op, %forall_op = transform.structured.tile_using_forall %matmul_op num_threads [] tile_sizes [128, 128](mapping = [#gpu.block<y>, #gpu.block<x>])
          : (!transform.any_op) -> (!transform.any_op, !transform.any_op)
      %fused_op, %new_containing_op = transform.structured.fuse_into_containing_op %fill_op into %forall_op
          : (!transform.any_op, !transform.any_op) -> (!transform.any_op, !transform.any_op)

      // Tile linalg.matmul a second time.
      %tiled_linalg_op, %loops = transform.structured.tile_using_for %tiled_matmul_op tile_sizes [0, 0, 16] : (!transform.any_op) -> (!transform.any_op, !transform.any_op)

      // Pad linalg.matmul.
      %padded, %pad, %copy_back = transform.structured.pad %tiled_linalg_op
          {padding_values=[0.0 : f32, 0.0 : f32, 0.0 : f32],
           padding_dimensions=[0, 1, 2], nofold_flags=[1, 1, 1],
           copy_back_op = "linalg.copy"}
          : (!transform.any_op) -> (!transform.any_op, !transform.any_op, !transform.any_op)

      // Map and tile tensor.pad.
      %pad_forall_op, %tiled_pad_op = transform.structured.gpu.map_copy_to_threads
          %pad total_num_threads = 32 desired_bit_alignment = 128
          : (!transform.any_op) -> (!transform.any_op, !transform.any_op)
      transform.foreach %pad_forall_op : !transform.any_op {
      ^bb2(%arg2 : !transform.any_op):
        %if_op = transform.structured.match ops{["scf.if"]} in %arg2
            : (!transform.any_op) -> !transform.any_op
        // TODO: The scf.if can be avoided with 0x... tensors.
        transform.scf.take_assumed_branch %if_op take_else_branch
            : (!transform.any_op) -> ()
            spirv.Return
      }

      // Map and tile copy back.
      %copy_forall_op, %tiled_copy_op = transform.structured.gpu.map_copy_to_threads
          %copy_back total_num_threads = 32 desired_bit_alignment = 128
          : (!transform.any_op) -> (!transform.any_op, !transform.any_op)

      // Apply masked vectorization to padding ops.
      transform.structured.vectorize %tiled_pad_op vector_sizes [128, 4]
          : !transform.any_op

      // Assign shared memory buffer to padding.
      %buffer, %new_ops = transform.structured.bufferize_to_allocation
          %pad_forall_op {memory_space = 3, bufferize_destination_only, emit_dealloc}
          : !transform.any_op

      // Bufferize.
      %func_op_1 = transform.structured.match ops{["func.func"]} in %arg1
          : (!transform.any_op) -> !transform.any_op
      transform.bufferization.eliminate_empty_tensors %func_op_1 : !transform.any_op
      transform.apply_dce to %func_op_1 : !transform.any_op
      transform.apply_cse to %func_op_1 : !transform.any_op
      %bufferized = transform.bufferization.one_shot_bufferize
          layout{IdentityLayoutMap} %arg1 {bufferize_function_boundaries=true}
          : (!transform.any_op) -> !transform.any_op

      // Apply vectorization to copy back from shared memory.
      // TODO: Find a way to retain the handle to linalg.copy throughout
      // bufferization.
      %func_op_2 = transform.structured.match ops{["func.func"]} in %bufferized
          : (!transform.any_op) -> !transform.any_op
      %bufferized_copy_back = transform.structured.match ops{["linalg.copy"]} in %func_op_2
          : (!transform.any_op) -> !transform.any_op
      transform.structured.vectorize
          %bufferized_copy_back vector_sizes [128, 4] : !transform.any_op

      // Canonicalize, cleanup and vector lowering. This step also removes buffer
      // self-copies.
      transform.apply_patterns to %func_op_2 {
        transform.apply_patterns.canonicalization
        transform.apply_patterns.vector.lower_masked_transfers
      } {apply_cse} : !transform.any_op
      transform.yield
    }
  }


  func.func @A_78ed9cd0_H_bf98bc54_s1_matmul_not_divisible(%A: tensor<1023x1023xf32>,
                                  %B: tensor<1023x1023xf32>,
                                  %C: tensor<1023x1023xf32>)
      -> tensor<1023x1023xf32>
  {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = linalg.fill ins(%cst : f32)
                     outs(%C : tensor<1023x1023xf32>)
        -> tensor<1023x1023xf32>
    %1 = linalg.matmul ins(%A, %B : tensor<1023x1023xf32>, tensor<1023x1023xf32>)
                       outs(%0 : tensor<1023x1023xf32>)
        -> tensor<1023x1023xf32>
    return %1 : tensor<1023x1023xf32>
  }

  module attributes {transform.with_named_sequence} {
    transform.named_sequence @A_78ed9cd0_H_bf98bc54_s1___transform_main(%arg1: !transform.any_op {transform.consumed}) {
      // Fuse linalg.fill into linalg.matmul and tile.
      %matmul_op = transform.structured.match ops{["linalg.matmul"]} in %arg1
          : (!transform.any_op) -> !transform.any_op
      %fill_op = transform.structured.match ops{["linalg.fill"]} in %arg1
          : (!transform.any_op) -> !transform.any_op
      %tiled_matmul_op, %forall_op = transform.structured.tile_using_forall %matmul_op num_threads [] tile_sizes [128, 128](mapping = [#gpu.block<y>, #gpu.block<x>])
          : (!transform.any_op) -> (!transform.any_op, !transform.any_op)
      %fused_op, %new_containing_op = transform.structured.fuse_into_containing_op %fill_op into %forall_op
          : (!transform.any_op, !transform.any_op) -> (!transform.any_op, !transform.any_op)

      // Tile linalg.matmul a second time.
      %tiled_linalg_op, %loops = transform.structured.tile_using_for %tiled_matmul_op tile_sizes [0, 0, 16] : (!transform.any_op) -> (!transform.any_op, !transform.any_op)

      // Pad linalg.matmul.
      %padded, %pad, %copy_back = transform.structured.pad %tiled_linalg_op
          {padding_values=[0.0 : f32, 0.0 : f32, 0.0 : f32],
           padding_dimensions=[0, 1, 2], nofold_flags=[1, 1, 1],
           copy_back_op = "linalg.copy"}
          : (!transform.any_op) -> (!transform.any_op, !transform.any_op, !transform.any_op)

      // Map and tile tensor.pad.
      %pad_forall_op, %tiled_pad_op = transform.structured.gpu.map_copy_to_threads
          %pad total_num_threads = 32 desired_bit_alignment = 128
          : (!transform.any_op) -> (!transform.any_op, !transform.any_op)
      transform.foreach %pad_forall_op : !transform.any_op {
      ^bb2(%arg2 : !transform.any_op):
        %if_op = transform.structured.match ops{["scf.if"]} in %arg2
            : (!transform.any_op) -> !transform.any_op
        // TODO: The scf.if can be avoided with 0x... tensors.
        transform.scf.take_assumed_branch %if_op take_else_branch
            : (!transform.any_op) -> ()
      }

      // Apply masked vectorization to padding ops.
      transform.structured.vectorize %tiled_pad_op vector_sizes [128, 4]
          : !transform.any_op

      // Assign shared memory buffer to padding.
      %buffer, %new_ops = transform.structured.bufferize_to_allocation
          %pad_forall_op {memory_space = 3, bufferize_destination_only, emit_dealloc}
          : !transform.any_op

      // Bufferize.
      %func_op_1 = transform.structured.match ops{["func.func"]} in %arg1
          : (!transform.any_op) -> !transform.any_op
      transform.bufferization.eliminate_empty_tensors %func_op_1 : !transform.any_op
      transform.apply_dce to %func_op_1 : !transform.any_op
      transform.apply_cse to %func_op_1 : !transform.any_op
      %bufferized = transform.bufferization.one_shot_bufferize
          layout{IdentityLayoutMap} %arg1 {bufferize_function_boundaries=true}
          : (!transform.any_op) -> !transform.any_op

      // Apply vectorization to copy back from shared memory.
      // TODO: Find a way to retain the handle to linalg.copy throughout
      // bufferization.
      %func_op_2 = transform.structured.match ops{["func.func"]} in %bufferized
          : (!transform.any_op) -> !transform.any_op
      %bufferized_copy_back = transform.structured.match ops{["linalg.copy"]} in %func_op_2
          : (!transform.any_op) -> !transform.any_op
      transform.structured.vectorize
          %bufferized_copy_back vector_sizes [128, 4] : !transform.any_op

      // Canonicalize, cleanup and vector lowering. This step also removes buffer
      // self-copies.
      transform.apply_patterns to %func_op_2 {
        transform.apply_patterns.canonicalization
        transform.apply_patterns.vector.lower_masked_transfers
      } {apply_cse} : !transform.any_op
      transform.yield
    }
  }

  // ===== Seed B =====
  //===----------------------------------------------------------------------===//
  // spirv.Bitcast
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_bitcast_float_to_integer_scalar(%arg0 : f32) "None" {
    %0 = spirv.Bitcast %arg0: f32 to i32
    spirv.Return
  }

  spirv.func @B_99cc48bf_bitcast_float_to_integer_vector(%arg0 : vector<3xf32>) "None" {
    %0 = spirv.Bitcast %arg0: vector<3xf32> to vector<3xi32>
    spirv.Return
  }

  spirv.func @B_99cc48bf_bitcast_vector_to_scalar(%arg0 : vector<2xf32>) "None" {
    %0 = spirv.Bitcast %arg0: vector<2xf32> to i64
    spirv.Return
  }

  spirv.func @B_99cc48bf_bitcast_scalar_to_vector(%arg0 : f64) "None" {
    %0 = spirv.Bitcast %arg0: f64 to vector<2xi32>
    spirv.Return
  }

  spirv.func @B_99cc48bf_bitcast_vector_to_vector(%arg0 : vector<4xf32>) "None" {
    %0 = spirv.Bitcast %arg0: vector<4xf32> to vector<2xi64>
    spirv.Return
  }

  spirv.func @B_99cc48bf_bitcast_pointer(%arg0: !spirv.ptr<f32, Function>) "None" {
    %0 = spirv.Bitcast %arg0 : !spirv.ptr<f32, Function> to !spirv.ptr<i32, Function>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.ConvertFToS
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_convert_float_to_signed_scalar(%arg0: f32) "None" {
    %0 = spirv.ConvertFToS %arg0: f32 to i32
    spirv.Return
  }

  spirv.func @B_99cc48bf_convert_float_to_signed_vector(%arg0: vector<2xf32>) "None" {
      %0 = spirv.ConvertFToS %arg0: vector<2xf32> to vector<2xi32>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.ConvertFToU
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_convert_float_to_unsigned_scalar(%arg0: f32) "None" {
    %0 = spirv.ConvertFToU %arg0: f32 to i32
    spirv.Return
  }

  spirv.func @B_99cc48bf_convert_float_to_unsigned_vector(%arg0: vector<2xf32>) "None" {
      %0 = spirv.ConvertFToU %arg0: vector<2xf32> to vector<2xi32>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.ConvertSToF
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_convert_signed_to_float_scalar(%arg0: i32) "None" {
    %0 = spirv.ConvertSToF %arg0: i32 to f32
    spirv.Return
  }

  spirv.func @B_99cc48bf_convert_signed_to_float_vector(%arg0: vector<3xi32>) "None" {
      %0 = spirv.ConvertSToF %arg0: vector<3xi32> to vector<3xf32>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.ConvertUToF
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_convert_unsigned_to_float_scalar(%arg0: i32) "None" {
    %0 = spirv.ConvertUToF %arg0: i32 to f32
    spirv.Return
  }

  spirv.func @B_99cc48bf_convert_unsigned_to_float_vector(%arg0: vector<3xi32>) "None" {
      %0 = spirv.ConvertUToF %arg0: vector<3xi32> to vector<3xf32>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.FConvert
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_fconvert_scalar(%arg0: f32, %arg1: f64) "None" {
    %0 = spirv.FConvert %arg0: f32 to f64

    %1 = spirv.FConvert %arg1: f64 to f32
    spirv.Return
  }

  spirv.func @B_99cc48bf_fconvert_vector(%arg0: vector<2xf32>, %arg1: vector<2xf64>) "None" {
    %0 = spirv.FConvert %arg0: vector<2xf32> to vector<2xf64>

    %1 = spirv.FConvert %arg1: vector<2xf64> to vector<2xf32>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.SConvert
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_sconvert_scalar(%arg0: i32, %arg1: i64) "None" {
    %0 = spirv.SConvert %arg0: i32 to i64

    %1 = spirv.SConvert %arg1: i64 to i32
    spirv.Return
  }

  spirv.func @B_99cc48bf_sconvert_vector(%arg0: vector<3xi32>, %arg1: vector<3xi64>) "None" {
    %0 = spirv.SConvert %arg0: vector<3xi32> to vector<3xi64>

    %1 = spirv.SConvert %arg1: vector<3xi64> to vector<3xi32>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.UConvert
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_uconvert_scalar(%arg0: i32, %arg1: i64) "None" {
    %0 = spirv.UConvert %arg0: i32 to i64

    %1 = spirv.UConvert %arg1: i64 to i32
    spirv.Return
  }

  spirv.func @B_99cc48bf_uconvert_vector(%arg0: vector<3xi32>, %arg1: vector<3xi64>) "None" {
    %0 = spirv.UConvert %arg0: vector<3xi32> to vector<3xi64>

    %1 = spirv.UConvert %arg1: vector<3xi64> to vector<3xi32>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.ConvertPtrToU
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_convert_ptr_to_u(%arg0 : !spirv.ptr<i32, Generic>) "None" {
    %0 = spirv.ConvertPtrToU %arg0 : !spirv.ptr<i32, Generic> to i32
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.ConvertUToPtr
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_convert_u_to_ptr(%arg0 : i32) "None" {
    %0 = spirv.ConvertUToPtr %arg0 : i32 to !spirv.ptr<i32, Generic>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.PtrCastToGeneric
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_ptr_cast_to_generic(%arg0 : !spirv.ptr<f32, CrossWorkgroup>) "None" {
    %0 = spirv.PtrCastToGeneric %arg0 : !spirv.ptr<f32, CrossWorkgroup> to !spirv.ptr<f32, Generic>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.GenericCastToPtr
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_generic_cast_to_ptr(%arg0 : !spirv.ptr<vector<2xi32>, Generic>) "None" {
    %0 = spirv.GenericCastToPtr %arg0 : !spirv.ptr<vector<2xi32>, Generic> to !spirv.ptr<vector<2xi32>, CrossWorkgroup>
    spirv.Return
  }

  //===----------------------------------------------------------------------===//
  // spirv.GenericCastToPtrExplicit
  //===----------------------------------------------------------------------===//

  spirv.func @B_99cc48bf_generic_cast_to_ptr_explicit(%arg0 : !spirv.ptr<vector<2xi32>, Generic>) "None" {
    %0 = spirv.GenericCastToPtrExplicit %arg0 : !spirv.ptr<vector<2xi32>, Generic> to !spirv.ptr<vector<2xi32>, CrossWorkgroup>
    spirv.Return
  }


  // P2: scf.for with iter_args nested inside scf.if — dominance stress
  func.func @_ffl_p2_scf_nested() -> i64 {
    %c0   = arith.constant 0 : index
    %c1   = arith.constant 1 : index
    %c16  = arith.constant 16 : index
    %acc0 = arith.constant 0 : i64
    %one  = arith.constant 1 : i64
    %two  = arith.constant 2 : i64
    %result = scf.for %iv = %c0 to %c16 step %c1
              iter_args(%acc = %acc0) -> (i64) {
      // Cast induction var to i64 for arithmetic
      %iv64 = arith.index_cast %iv : index to i64
      %odd  = arith.remui %iv64, %two : i64
      %cond = arith.cmpi eq, %odd, %acc0 : i64
      %next = scf.if %cond -> (i64) {
        %v = arith.muli %acc, %one : i64
        scf.yield %v : i64
      } else {
        %v = arith.addi %acc, %iv64 : i64
        scf.yield %v : i64
      }
      scf.yield %next : i64
    }
    return %result : i64
  }
}
