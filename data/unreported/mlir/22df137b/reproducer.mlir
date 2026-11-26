// FUSED MLIR (FFL)  A: dcaf038f  B: 1e8d09ab  bridge: rename

module {
  // ===== Seed A =====
  // Same below, but using the `ConvertToLLVMPatternInterface` entry point
  // and the generic `convert-to-llvm` pass.

  func.func @A_dcaf038f_H_925ed5a2_check_poison() {
    %0 = ub.poison : index
    %1 = ub.poison : i16
    %d1e8d09ab_c0 = arith.constant 0 : i32
    %2 = ub.poison : f64
    %3 = ub.poison : !llvm.ptr
    return
  }

  func.func @A_dcaf038f_H_925ed5a2_check_unrechable() {
    ub.unreachable
  }

  // ===== Seed B =====
  func.func private @B_1e8d09ab_callee() {
      return
    }

    func.func @B_1e8d09ab_main() -> i32 {
      func.call @A_dcaf038f_H_925ed5a2_check_unrechable() : () -> ()
      %c0 = arith.constant 0 : i32
      return %c0 : i32
    }


  // P7: scf.while loop — structured do-while lowering stress
  func.func @_ffl_p7_while() -> i32 {
    %c0  = arith.constant 0 : i32
    %c1  = arith.constant 1 : i32
    %c10 = arith.constant 10 : i32
    %res = scf.while (%arg = %c0) : (i32) -> i32 {
      // before region: compute condition
      %cond = arith.cmpi slt, %arg, %c10 : i32
      scf.condition(%cond) %arg : i32
    } do {
    ^bb0(%arg : i32):
      // after region: advance loop variable
      %next = arith.addi %arg, %c1 : i32
      scf.yield %next : i32
    }
    return %res : i32
  }
}
