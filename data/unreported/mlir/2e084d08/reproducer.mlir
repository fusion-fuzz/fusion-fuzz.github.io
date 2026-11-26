module {
func.func @H_6e8c6abd_f(%arg0: tensor<2x3x4xf32>) -> tensor<3xindex> {
  %0 = shape.shape_of %arg0 : tensor<2x3x4xf32> -> tensor<3xindex>
  return %0 : tensor<3xindex>
}


// Basic case.
func.func @H_6e8c6abd_s1_f() -> (!shape.shape, !shape.shape) {
  %c2 = arith.constant 2 : index
  %0 = shape.const_shape [2, 3, 4, 5] : !shape.shape
  %head, %tail = "shape.split_at"(%0, %c2) : (!shape.shape, index) -> (!shape.shape, !shape.shape)
  return %head, %tail : !shape.shape, !shape.shape

}


// Negative split point.
func.func @H_6e8c6abd_s2_f() -> (!shape.shape, !shape.shape) {
  %c-1 = arith.constant -1 : index
  %0 = shape.const_shape [2, 3, 4, 5] : !shape.shape
  %head, %tail = "shape.split_at"(%0, %c-1) : (!shape.shape, index) -> (!shape.shape, !shape.shape)
  return %head, %tail : !shape.shape, !shape.shape
}


// Out of range split point. No folding.
func.func @H_6e8c6abd_s3_f() -> (!shape.shape, !shape.shape) {
  %c5 = arith.constant 5 : index
  %0 = shape.const_shape [2, 3, 4, 5] : !shape.shape
  %head, %tail = "shape.split_at"(%0, %c5) : (!shape.shape, index) -> (!shape.shape, !shape.shape)
  return %head, %tail : !shape.shape, !shape.shape
}


// Basic case.
func.func @H_6e8c6abd_s4_f() -> !shape.shape {
  %0 = shape.const_shape [1, 2] : !shape.shape
  %1 = shape.const_shape [7, 1] : !shape.shape
  %2 = shape.broadcast %0, %1 : !shape.shape, !shape.shape -> !shape.shape
  return %2 : !shape.shape
}


// Basic case including extent tensors.
func.func @H_6e8c6abd_s5_broadcast() -> tensor<2xindex> {
  %0 = shape.const_shape [1, 2] : tensor<2xindex>
  %1 = shape.const_shape [7, 1] : tensor<2xindex>
  %2 = shape.broadcast %0, %1
      : tensor<2xindex>, tensor<2xindex> -> tensor<2xindex>
  return %2 : tensor<2xindex>
}


// Basic case including extent tensors.
func.func @H_6e8c6abd_s6_broadcast() -> !shape.shape {
  %0 = shape.const_shape [1, 2] : tensor<2xindex>
  %1 = shape.const_shape [7, 1] : tensor<2xindex>
  %2 = shape.broadcast %0, %1 : tensor<2xindex>, tensor<2xindex> -> !shape.shape
  return %2 : !shape.shape
}


// Variadic case including extent tensors.
func.func @H_6e8c6abd_s7_broadcast_variadic() -> !shape.shape {
  %0 = shape.const_shape [2, 1] : tensor<2xindex>
  %1 = shape.const_shape [7, 2, 1] : tensor<3xindex>
  %2 = shape.const_shape [1, 10] : tensor<2xindex>
  %3 = shape.broadcast %0, %1, %2 : tensor<2xindex>, tensor<3xindex>, tensor<2xindex> -> !shape.shape
  return %3 : !shape.shape
}


// Rhs is a scalar.
func.func @H_6e8c6abd_s8_f(%arg0 : !shape.shape) -> !shape.shape {
  %0 = shape.const_shape [] : !shape.shape
  %1 = shape.broadcast %arg0, %0 : !shape.shape, !shape.shape -> !shape.shape
  return %1 : !shape.shape
}


// Lhs is a scalar.
func.func @H_6e8c6abd_s9_f(%arg0 : !shape.shape) -> !shape.shape {
  %0 = shape.const_shape [] : !shape.shape
  %1 = shape.broadcast %0, %arg0 : !shape.shape, !shape.shape -> !shape.shape
  return %1 : !shape.shape
}


// Lhs is a scalar and rhs is constant.
func.func @H_6e8c6abd_s10_f() -> !shape.shape {
  %0 = shape.const_shape [] : !shape.shape
  %1 = shape.const_shape [1, 2, 3] : !shape.shape
  %2 = shape.broadcast %0, %1 : !shape.shape, !shape.shape -> !shape.shape
  return %2 : !shape.shape
}


// All but one operands are known empty shapes.
func.func @H_6e8c6abd_s11_all_but_one_empty(%arg0 : !shape.shape) -> !shape.shape {
  %0 = shape.const_shape [] : !shape.shape
  %1 = shape.const_shape [] : tensor<0xindex>
  %2 = shape.broadcast %0, %arg0, %1, %0 : !shape.shape, !shape.shape,
      tensor<0xindex>, !shape.shape -> !shape.shape
  return %2 : !shape.shape
}


// All operands are known empty shapes.
func.func @H_6e8c6abd_s12_all_empty(%arg0: tensor<f32>, %arg1: tensor<i1>) -> tensor<0xindex> {
  %1 = shape.shape_of %arg0 : tensor<f32> -> tensor<0xindex>
  %2 = shape.shape_of %arg1 : tensor<i1> -> tensor<0xindex>
  %3 = shape.const_shape [] : tensor<0xindex>
  %4 = shape.broadcast %1, %2, %3 : tensor<0xindex>, tensor<0xindex>, tensor<0xindex> -> tensor<0xindex>
  return %4 : tensor<0xindex>
}


// Partial folding.
func.func @H_6e8c6abd_s13_partial_folding(%arg0 : !shape.shape) -> !shape.shape {
  %0 = shape.const_shape [2, 1] : !shape.shape
  %1 = shape.const_shape [1, 2, 3] : tensor<3xindex>
  %2 = shape.broadcast %0, %arg0, %1, %0 : !shape.shape, !shape.shape,
      tensor<3xindex>, !shape.shape -> !shape.shape
  return %2 : !shape.shape
}


// Incompatible shapes. No folding.
func.func @H_6e8c6abd_s14_f() -> !shape.shape {
  %0 = shape.const_shape [2] : !shape.shape
  %1 = shape.const_shape [7] : !shape.shape
  %2 = shape.broadcast %0, %1 : !shape.shape, !shape.shape -> !shape.shape
  return %2 : !shape.shape
}


// Dead code
func.func @H_6e8c6abd_s15_broadcast(%arg0 : !shape.shape, %arg1 : !shape.shape) {
  %0 = shape.broadcast %arg0, %arg1
      : !shape.shape, !shape.shape -> !shape.shape
  return
}


// Basic case.
func.func @H_6e8c6abd_s16_f() -> !shape.shape {
  %lhs = shape.const_shape [0, 1] : !shape.shape
  %rhs = shape.const_shape [2, 3] : !shape.shape
  %0 = shape.concat %lhs, %rhs : !shape.shape , !shape.shape -> !shape.shape
  return %0 : !shape.shape
}


// Basic case.
func.func @H_6e8c6abd_s17_f() -> tensor<4xindex> {
  %lhs = shape.const_shape [0, 1] : tensor<2xindex>
  %rhs = shape.const_shape [2, 3] : tensor<2xindex>
  %0 = shape.concat %lhs, %rhs : tensor<2xindex>, tensor<2xindex> -> tensor<4xindex>
  return %0 : tensor<4xindex>
}


// Basic case.
func.func @H_6e8c6abd_s18_f() -> tensor<2xindex> {
  %cs = shape.const_shape [0, 1] : !shape.shape
  %0 = shape.to_extent_tensor %cs : !shape.shape -> tensor<2xindex>
  return %0 : tensor<2xindex>
}


// Basic case.
func.func @H_6e8c6abd_s19_f() -> !shape.shape {
  %e0 = arith.constant 3 : index
  %e1 = arith.constant 5 : index
  %e2 = arith.constant 11 : index
  %ret = shape.from_extents %e0, %e1, %e2 : index, index, index
  return %ret : !shape.shape
}


// fold_const_size
func.func @H_6e8c6abd_s20_fold_const_size() -> !shape.shape {
  %e0 = shape.const_size 3
  %e1 = shape.const_size 5
  %ret = shape.from_extents %e0, %e1 : !shape.size, !shape.size
  return %ret : !shape.shape
}


func.func @H_6e8c6abd_s21_no_fold(%arg0: index) -> !shape.shape {
  %e0 = arith.constant 3 : index
  %ret = shape.from_extents %e0, %arg0 : index, index
  return %ret : !shape.shape
}


// GH#178820: Verify from_extents doesn't crash on poison operands.
func.func @H_6e8c6abd_s22_from_extents_poison() -> !shape.shape {
  %0 = ub.poison : index
  %ret = shape.from_extents %0 : index
  return %ret : !shape.shape
}


// Cast constant size to index and fold it away.
func.func @H_6e8c6abd_s23_const_size_to_index() -> index {
  %cs = shape.const_size 123
  %ci = shape.size_to_index %cs : !shape.size
  return %ci : index
}


// Cast constant index to size and fold it away.
func.func @H_6e8c6abd_s24_const_index_to_size() -> !shape.size {
  %ci = arith.constant 123 : index
  %cs = shape.index_to_size %ci
  return %cs : !shape.size
}


// Cast constant index to size, then back, and fold it away.
func.func @H_6e8c6abd_s25_const_index_to_size_to_index() -> index {
  %ci0 = arith.constant 123 : index
  %cs0 = shape.index_to_size %ci0
  %ci1 = shape.size_to_index %cs0 : !shape.size
  return %ci1 : index
}


// No folding.
func.func @H_6e8c6abd_s26_nonfoldable_size_to_index(%cs : !shape.size) -> index {
  %ci = shape.size_to_index %cs : !shape.size
  return %ci : index
}


// No folding.
func.func @H_6e8c6abd_s27_nonfoldable_index_to_size(%ci : index) -> !shape.size {
  %cs = shape.index_to_size %ci
  return %cs : !shape.size
}


// Fold number of elements computation.
func.func @H_6e8c6abd_s28_num_elements() -> !shape.size {
  %shape = shape.const_shape [4, 5, 6] : !shape.shape
  %num_elements = shape.num_elements %shape : !shape.shape -> !shape.size
  return %num_elements : !shape.size
}


// No folding.
func.func @H_6e8c6abd_s29_nonfoldable_num_elements(%shape : !shape.shape) -> !shape.size {
  %num_elements = shape.num_elements %shape : !shape.shape -> !shape.size
  return %num_elements : !shape.size
}


// Basic folding.
func.func @H_6e8c6abd_s30_basic() -> index {
  %0 = shape.const_shape [0, 1, 2] : tensor<3xindex>
  %c2 = arith.constant 2 : index
  %1 = shape.get_extent %0, %c2 : tensor<3xindex>, index -> index
  return %1 : index
}


// Should not fold.
func.func @H_6e8c6abd_s31_out_of_bounds() -> index {
  %0 = shape.const_shape [0, 1, 2] : tensor<3xindex>
  %c3 = arith.constant 3 : index
  %1 = shape.get_extent %0, %c3 : tensor<3xindex>, index -> index
  return %1 : index
}


// Should not fold.
func.func @H_6e8c6abd_s32_not_const(%arg0: tensor<?xindex>) -> index {
  %c3 = arith.constant 3 : index
  %0 = shape.get_extent %arg0, %c3 : tensor<?xindex>, index -> index
  return %0 : index
}


// Basic folding.
func.func @H_6e8c6abd_s33_basic() -> !shape.size {
  %0 = shape.const_shape [0, 1, 2] : !shape.shape
  %c2 = shape.const_size 2
  %1 = shape.get_extent %0, %c2 : !shape.shape, !shape.size -> !shape.size
  return %1 : !shape.size
}


// Should not fold.
func.func @H_6e8c6abd_s34_out_of_bounds() -> !shape.size {
  %0 = shape.const_shape [0, 1, 2] : !shape.shape
  %c3 = shape.const_size 3
  %1 = shape.get_extent %0, %c3 : !shape.shape, !shape.size -> !shape.size
  return %1 : !shape.size
}


// Should not fold.
func.func @H_6e8c6abd_s35_not_const(%arg0 : !shape.shape) -> !shape.size {
  %c3 = shape.const_size 3
  %0 = shape.get_extent %arg0, %c3 : !shape.shape, !shape.size -> !shape.size
  return %0 : !shape.size
}


// cstr_eq with non-constant but known equal shapes can be removed.
func.func @H_6e8c6abd_s36_f(%arg0 : !shape.shape) {
  %0 = shape.cstr_eq %arg0, %arg0, %arg0 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// cstr_eq with equal const_shapes can be folded
func.func @H_6e8c6abd_s37_f() {
  %cs0 = shape.const_shape [0, 1] : !shape.shape
  %cs1 = shape.const_shape [0, 1] : !shape.shape
  %cs2 = shape.const_shape [0, 1] : !shape.shape
  %0 = shape.cstr_eq %cs0, %cs1, %cs2 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// cstr_eq with unequal const_shapes cannot be folded
func.func @H_6e8c6abd_s38_f() {
  %cs0 = shape.const_shape [0, 1] : !shape.shape
  %cs1 = shape.const_shape [3, 1] : !shape.shape
  %0 = shape.cstr_eq %cs0, %cs1 : !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// cstr_eq without const_shapes cannot be folded
func.func @H_6e8c6abd_s39_f(%arg0: !shape.shape, %arg1: !shape.shape) {
  %0 = shape.cstr_eq %arg0, %arg1 : !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// cstr_require with constant can be folded
func.func @H_6e8c6abd_s40_cstr_require_fold() {
  %true = arith.constant true
  %0 = shape.cstr_require %true, "msg"
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// cstr_require without constant cannot be folded
func.func @H_6e8c6abd_s41_cstr_require_no_fold(%arg0: i1) {
  %0 = shape.cstr_require %arg0, "msg"
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// merge assuming_all operations
func.func @H_6e8c6abd_s42_f() {
  %0 = "test.source"() : () -> !shape.witness
  %1 = "test.source"() : () -> !shape.witness
  %2 = "test.source"() : () -> !shape.witness
  %3 = shape.assuming_all %0, %1
  %4 = shape.assuming_all %3, %2
  "consume.witness"(%4) : (!shape.witness) -> ()
  return
}


// `assuming_all` with all `cstr_eq` and shared operands can be collapsed.
func.func @H_6e8c6abd_s43_assuming_all_to_cstr_eq(%a : !shape.shape, %b : tensor<?xindex>,
    %c : tensor<3xindex>) -> !shape.witness {
  %0 = shape.cstr_eq %a, %b : !shape.shape, tensor<?xindex>
  %1 = shape.cstr_eq %b, %c : tensor<?xindex>, tensor<3xindex>
  %2 = shape.assuming_all %0, %1
  return %2 : !shape.witness
}


// `assuming_all` with duplicate operands.
func.func @H_6e8c6abd_s44_assuming_all_duplicate_operands(%arg0 : tensor<?xindex>,
    %arg1 : tensor<?xindex>) -> !shape.witness {
  %0 = shape.cstr_broadcastable %arg0, %arg1 : tensor<?xindex>, tensor<?xindex>
  %1 = shape.assuming_all %0, %0, %0
  return %1 : !shape.witness
}


// `assuming_all` with all `cstr_eq` but disjoint operands cannot be collapsed.
func.func @H_6e8c6abd_s45_assuming_all_to_cstr_eq(%a : !shape.shape, %b : tensor<?xindex>,
    %c : tensor<3xindex>, %d : tensor<3xindex>) -> !shape.witness {
  %0 = shape.cstr_eq %a, %b : !shape.shape, tensor<?xindex>
  %1 = shape.cstr_eq %c, %d : tensor<3xindex>, tensor<3xindex>
  %2 = shape.assuming_all %0, %1
  return %2 : !shape.witness
}


// assuming_all with known passing witnesses can be folded
func.func @H_6e8c6abd_s46_f() {
  %0 = shape.const_witness true
  %1 = shape.const_witness true
  %2 = shape.const_witness true
  %3 = shape.assuming_all %0, %1, %2
  "consume.witness"(%3) : (!shape.witness) -> ()
  return
}


// assuming_all should not be removed if more than one witness is not
// statically passing
//
// Additionally check that the attribute is moved to the end as this op is
// commutative.
func.func @H_6e8c6abd_s47_f() {
  %0 = shape.const_witness true
  %1 = "test.source"() : () -> !shape.witness
  %2 = "test.source"() : () -> !shape.witness
  %3 = shape.assuming_all %0, %1, %2
  "consume.witness"(%3) : (!shape.witness) -> ()
  return
}


// merge cstr_broadcastable operations
//
func.func @H_6e8c6abd_s48_f(%arg0 : !shape.shape, %arg1 : !shape.shape, %arg2 : !shape.shape) {
  %0 = shape.cstr_broadcastable %arg0, %arg1 : !shape.shape, !shape.shape
  %1 = shape.cstr_broadcastable %arg0, %arg1, %arg2 : !shape.shape, !shape.shape, !shape.shape
  %2 = shape.assuming_all %0, %1
  "consume.witness"(%2) : (!shape.witness) -> ()
  return
}


// do not merge cstr_broadcastable operations
//
func.func @H_6e8c6abd_s49_f(%arg0 : !shape.shape, %arg1 : !shape.shape, %arg2 : !shape.shape) {
  %0 = shape.cstr_broadcastable %arg0, %arg1 : !shape.shape, !shape.shape
  %1 = shape.cstr_broadcastable %arg1, %arg2 : !shape.shape, !shape.shape
  %2 = shape.assuming_all %0, %1
  "consume.witness"(%2) : (!shape.witness) -> ()
  return
}


// any can be replaced with a constant input if it has one.
func.func @H_6e8c6abd_s50_f(%arg : !shape.shape) -> !shape.shape {
  %0 = shape.const_shape [2, 3, 4] : !shape.shape
  %1 = shape.any %0, %arg : !shape.shape, !shape.shape -> !shape.shape
  return %1 : !shape.shape
}


// any can be replaced with a constant input if it has one.
func.func @H_6e8c6abd_s51_f(%arg : tensor<?xindex>) -> tensor<3xindex> {
  %0 = shape.const_shape [2, 3, 4] : tensor<3xindex>
  %1 = shape.any %0, %arg : tensor<3xindex>, tensor<?xindex> -> tensor<3xindex>
  return %1 : tensor<3xindex>
}


// Folding of any with partially constant operands is not yet implemented.
func.func @H_6e8c6abd_s52_f(%arg0 : !shape.shape, %arg1 : !shape.shape) -> !shape.shape {
  %1 = shape.any %arg0, %arg1 : !shape.shape, !shape.shape -> !shape.shape
  return %1 : !shape.shape
}


// assuming with a known passing witness can be removed
func.func @H_6e8c6abd_s53_f() {
  %0 = shape.const_witness true
  %1 = shape.assuming %0 -> index {
    %2 = "test.source"() : () -> (index)
    shape.assuming_yield %2 : index
  }
  "test.sink"(%1) : (index) -> ()
  return
}


// assuming without a known passing passing witness cannot be removed
func.func @H_6e8c6abd_s54_f() {
  %0 = "test.source"() : () -> (!shape.witness)
  %1 = shape.assuming %0 -> index {
    %2 = "test.source"() : () -> (index)
    shape.assuming_yield %2 : index
  }
  "test.sink"(%1) : (index) -> ()
  return
}


// Remove unused results from assuming ops.
func.func @H_6e8c6abd_s55_unused_assuming_results() {
  %0 = "test.source"() : () -> (!shape.witness)
  %1:2 = shape.assuming %0 -> (f32, f32) {
    %2 = "produce.redundant"() : () -> (f32)
    %3 = "produce.meaningful"() : () -> (f32)
    %d612e94ba_arg = ub.poison : tensor<?xindex>
    %d612e94ba_0 = shape.to_extent_tensor %d612e94ba_arg : tensor<?xindex> -> tensor<?xindex>
    shape.assuming_yield %2, %3 : f32, f32
  }
  "use"(%1#1) : (f32) -> ()
  return
}


// Broadcastable with broadcastable constant shapes can be removed.
func.func @H_6e8c6abd_s56_f() {
  %cs0 = shape.const_shape [3, 1] : !shape.shape
  %cs1 = shape.const_shape [1, 5] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs1 : !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Empty shape arguments can be removed from broadcastable ops.
func.func @H_6e8c6abd_s57_f(%arg0 : tensor<?xindex>, %arg1 : tensor<?xindex>, %arg2 : tensor<0xindex>) {
  %0 = shape.const_shape [] : !shape.shape
  %1 = shape.cstr_broadcastable %arg0, %arg1, %0, %arg2
      : tensor<?xindex>, tensor<?xindex>, !shape.shape, tensor<0xindex>
  "consume.witness"(%1) : (!shape.witness) -> ()
  return
}


// Broadcastable with non-broadcastable constant shapes is always false
func.func @H_6e8c6abd_s58_static_non_broadcastable() {
  %cs0 = shape.const_shape [1, 3] : !shape.shape
  %cs1 = shape.const_shape [1, 5] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs1 : !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Broadcastable without guaranteed broadcastable shapes cannot be removed.
func.func @H_6e8c6abd_s59_f(%arg0 : !shape.shape) {
  %cs0 = shape.const_shape [1, 3] : !shape.shape
  %0 = shape.cstr_broadcastable %arg0, %cs0 : !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Broadcastable with non-constant but known equal shapes can be removed.
func.func @H_6e8c6abd_s60_f(%arg0 : !shape.shape) {
  %0 = shape.cstr_broadcastable %arg0, %arg0 : !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Broadcastable canonicalization also works on extent tensors.
func.func @H_6e8c6abd_s61_broadcastable_on_extent_tensors(%arg : tensor<?xindex>) {
  %0 = shape.cstr_broadcastable %arg, %arg : tensor<?xindex>, tensor<?xindex>
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Fold ternary broadcastable
func.func @H_6e8c6abd_s62_f() {
  %cs0 = shape.const_shape [8, 1] : !shape.shape
  %cs1 = shape.const_shape [1, 8] : !shape.shape
  %cs2 = shape.const_shape [1, 1] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs1, %cs2 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Fold ternary broadcastable with dynamic ranks
func.func @H_6e8c6abd_s63_f() {
  %cs0 = shape.const_shape [8, 1] : !shape.shape
  %cs1 = shape.const_shape [1, -9223372036854775808] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs0, %cs1 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// One scalar and one non-scalar and one unknown cannot be broadcasted at compile time
func.func @H_6e8c6abd_s64_f() {
  %cs0 = shape.const_shape [8, 1] : !shape.shape
  %cs1 = shape.const_shape [1, 8] : !shape.shape
  %cs2 = shape.const_shape [1, -9223372036854775808] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs1, %cs2 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// One scalar and two unknowns cannot be broadcasted at compile time
func.func @H_6e8c6abd_s65_f() {
  %cs0 = shape.const_shape [8, 1] : !shape.shape
  %cs1 = shape.const_shape [1, -9223372036854775808] : !shape.shape
  %cs2 = shape.const_shape [8, -9223372036854775808] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs1, %cs2 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Broadcastable with scalars and a non-scalar can be constant folded
func.func @H_6e8c6abd_s66_f(%arg0 : !shape.shape) {
  %cs0 = shape.const_shape [] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs0, %arg0 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// One scalar and one non-scalar and one unknown cannot be folded.
func.func @H_6e8c6abd_s67_f(%arg0 : !shape.shape) {
  %cs0 = shape.const_shape [] : !shape.shape
  %cs1 = shape.const_shape [2] : !shape.shape
  %0 = shape.cstr_broadcastable %cs0, %cs1, %arg0 : !shape.shape, !shape.shape, !shape.shape
  "consume.witness"(%0) : (!shape.witness) -> ()
  return
}


// Fold `rank` based on constant shape.
func.func @H_6e8c6abd_s68_fold_rank() -> !shape.size {
  %shape = shape.const_shape [3, 4, 5, 6, 7] : !shape.shape
  %rank = shape.rank %shape : !shape.shape -> !shape.size
  return %rank : !shape.size
}


// Do not fold `rank` if shape is dynamic.
func.func @H_6e8c6abd_s69_dont_fold_rank(%shape : !shape.shape) -> !shape.size {
  %rank = shape.rank %shape : !shape.shape -> !shape.size
  return %rank : !shape.size
}


// Fold `rank` based on constant extent tensor.
func.func @H_6e8c6abd_s70_fold_rank() -> index {
  %shape = shape.const_shape [3, 4, 5, 6, 7] : tensor<5xindex>
  %rank = shape.rank %shape : tensor<5xindex> -> index
  return %rank : index
}


// Do not fold `rank` for non-constant extent tensors.
func.func @H_6e8c6abd_s71_dont_fold_rank(%shape : tensor<?xindex>) -> index {
  %rank = shape.rank %shape : tensor<?xindex> -> index
  return %rank : index
}


// Canonicalize `rank` when shape is derived from ranked tensor.
func.func @H_6e8c6abd_s72_canonicalize_rank(%arg : tensor<1x2x?xf32>) -> index {
  %shape = shape.shape_of %arg : tensor<1x2x?xf32> -> tensor<?xindex>
  %rank = shape.rank %shape : tensor<?xindex> -> index
  return %rank : index
}


// Canonicalize `rank` when shape is derived from ranked tensor.
func.func @H_6e8c6abd_s73_canonicalize_rank_size(%arg : tensor<1x2x?xf32>) -> !shape.size {
  %shape = shape.shape_of %arg : tensor<1x2x?xf32> -> !shape.shape
  %rank = shape.rank %shape : !shape.shape -> !shape.size
  return %rank : !shape.size
}


// Do not canonicalize `rank` when shape is derived from unranked tensor.
func.func @H_6e8c6abd_s74_dont_canonicalize_rank(%arg : tensor<*xf32>) -> index {
  %shape = shape.shape_of %arg : tensor<*xf32> -> tensor<?xindex>
  %rank = shape.rank %shape : tensor<?xindex> -> index
  return %rank : index
}


// Canonicalize redundant conversion from `index` to `size` and back.
func.func @H_6e8c6abd_s75_index_to_size_to_index(%index : index) -> index {
  %size = shape.index_to_size %index
  %result = shape.size_to_index %size : !shape.size
  return %result : index
}


// Canonicalize redundant conversion from `size` to `index` and back.
func.func @H_6e8c6abd_s76_size_to_index_to_size(%size : !shape.size) -> !shape.size {
  %idx = shape.size_to_index %size : !shape.size
  %result = shape.index_to_size %idx
  return %result : !shape.size
}


// Canonicalize scalar cstr_broadcastable checks
func.func @H_6e8c6abd_s77_cstr_broadcastable_scalar(%arg0 : tensor<?xf32>) {
  %0 = shape.const_shape [] : !shape.shape
  %1 = shape.shape_of %arg0 : tensor<?xf32> -> tensor<?xindex>
  %2 = shape.cstr_broadcastable %0, %1 : !shape.shape, tensor<?xindex>
  "consume.witness"(%2) : (!shape.witness) -> ()
  return
}


// Do not canonicalize cstr_broadcastable checks with 2 unknowns
func.func @H_6e8c6abd_s78_cstr_broadcastable_unknown(%arg0 : tensor<?xf32>, %arg1 : tensor<?xf32>) {
  %0 = shape.shape_of %arg0 : tensor<?xf32> -> tensor<?xindex>
  %1 = shape.shape_of %arg1 : tensor<?xf32> -> tensor<?xindex>
  %2 = shape.cstr_broadcastable %0, %1 : tensor<?xindex>, tensor<?xindex>
  "consume.witness"(%2) : (!shape.witness) -> ()
  return
}


// Scalars are safe to broadcast to unranked sizes.
func.func @H_6e8c6abd_s79_cstr_broadcastable_scalar_unranked(%arg0 : tensor<*xf32>, %arg1 : tensor<index>) {
  %0 = shape.shape_of %arg1 : tensor<index> -> tensor<?xindex>
  %1 = shape.shape_of %arg0 : tensor<*xf32> -> tensor<?xindex>
  %2 = shape.cstr_broadcastable %0, %1 : tensor<?xindex>, tensor<?xindex>
  "consume.witness"(%2) : (!shape.witness) -> ()
  return
}


// Fold `shape_eq` for equal and constant shapes.
func.func @H_6e8c6abd_s80_shape_eq_fold_1() -> i1 {
  %a = shape.const_shape [1, 2, 3] : !shape.shape
  %b = shape.const_shape [1, 2, 3] : tensor<3xindex>
  %c = shape.const_shape [1, 2, 3] : tensor<3xindex>
  %result = shape.shape_eq %a, %b, %c : !shape.shape, tensor<3xindex>, tensor<3xindex>
  return %result : i1
}


// Fold `shape_eq` for different but constant shapes of same length.
func.func @H_6e8c6abd_s81_shape_eq_fold_0() -> i1 {
  %a = shape.const_shape [1, 2, 3] : tensor<3xindex>
  %b = shape.const_shape [4, 5, 6] : tensor<3xindex>
  %c = shape.const_shape [4, 5, 6] : tensor<3xindex>
  %result = shape.shape_eq %a, %b, %c : tensor<3xindex>, tensor<3xindex>, tensor<3xindex>
  return %result : i1
}


// Fold `shape_eq` for different but constant shapes of different length.
func.func @H_6e8c6abd_s82_shape_eq_fold_0() -> i1 {
  %a = shape.const_shape [1, 2, 3, 4, 5, 6] : !shape.shape
  %b = shape.const_shape [1, 2, 3] : !shape.shape
  %result = shape.shape_eq %a, %b : !shape.shape, !shape.shape
  return %result : i1
}


// Do not fold `shape_eq` for non-constant different shapes.
func.func @H_6e8c6abd_s83_shape_eq_do_not_fold(%a : !shape.shape) -> i1 {
  %b = shape.const_shape [4, 5, 6] : !shape.shape
  %result = shape.shape_eq %a, %b : !shape.shape, !shape.shape
  return %result : i1
}


// Fold `add` for constant sizes.
func.func @H_6e8c6abd_s84_fold_add_size() -> !shape.size {
  %c2 = shape.const_size 2
  %c3 = shape.const_size 3
  %result = shape.add %c2, %c3 : !shape.size, !shape.size -> !shape.size
  return %result : !shape.size
}


// Fold `mul` for constant sizes.
func.func @H_6e8c6abd_s85_fold_mul_size() -> !shape.size {
  %c2 = shape.const_size 2
  %c3 = shape.const_size 3
  %result = shape.mul %c2, %c3 : !shape.size, !shape.size -> !shape.size
  return %result : !shape.size
}


// Fold `mul` for constant indices.
func.func @H_6e8c6abd_s86_fold_mul_index() -> index {
  %c2 = arith.constant 2 : index
  %c3 = arith.constant 3 : index
  %result = shape.mul %c2, %c3 : index, index -> index
  return %result : index
}


// Fold `mul` for mixed constants.
func.func @H_6e8c6abd_s87_fold_mul_mixed() -> !shape.size {
  %c2 = shape.const_size 2
  %c3 = arith.constant 3 : index
  %result = shape.mul %c2, %c3 : !shape.size, index -> !shape.size
  return %result : !shape.size
}


// Fold `div` for constant sizes.
func.func @H_6e8c6abd_s88_fold_div_size() -> !shape.size {
  %c2 = shape.const_size 10
  %c3 = shape.const_size 3
  %result = shape.div %c2, %c3 : !shape.size, !shape.size -> !shape.size
  return %result : !shape.size
}


// Fold `div` for constant indices.
func.func @H_6e8c6abd_s89_fold_div_index() -> index {
  %c2 = arith.constant 10 : index
  %c3 = arith.constant 4 : index
  %result = shape.div %c2, %c3 : index, index -> index
  return %result : index
}


// Fold `div` for constant indices and lhs is negative.
func.func @H_6e8c6abd_s90_fold_div_index_neg_lhs() -> index {
  %c2 = arith.constant -10 : index
  %c3 = arith.constant 4 : index
  %result = shape.div %c2, %c3 : index, index -> index
  return %result : index
}


// Fold `div` for constant indices and rhs is negative.
func.func @H_6e8c6abd_s91_fold_div_index_neg_rhs() -> index {
  %c2 = arith.constant 10 : index
  %c3 = arith.constant -4 : index
  %result = shape.div %c2, %c3 : index, index -> index
  return %result : index
}


// Fold `div` for mixed constants.
func.func @H_6e8c6abd_s92_fold_div_mixed() -> !shape.size {
  %c2 = shape.const_size 12
  %c3 = arith.constant 3 : index
  %result = shape.div %c2, %c3 : !shape.size, index -> !shape.size
  return %result : !shape.size
}


// Fold index_cast when already on index.
func.func @H_6e8c6abd_s93_fold_index_cast_on_index(%arg: index) -> index {
  %0 = shape.size_to_index %arg : index
  return %0 : index
}


// Fold to_extent_tensor when already on tensor.
func.func @H_6e8c6abd_s94_fold_to_extent_tensor_on_tensor(%arg: tensor<?xindex>) -> tensor<?xindex> {
  %0 = shape.to_extent_tensor %arg : tensor<?xindex> -> tensor<?xindex>
  return %0 : tensor<?xindex>
}


// Fold assuming_all with a single input
func.func @H_6e8c6abd_s95_fold_assuming_all_single_element(%arg: tensor<?xindex>) {
  %0 = "test.source"() : () -> (!shape.witness)
  %1 = shape.assuming_all %0
  "consume.witness"(%1) : (!shape.witness) -> ()
  return
}


// Verify that tensor.cast folding uses the correct type
func.func @H_6e8c6abd_s96_fold_tensor.cast_of_const_shape_returned(%arg: i1) -> tensor<1xindex> {
  %0 = shape.const_shape [2] : tensor<1xindex>
  %1 = tensor.cast %0 : tensor<1xindex> to tensor<1xindex>
  return %1 : tensor<1xindex>
}


func.func @H_6e8c6abd_s97_dont_fold_tensor.cast_of_const_shape_returned_dynamic(%arg: i1) -> tensor<?xindex> {
  %0 = shape.const_shape [2] : tensor<1xindex>
  %1 = tensor.cast %0 : tensor<1xindex> to tensor<?xindex>
  return %1 : tensor<?xindex>
}


func.func @H_6e8c6abd_s98_is_broadcastable_on_same_shape(%shape : !shape.shape) -> i1 {
  %0 = shape.is_broadcastable %shape, %shape, %shape
      : !shape.shape, !shape.shape, !shape.shape
  return %0 : i1
}


func.func @H_6e8c6abd_s99_is_broadcastable_on_duplicate_shapes(%a : !shape.shape, %b : !shape.shape)
    -> i1 {
  %0 = shape.is_broadcastable %a, %b, %a, %a, %a, %b : !shape.shape,
      !shape.shape, !shape.shape, !shape.shape, !shape.shape, !shape.shape
  return %0 : i1
}


func.func @H_6e8c6abd_s100_cstr_broadcastable_on_duplicate_shapes(%a : !shape.shape,
    %b : !shape.shape) -> !shape.witness {
  %0 = shape.cstr_broadcastable %a, %b, %a, %a, %a, %b : !shape.shape,
      !shape.shape, !shape.shape, !shape.shape, !shape.shape, !shape.shape
  return %0 : !shape.witness
}


func.func @H_6e8c6abd_s101_broadcast_on_same_shape(%shape : !shape.shape) -> !shape.shape {
  %0 = shape.broadcast %shape, %shape, %shape : !shape.shape, !shape.shape,
      !shape.shape -> !shape.shape
  return %0 : !shape.shape
}


func.func @H_6e8c6abd_s102_broadcast_on_duplicate_shapes(%a : !shape.shape, %b : !shape.shape)
    -> !shape.shape {
  %0 = shape.broadcast %a, %b, %a, %a, %a, %b : !shape.shape, !shape.shape,
      !shape.shape, !shape.shape, !shape.shape, !shape.shape -> !shape.shape
  return %0 : !shape.shape
}


func.func @H_6e8c6abd_s103_broadcast_on_single_operand(%a : tensor<?xindex>) {
  %0 = shape.broadcast %a : tensor<?xindex> -> tensor<?xindex>
  "use"(%0) : (tensor<?xindex>) -> ()
  return
}


func.func @H_6e8c6abd_s104_broadcast_as_tensor_cast(%a : tensor<3xindex>) -> tensor<?xindex> {
  %0 = shape.broadcast %a : tensor<3xindex> -> tensor<?xindex>
  return %0 : tensor<?xindex>
}


func.func @H_6e8c6abd_s105_broadcast_as_from_extent_tensor(%a : tensor<?xindex>) -> !shape.shape {
  %0 = shape.broadcast %a : tensor<?xindex> -> !shape.shape
  return %0 : !shape.shape
}


func.func @H_6e8c6abd_s106_shape_of_from_reshape(%arg0: tensor<*xf32>, %arg1: tensor<?xindex>) -> tensor<?xindex> {
  %0 = tensor.reshape %arg0(%arg1) : (tensor<*xf32>, tensor<?xindex>) -> tensor<*xf32>
  %1 = shape.shape_of %0 : tensor<*xf32> -> tensor<?xindex>
  return %1 : tensor<?xindex>
}


// Check statically shaped types, with element types i32 to index.
func.func @H_6e8c6abd_s107_shape_of_from_reshape_int_to_index(%arg0: tensor<?x1xf32>, %arg1: tensor<3xi32>) -> tensor<3xindex> {
    %0 = tensor.reshape %arg0(%arg1) : (tensor<?x1xf32>, tensor<3xi32>) -> tensor<?x1x1xf32>
    %1 = shape.shape_of %0 : tensor<?x1x1xf32> -> tensor<3xindex>
    return %1 : tensor<3xindex>
}


// Check similar element types, with statically shaped to dynamically shaped.
func.func @H_6e8c6abd_s108_shape_of_from_reshape_static_to_dynamic(%arg0: tensor<*xf32>, %arg1: tensor<5xindex>) -> tensor<?xindex> {
  %0 = tensor.reshape %arg0(%arg1) : (tensor<*xf32>, tensor<5xindex>) -> tensor<*xf32>
  %1 = shape.shape_of %0 : tensor<*xf32> -> tensor<?xindex>
  return %1 : tensor<?xindex>
}


// Check similar element types, with dynamically shaped to statically shaped.
func.func @H_6e8c6abd_s109_shape_of_from_reshape_dynamic_to_static(%arg0: tensor<*xf32>, %arg1: tensor<?xindex>) -> tensor<5xindex> {
  %0 = tensor.reshape %arg0(%arg1) : (tensor<*xf32>, tensor<?xindex>) -> tensor<*xf32>
  %1 = shape.shape_of %0 : tensor<*xf32> -> tensor<5xindex>
  return %1 : tensor<5xindex>
}


// Check similar element types and similar static shape.
func.func @H_6e8c6abd_s110_shape_of_from_reshape_identical_types(%arg0: tensor<*xf32>, %arg1: tensor<5xindex>) -> tensor<5xindex> {
  %0 = tensor.reshape %arg0(%arg1) : (tensor<*xf32>, tensor<5xindex>) -> tensor<*xf32>
  %1 = shape.shape_of %0 : tensor<*xf32> -> tensor<5xindex>
  return %1 : tensor<5xindex>
}


func.func @H_6e8c6abd_s111_shape_of_from_reshape_nofold(%arg0: tensor<*xf32>, %arg1: tensor<?xindex>) -> !shape.shape {
  %0 = tensor.reshape %arg0(%arg1) : (tensor<*xf32>, tensor<?xindex>) -> tensor<*xf32>
  %1 = shape.shape_of %0 : tensor<*xf32> -> !shape.shape
  return %1 : !shape.shape
}


func.func @H_6e8c6abd_s112_cast_extent_tensor(%arg : tensor<?x?x?xf32>) -> tensor<?xindex> {
  %0 = shape.shape_of %arg : tensor<?x?x?xf32> -> tensor<3xindex>
  %1 = tensor.cast %0 : tensor<3xindex> to tensor<?xindex>
  return %1 : tensor<?xindex>
}


func.func @H_6e8c6abd_s113_cast_extent_tensor(%arg : tensor<?x?x?xf32>) -> tensor<3xindex> {
  %0 = shape.shape_of %arg : tensor<?x?x?xf32> -> tensor<?xindex>
  %1 = tensor.cast %0 : tensor<?xindex> to tensor<3xindex>
  return %1 : tensor<3xindex>
}


func.func @H_6e8c6abd_s114_cast_extent_tensor(%arg : tensor<?x?x?x?xf32>) -> tensor<3xindex> {
  %0 = shape.shape_of %arg : tensor<?x?x?x?xf32> -> tensor<?xindex>
  %1 = tensor.cast %0 : tensor<?xindex> to tensor<3xindex>
  return %1 : tensor<3xindex>
}


func.func @H_6e8c6abd_s115_cast_extent_tensor(%arg : tensor<*xf32>) -> tensor<3xindex> {
  %0 = shape.shape_of %arg : tensor<*xf32> -> tensor<?xindex>
  %1 = tensor.cast %0 : tensor<?xindex> to tensor<3xindex>
  return %1 : tensor<3xindex>
}


func.func @H_6e8c6abd_s116_max_same_arg(%a: !shape.shape) -> !shape.shape {
  %1 = shape.max %a, %a : !shape.shape, !shape.shape -> !shape.shape
  return %1 : !shape.shape
}


func.func @H_6e8c6abd_s117_min_same_arg(%a: !shape.shape) -> !shape.shape {
  %1 = shape.min %a, %a : !shape.shape, !shape.shape -> !shape.shape
  return %1 : !shape.shape
}


func.func @H_6e8c6abd_s118_cstr_broadcastable_folding(%arg : tensor<?x4xf32>) {
  %0 = shape.shape_of %arg : tensor<?x4xf32> -> tensor<2xindex>
  %1 = shape.const_shape [4] : tensor<1xindex>
  %2 = shape.cstr_broadcastable %0, %1: tensor<2xindex>, tensor<1xindex>
  "use"(%2) : (!shape.witness) -> ()
}


func.func @H_6e8c6abd_s119_cast_extent_tensor_operands(%arg0 : tensor<?xindex>,
    %arg1 : tensor<3xindex>) -> (!shape.witness, tensor<?xindex>) {
  %0 = tensor.cast %arg0 : tensor<?xindex> to tensor<3xindex>
  %1 = tensor.cast %arg1 : tensor<3xindex> to tensor<?xindex>
  %2 = shape.cstr_broadcastable %0, %1 : tensor<3xindex>, tensor<?xindex>
  %3 = shape.broadcast %0, %1 :tensor<3xindex>, tensor<?xindex>
      -> tensor<?xindex>
  return %2, %3 : !shape.witness, tensor<?xindex>
}


func.func @H_6e8c6abd_s120_concretize_broadcast_result_type(%arg0 : tensor<2xindex>,
    %arg1 : tensor<3xindex>) -> tensor<?xindex> {
  %0 = shape.broadcast %arg0, %arg1 : tensor<2xindex>, tensor<3xindex>
      -> tensor<?xindex>
  return %0 : tensor<?xindex>
}


func.func @H_6e8c6abd_s121_extract_shapeof(%arg0 : tensor<?x?xf64>) -> index {
 %c1 = arith.constant 1 : index
 %shape = shape.shape_of %arg0 : tensor<?x?xf64> -> tensor<2xindex>
 %result = tensor.extract %shape[%c1] : tensor<2xindex>
 return %result : index
}


func.func @H_6e8c6abd_s122_add_poison() -> !shape.size {
  %1 = shape.const_size 2
  %2 = ub.poison : !shape.size
  %result = shape.add %1, %2 : !shape.size, !shape.size -> !shape.size
  return %result : !shape.size
}


func.func @H_6e8c6abd_s123_shape_of_0d(%arg0: tensor<f32>) -> tensor<?xindex> {
  %0 = shape.shape_of %arg0 : tensor<f32> -> tensor<?xindex>
  return %0 : tensor<?xindex>
}


func.func @H_6e8c6abd_s124_shape_of_static_with_shape_result(%arg0: tensor<3xf32>) -> !shape.shape {
  %0 = shape.shape_of %arg0 : tensor<3xf32> -> !shape.shape
  return %0 : !shape.shape
}


// Regression test for https://github.com/llvm/llvm-project/issues/179679:
// shape.broadcast fold used to crash with an unchecked cast when one of the
// operands was ub.poison (a non-DenseIntElementsAttr attribute). The fold
// must bail out gracefully instead.

func.func @H_6e8c6abd_s125_broadcast_no_crash_on_poison() {
  %0 = shape.const_shape [1, 2, 3] : tensor<3xindex>
  %1 = ub.poison : tensor<3xindex>
  %2 = shape.broadcast %0, %1 : tensor<3xindex>, tensor<3xindex> -> tensor<3xindex>
  %3 = tensor.rank %2 : tensor<3xindex>
  return
}


// tensor.extract(shape.shape_of(tensor)) folds to tensor.dim.
func.func @H_6e8c6abd_s126_extract_from_shape_of_tensor(%arg0: tensor<?xf32>) -> index {
  %c0 = arith.constant 0 : index
  %shape = shape.shape_of %arg0 : tensor<?xf32> -> tensor<1xindex>
  %dim = tensor.extract %shape[%c0] : tensor<1xindex>
  return %dim : index
}


// tensor.extract(shape.shape_of(memref)) must NOT be folded to tensor.dim
// because tensor.dim requires a tensor source.  Previously this pattern
// incorrectly created tensor.dim with a memref operand, causing a crash.
func.func @H_6e8c6abd_s127_extract_from_shape_of_memref_no_fold(%arg0: memref<?xf32>) -> index {
  %c0 = arith.constant 0 : index
  %shape = shape.shape_of %arg0 : memref<?xf32> -> tensor<1xindex>
  %dim = tensor.extract %shape[%c0] : tensor<1xindex>
  return %dim : index
}
}
