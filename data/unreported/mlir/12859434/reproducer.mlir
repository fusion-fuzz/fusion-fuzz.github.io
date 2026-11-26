#H_fe2f7db6_A_5fb79448_s2_DCSR  = #sparse_tensor.encoding<{
  map = (d0, d1) -> (d0 : compressed, d1 : compressed)
}>
module {
// ===== Seed A =====
  //
    // Main driver.
    //
    func.func @H_fe2f7db6_A_5fb79448_s2_main() {
      %c0 = arith.constant 0 : index
      %c1 = arith.constant 1 : index
      %c2 = arith.constant 2 : index
      %c3 = arith.constant 3 : index
      %t1 = tensor.empty() : tensor<4x5xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>
      %t2 = tensor.empty(%c2, %c3) : tensor<?x?xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>

      %d1_0 = tensor.dim %t1, %c0 : tensor<4x5xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>
      %d2_0 = tensor.dim %t2, %c0 : tensor<?x?xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>
      %d1_1 = tensor.dim %t1, %c1 : tensor<4x5xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>
      %d2_1 = tensor.dim %t2, %c1 : tensor<?x?xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>

      vector.print %d1_0 : index
      vector.print %d2_0 : index
      vector.print %d1_1 : index
      vector.print %d2_1 : index

      // Release resources.
      bufferization.dealloc_tensor %t1 : tensor<4x5xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>
      bufferization.dealloc_tensor %t2 : tensor<?x?xf64, #H_fe2f7db6_A_5fb79448_s2_DCSR>

      return
    }

  // ===== Seed B =====
  func.func @H_fe2f7db6_B_7855e8de_side_effect(%arg : index) {
    %0 = "test.side_effect_op"() {} : () -> i32

    %1 = "test.side_effect_op"() {effects = [
      {effect="read"}, {effect="free"}
    ]} : () -> i32

    %2 = "test.side_effect_op"() {effects = [
      {effect="write", test_resource}
    ]} : () -> i32

    %3 = "test.side_effect_op"() {effects = [
      {effect="allocate", on_result, test_resource}
    ]} : () -> i32

    "test.side_effect_op"() {effects = [
      {effect="read", on_reference = @H_fe2f7db6_A_5fb79448_s2_main, test_resource}
    ]} : () -> i32

    // No _memory_ effects, but a parametric test effect.
    %4 = "test.side_effect_op"() {
      effect_parameter = affine_map<(i, j) -> (j, i)>
    } : () -> i32

    // Check with this unregistered operation to test the fallback on the dialect.
    %5 = "test.unregistered_side_effect_op"() {
      effect_parameter = affine_map<(i, j) -> (j, i)>
    } : () -> i32

    %6 = test.side_effect_with_region_op (%arg) {
    ^bb0(%arg0 : index):
      test.region_yield %arg0 : index 
    } {effects = [ {effect="allocate", on_operand, test_resource} ]} : index -> index

    %7 = test.side_effect_with_region_op (%arg) {
    ^bb0(%arg0 : index):
      test.region_yield %arg0 : index 
    } {effects = [ {effect="allocate", on_result, test_resource} ]} : index -> index

    %8 = test.side_effect_with_region_op (%arg) {
    test.region_yield %arg : index
    ^bb0(%arg0 : index):
      test.region_yield %arg0 : index 
    } {effects = [ {effect="allocate", on_argument, test_resource} ]} : index -> index

    %9 = "test.conditional_side_effect_op"() {has_effects = false} : () -> i32

    %10 = "test.conditional_side_effect_op"() {has_effects = true} : () -> i32

    func.return 
  }

  func.func @H_fe2f7db6_B_7855e8de_parameterized_side_effect(%arg : memref<4xf32>) {
    "test.op_with_parameterized_effects"(%arg) : (memref<4xf32>) -> ()
    func.return
  }


  // P4: Vector broadcast, arithmetic, reduction — VectorToLLVM stress
  func.func @H_fe2f7db6__ffl_p4_vector() -> i32 {
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
