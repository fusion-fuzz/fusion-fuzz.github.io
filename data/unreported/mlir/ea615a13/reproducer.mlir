// FUSED MLIR (FFL)  A: 74b1e4a9  B: 090189e6  bridge: rename
#A_74b1e4a9_D_090189e6_NV_24 = #sparse_tensor.encoding<{
  map = ( i, j ) ->
  ( i            : dense,
    j floordiv 4 : dense,
    j mod 4      : structured[2, 4]
  )
}>
#B_090189e6_NV_24 = #sparse_tensor.encoding<{
  map = ( i, j ) ->
  ( i            : dense,
    j floordiv 4 : dense,
    j mod 4      : structured[2, 4]
  )
}>

module {
  // ===== Seed A =====
  module {
  // COM: --test-verify-uselistorder will randomly shuffle the uselist of every
  //      value and do a roundtrip to bytecode. An error is returned if the
  //      uselist order are not preserved when doing a roundtrip to bytecode. The
  //      test needs to verify diagnostics to be functional.

  func.func @A_74b1e4a9_H_e88ed147_base_test(%arg0 : i32) -> i32 {
    %0 = arith.constant 45 : i32
    %1 = arith.constant 46 : i32
    %2 = "test.addi"(%arg0, %arg0) : (i32, i32) -> i32
    %3 = "test.addi"(%2, %0) : (i32, i32) -> i32
    %4 = "test.addi"(%2, %1) : (i32, i32) -> i32
    %5 = "test.addi"(%3, %4) : (i32, i32) -> i32
    %6 = "test.addi"(%5, %4) : (i32, i32) -> i32
    %7 = "test.addi"(%6, %4) : (i32, i32) -> i32
    return %7 : i32
  }


  func.func @A_74b1e4a9_H_e88ed147_s1_test_with_multiple_uses_in_same_op(%arg0 : i32) -> i32 {
    %0 = arith.constant 45 : i32
    %1 = arith.constant 46 : i32
    %2 = "test.addi"(%arg0, %arg0) : (i32, i32) -> i32
    %3 = "test.addi"(%2, %0) : (i32, i32) -> i32
    %4 = "test.addi"(%2, %1) : (i32, i32) -> i32
    %5 = "test.addi"(%2, %2) : (i32, i32) -> i32
    %6 = "test.addi"(%3, %4) : (i32, i32) -> i32
    %7 = "test.addi"(%6, %5) : (i32, i32) -> i32
    %8 = "test.addi"(%7, %4) : (i32, i32) -> i32
    %9 = "test.addi"(%8, %4) : (i32, i32) -> i32
    return %9 : i32
  }


  func.func @A_74b1e4a9_H_e88ed147_s2_test_with_multiple_block_arg_uses(%arg0 : i32) -> i32 {
    %0 = arith.constant 45 : i32
    %1 = arith.constant 46 : i32
    %2 = "test.addi"(%arg0, %arg0) : (i32, i32) -> i32
    %3 = "test.addi"(%2, %arg0) : (i32, i32) -> i32
    %4 = "test.addi"(%2, %1) : (i32, i32) -> i32
    %5 = "test.addi"(%2, %2) : (i32, i32) -> i32
    %6 = "test.addi"(%3, %4) : (i32, i32) -> i32
    %7 = "test.addi"(%6, %5) : (i32, i32) -> i32
    %8 = "test.addi"(%7, %4) : (i32, i32) -> i32
    %9 = "test.addi"(%8, %4) : (i32, i32) -> i32
    return %9 : i32
  }


  // Test that use-lists in region with no dominance are preserved
  test.graph_region {
    %0 = "test.foo"(%1) : (i32) -> i32
    test.graph_region attributes {a} {
      %a = "test.a"(%b) : (i32) -> i32
      %b = "test.b"(%2) : (i32) -> i32
    }
    %1 = "test.bar"(%2) : (i32) -> i32
    // Initial A, B, C matrices.
    %d090189e6_A = tensor.generate {
    %2 = "test.baz"() : () -> i32
  }


  // This is a reproducer test (for the fixed seed run) for use-def list
  // ordering.
  func.func @A_74b1e4a9_H_e88ed147_s4_test_with_8_uses(%arg0 : i32) -> i32 {
    %0 = arith.constant 45 : i32
    %1 = "test.addi"(%arg0, %0) : (i32, i32) -> i32
    %2 = "test.addi"(%1, %0) : (i32, i32) -> i32
    %3 = "test.addi"(%1, %0) : (i32, i32) -> i32
    %4 = "test.addi"(%1, %0) : (i32, i32) -> i32
    %5 = "test.addi"(%1, %0) : (i32, i32) -> i32
    %6 = "test.addi"(%1, %0) : (i32, i32) -> i32
    %7 = "test.addi"(%1, %0) : (i32, i32) -> i32
    %8 = "test.addi"(%1, %0) : (i32, i32) -> i32
    %9 = "test.addi"(%1, %0) : (i32, i32) -> i32
    return %9 : i32
  }
  }

  // ===== Seed B =====
  llvm.func @B_090189e6_mgpuCreateSparseLtEnv()
    llvm.func @B_090189e6_mgpuDestroySparseLtEnv()

    func.func @B_090189e6_matmul24(%Ad: tensor<16x16xf16>,
                        %B: tensor<16x16xf16>,
                        %Cin: tensor<16x16xf16>) -> tensor<16x16xf16> {
      %A = sparse_tensor.convert %Ad : tensor<16x16xf16> to tensor<16x16xf16, #B_090189e6_NV_24>
      %C = linalg.matmul
        ins(%A, %B: tensor<16x16xf16, #B_090189e6_NV_24>, tensor<16x16xf16>)
        outs(%Cin: tensor<16x16xf16>) -> tensor<16x16xf16>
      return %C : tensor<16x16xf16>
    }

    func.func @B_090189e6_main() {
      llvm.call @A_74b1e4a9_H_e88ed147_s4_test_with_8_uses() : () -> ()

      %c0 = arith.constant 0 : index
      %c1 = arith.constant 1 : index
      %c16 = arith.constant 16 : index

      %f0 = arith.constant 0.0 : f16
      %f1 = arith.constant 1.0 : f16
      %f4 = arith.constant 4.0 : f16

      // Initial A, B, C matrices.
      %A = tensor.generate {
      ^bb0(%i: index, %j: index):
        %val = arith.andi %j, %c1 : index
        %cmp = arith.cmpi eq, %val, %c0 : index
        %res = arith.select %cmp, %f4, %f1 : f16
        tensor.yield %res : f16
      } : tensor<16x16xf16>
      %B = tensor.generate {
      ^bb0(%i: index, %j: index):
        %cmp = arith.cmpi eq, %i, %j : index
        %res = arith.select %cmp, %f1, %f0 : f16
        tensor.yield %res : f16
      } : tensor<16x16xf16>
      %C = tensor.generate {
      ^bb0(%i: index, %j: index):
        tensor.yield %f0 : f16
      } : tensor<16x16xf16>

      // Call the kernel.
      //
      // By effectively computing D = A B + C with id(B) and zero(C)
      // the resulting matrix returns the pruned A back to the caller.
      //
      %D = call @B_090189e6_matmul24(%A, %B, %C): (tensor<16x16xf16>,
                                        tensor<16x16xf16>,
                                        tensor<16x16xf16>) -> (tensor<16x16xf16>)

      //
      // This was the original matrix.
      //
      //
      scf.for %i = %c0 to %c16 step %c1 {
        %va = vector.transfer_read %A[%i, %c0], %f0 : tensor<16x16xf16>, vector<16xf16>
        vector.print %va : vector<16xf16>
      }

      //
      // This is the STRIP-pruned matrix.
      //
      //
      scf.for %i = %c0 to %c16 step %c1 {
        %vd = vector.transfer_read %D[%i, %c0], %f0 : tensor<16x16xf16>, vector<16xf16>
        vector.print %vd : vector<16xf16>
      }

      llvm.call @B_090189e6_mgpuDestroySparseLtEnv() : () -> ()
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
