module {
// ===== Seed A =====
  // (seed A not plausible MLIR — omitted)

  // ===== Seed B =====
  func.func private @callee(%x: i32, %y: i32) {
      %u = arith.addi %x, %x : i32   // %y is dead
      return
    }

    func.func @H_3d20b867_B_d9d3116b_caller(%a: i32, %b: i32) {
      // args segment initially has 2 operands.
      "test.call_with_segments"(%a, %b) { callee = @callee,
        operandSegmentSizes = array<i32: 0, 2, 0> } : (i32, i32) -> ()
      return
    }


  // P7: scf.while loop — structured do-while lowering stress
  func.func @H_3d20b867__ffl_p7_while() -> i32 {
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
