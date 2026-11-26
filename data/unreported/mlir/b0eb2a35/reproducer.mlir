// FUSED MLIR (FFL)  A: b57b925e  B: 0fcbd7be  bridge: rename

module {
  // ===== Seed A =====
  // (seed A not plausible MLIR — omitted)

  // ===== Seed B =====
  func.func @B_0fcbd7be_main() {
      %c1_i32 = arith.constant 1 : i32
      %c1_i64 = arith.constant 1 : i64
      %0 = arith.extsi %c1_i32 : i32 to i64
      %1 = arith.addi %0, %c1_i64 : i64
      %2 = arith.extsi %c1_i32 : i32 to i64
      %3 = arith.addi %1, %2 : i64
      return
    }


  // P4: Vector broadcast, arithmetic, reduction — VectorToLLVM stress
  func.func @_ffl_p4_vector() -> i32 {
    %c5    = arith.constant 5 : i32
    %cneg  = arith.constant -1 : i32
    %splat = vector.broadcast %c5   : i32 to vector<8xi32>
    %neg   = vector.broadcast %cneg : i32 to vector<8xi32>
    // Element-wise multiply — stresses vector element type lowering
    %prod = arith.muli %splat, %neg : vector<8xi32>
    // Horizontal add reduction with explicit neutral element
    %c0   = arith.constant 0 : i32
    %sum  = vector.reduction <add>, %prod, %c0 : vector<8xi32> into i32
    return %sum : i32
  }
}
