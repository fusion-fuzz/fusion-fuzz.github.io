// FUSED MLIR (FFL)  A: a34375dc  B: daaeddbd  bridge: rename

module {
  // ===== Seed A =====
  // (seed A not plausible MLIR — omitted)

  // ===== Seed B =====
  func.func @B_daaeddbd_test_index_cast_shape_error(%arg0 : tensor<index>) -> tensor<2xi64> {
    %0 = arith.index_cast %arg0 : tensor<index> to tensor<2xi64>
    return %0 : tensor<2xi64>
  }


  func.func @B_daaeddbd_test_index_cast_shape_dim_error(%arg0 : tensor<2xindex>) -> tensor<?xi64> {
    %0 = arith.index_cast %arg0 : tensor<2xindex> to tensor<?xi64>
    return %0 : tensor<?xi64>
  }


  func.func @B_daaeddbd_test_index_cast_tensor_error(%arg0 : tensor<index>) -> i64 {
    %0 = arith.index_cast %arg0 : tensor<index> to i64
    return %0 : i64
  }


  func.func @B_daaeddbd_non_signless_constant() {
    %0 = arith.constant 0 : ui32
    return
  }


  func.func @B_daaeddbd_non_signless_tensor_constant() {
    %0 = arith.constant dense<[10, 20]> : tensor<2xui8>
    return
  }


  func.func @B_daaeddbd_complex_constant_wrong_attribute_type() {
    %0 = "arith.constant" () {value = 1.0 : f32} : () -> complex<f32>
    return
  }


  func.func @B_daaeddbd_non_signless_constant() {
    %0 = arith.constant 0 : si32
    return
  }


  func.func @B_daaeddbd_non_signless_vector_constant() {
    %0 = arith.constant dense<[0, 1]> : vector<2xsi32>
    return
  }


  func.func @B_daaeddbd_bitcast_different_bit_widths(%arg : f16) -> f32 {
    %res = arith.bitcast %arg : f16 to f32
    return %res : f32
  }


  func.func @B_daaeddbd_constant() {
  ^bb:
    %x = "arith.constant"(){value = "xyz"} : () -> i32 // expected-error {{'arith.constant' op failed to verify that all of {value, result} have same type}}
    return
  }


  func.func @B_daaeddbd_constant_out_of_range() {
  ^bb:
    %x = "arith.constant"(){value = 100} : () -> i1 // expected-error {{'arith.constant' op failed to verify that all of {value, result} have same type}}
    return
  }


  func.func @B_daaeddbd_constant_invalid_scalable_1d_vec_initialization() {
  ^bb0:
    %c = arith.constant dense<[0, 1]> : vector<[2] x i32>
    return
  }


  func.func @B_daaeddbd_constant_invalid_scalable_2d_vec_initialization() {
  ^bb0:
    %c = arith.constant dense<[[3, 3], [1, 1]]> : vector<2 x [2] x i32>
    return
  }


  func.func @B_daaeddbd_constant_wrong_type() {
  ^bb:
    %x = "arith.constant"(){value = 10.} : () -> f32 // expected-error {{'arith.constant' op failed to verify that all of {value, result} have same type}}
    return
  }


  func.func @B_daaeddbd_intlimit2() {
  ^bb:
    %0 = "arith.constant"() {value = 0} : () -> i16777215
    %1 = "arith.constant"() {value = 1} : () -> i16777216 // expected-error {{integer bitwidth is limited to 16777215 bits}}
    return
  }


  func.func @B_daaeddbd_func_with_ops(f32) {
  ^bb0(%a : f32):
    %sf = arith.addf %a, %a, %a : f32  // expected-error {{expected ':'}}
  }


  func.func @B_daaeddbd_func_with_ops(f32) {
  ^bb0(%a : f32):
    %sf = arith.addf(%a, %a) : f32  // expected-error {{expected SSA operand}}
  }


  func.func @B_daaeddbd_func_with_ops(f32) {
  ^bb0(%a : f32):
    %sf = arith.addf{%a, %a} : f32  // expected-error {{expected SSA operand}}
  }


  func.func @B_daaeddbd_func_with_ops(f32) {
  ^bb0(%a : f32):
    %sf = arith.addi %a, %a : f32
  }


  func.func @B_daaeddbd_func_with_ops(%a: f32) {
    %r:2 = arith.addui_extended %a, %a : f32, i32
    return
  }


  func.func @B_daaeddbd_func_with_ops(%a: i32) {
    %r:2 = arith.addui_extended %a, %a : i32, i32
    return
  }


  func.func @B_daaeddbd_func_with_ops(%a: vector<8xi32>) {
    %r:2 = arith.addui_extended %a, %a : vector<8xi32>, i1
    return
  }


  func.func @B_daaeddbd_func_with_ops(%a: vector<8xi32>) {
    %r:2 = arith.addui_extended %a, %a : vector<8xi32>, tensor<8xi1>
    return
  }


  func.func @B_daaeddbd_func_with_ops(%a: f32) {
    %r:2 = arith.subui_extended %a, %a : f32, i32
    return
  }


  func.func @B_daaeddbd_func_with_ops(%a: i32) {
    %r:2 = arith.subui_extended %a, %a : i32, i32
    return
  }


  func.func @B_daaeddbd_func_with_ops(%a: vector<8xi32>) {
    %r:2 = arith.subui_extended %a, %a : vector<8xi32>, i1
    return
  }


  func.func @B_daaeddbd_func_with_ops(%a: vector<8xi32>) {
    %r:2 = arith.subui_extended %a, %a : vector<8xi32>, tensor<8xi1>
    return
  }


  func.func @B_daaeddbd_func_with_ops(i32) {
  ^bb0(%a : i32):
    %sf = arith.addf %a, %a : i32  // expected-error {{'arith.addf' op operand #0 must be floating-point-like}}
  }


  func.func @B_daaeddbd_func_with_ops(i32) {
  ^bb0(%a : i32):
    %r = "arith.cmpi"(%a, %a) {predicate = 42} : (i32, i32) -> i1
  }


  // Comparison are defined for arguments of the same type.
  func.func @B_daaeddbd_func_with_ops(i32, i64) {
  ^bb0(%a : i32, %b : i64): // expected-note {{prior use here}}
    %r = arith.cmpi eq, %a, %b : i32 // expected-error {{use of value '%b' expects different type than prior uses}}
  }


  // Comparisons must have the "predicate" attribute.
  func.func @B_daaeddbd_func_with_ops(i32, i32) {
  ^bb0(%a : i32, %b : i32):
    %r = arith.cmpi %a, %b : i32 // expected-error {{expected string or keyword containing one of the following enum values}}
  }


  // Integer comparisons are not recognized for float types.
  func.func @B_daaeddbd_func_with_ops(f32, f32) {
  ^bb0(%a : f32, %b : f32):
    %r = arith.cmpi eq, %a, %b : f32 // expected-error {{'lhs' must be signless-non-zero-bitwidth-integer-like, but got 'f32'}}
  }


  // Result type must be boolean like.
  func.func @B_daaeddbd_func_with_ops(i32, i32) {
  ^bb0(%a : i32, %b : i32):
    %r = "arith.cmpi"(%a, %b) {predicate = 0} : (i32, i32) -> i32 // expected-error {{op result #0 must be bool-like}}
  }


  func.func @B_daaeddbd_func_with_ops(i32, i32) {
  ^bb0(%a : i32, %b : i32):
    %r = "arith.cmpi"(%a, %b) {foo = 1} : (i32, i32) -> i1
  }


  func.func @B_daaeddbd_func_with_ops() {
  ^bb0:
    %c = arith.constant dense<0> : vector<42 x i32>
    %r = "arith.cmpi"(%c, %c) {predicate = 0} : (vector<42 x i32>, vector<42 x i32>) -> vector<41 x i1>
  }


  func.func @B_daaeddbd_func_with_ops() {
  ^bb0:
    %c = arith.constant dense<0> : tensor<42 x i32, "foo">
    %r = "arith.cmpi"(%c, %c) {predicate = 0} : (tensor<42 x i32, "foo">, tensor<42 x i32, "foo">) -> tensor<42 x i1, "bar">
  }


  func.func @B_daaeddbd_invalid_cmp_shape(%idx : () -> ()) {
    %cmp = arith.cmpi eq, %idx, %idx : () -> ()


  func.func @B_daaeddbd_invalid_cmp_attr(%idx : i32) {
    %cmp = arith.cmpi i1, %idx, %idx : i32


  func.func @B_daaeddbd_cmpf_generic_invalid_predicate_value(%a : f32) {
    %r = "arith.cmpf"(%a, %a) {predicate = 42} : (f32, f32) -> i1
  }


  func.func @B_daaeddbd_cmpf_canonical_invalid_predicate_value(%a : f32) {
    %r = arith.cmpf foo, %a, %a : f32
  }


  func.func @B_daaeddbd_cmpf_canonical_invalid_predicate_value_signed(%a : f32) {
    %r = arith.cmpf sge, %a, %a : f32
  }


  func.func @B_daaeddbd_cmpf_canonical_invalid_predicate_value_no_order(%a : f32) {
    %r = arith.cmpf eq, %a, %a : f32
  }


  func.func @B_daaeddbd_cmpf_canonical_no_predicate_attr(%a : f32, %b : f32) {
    %r = arith.cmpf %a, %b : f32 // expected-error {{}}
  }


  func.func @B_daaeddbd_cmpf_generic_no_predicate_attr(%a : f32, %b : f32) {
    %r = "arith.cmpf"(%a, %b) {foo = 1} : (f32, f32) -> i1
  }


  func.func @B_daaeddbd_cmpf_wrong_type(%a : i32, %b : i32) {
    %r = arith.cmpf oeq, %a, %b : i32 // expected-error {{must be floating-point-like}}
  }


  func.func @B_daaeddbd_cmpf_generic_wrong_result_type(%a : f32, %b : f32) {
    %r = "arith.cmpf"(%a, %b) {predicate = 0} : (f32, f32) -> f32
  }


  func.func @B_daaeddbd_cmpf_canonical_wrong_result_type(%a : f32, %b : f32) -> f32 {
    %r = arith.cmpf oeq, %a, %b : f32 // expected-note {{prior use here}}
    return %r : f32
  }


  func.func @B_daaeddbd_cmpf_result_shape_mismatch(%a : vector<42xf32>) {
    %r = "arith.cmpf"(%a, %a) {predicate = 0} : (vector<42 x f32>, vector<42 x f32>) -> vector<41 x i1>
  }


  func.func @B_daaeddbd_cmpf_operand_shape_mismatch(%a : vector<42xf32>, %b : vector<41xf32>) {
    %r = "arith.cmpf"(%a, %b) {predicate = 0} : (vector<42 x f32>, vector<41 x f32>) -> vector<42 x i1>
  }


  func.func @B_daaeddbd_cmpf_generic_operand_type_mismatch(%a : f32, %b : f64) {
    %r = "arith.cmpf"(%a, %b) {predicate = 0} : (f32, f64) -> i1
  }


  func.func @B_daaeddbd_cmpf_canonical_type_mismatch(%a : f32, %b : f64) { // expected-note {{prior use here}}
    %r = arith.cmpf oeq, %a, %b : f32
  }


  func.func @B_daaeddbd_index_cast_index_to_index(%arg0: index) {
    %0 = arith.index_cast %arg0: index to index
    return
  }


  func.func @B_daaeddbd_index_cast_float(%arg0: index, %arg1: f32) {
    %0 = arith.index_cast %arg0 : index to f32
    return
  }


  func.func @B_daaeddbd_index_cast_float_to_index(%arg0: f32) {
    %0 = arith.index_cast %arg0 : f32 to index
    return
  }


  func.func @B_daaeddbd_sitofp_i32_to_i64(%arg0 : i32) {
    %0 = arith.sitofp %arg0 : i32 to i64
    return
  }


  func.func @B_daaeddbd_sitofp_f32_to_i32(%arg0 : f32) {
    %0 = arith.sitofp %arg0 : f32 to i32
    return
  }


  func.func @B_daaeddbd_fpext_f32_to_f16(%arg0 : f32) {
    %0 = arith.extf %arg0 : f32 to f16
    return
  }


  func.func @B_daaeddbd_fpext_f16_to_f16(%arg0 : f16) {
    %0 = arith.extf %arg0 : f16 to f16
    return
  }


  func.func @B_daaeddbd_fpext_i32_to_f32(%arg0 : i32) {
    %0 = arith.extf %arg0 : i32 to f32
    return
  }


  func.func @B_daaeddbd_fpext_f32_to_i32(%arg0 : f32) {
    %0 = arith.extf %arg0 : f32 to i32
    return
  }


  func.func @B_daaeddbd_fpext_vec(%arg0 : vector<2xf16>) {
    %0 = arith.extf %arg0 : vector<2xf16> to vector<3xf32>
    return
  }


  func.func @B_daaeddbd_fpext_vec_f32_to_f16(%arg0 : vector<2xf32>) {
    %0 = arith.extf %arg0 : vector<2xf32> to vector<2xf16>
    return
  }


  func.func @B_daaeddbd_fpext_vec_f16_to_f16(%arg0 : vector<2xf16>) {
    %0 = arith.extf %arg0 : vector<2xf16> to vector<2xf16>
    return
  }


  func.func @B_daaeddbd_fpext_vec_i32_to_f32(%arg0 : vector<2xi32>) {
    %0 = arith.extf %arg0 : vector<2xi32> to vector<2xf32>
    return
  }


  func.func @B_daaeddbd_fpext_vec_f32_to_i32(%arg0 : vector<2xf32>) {
    %0 = arith.extf %arg0 : vector<2xf32> to vector<2xi32>
    return
  }


  func.func @B_daaeddbd_fpext_vec_f32_to_i32(%arg0 : tensor<2xf32, "foo">) {
    %0 = arith.extf %arg0 : tensor<2xf32, "foo"> to tensor<2xf64, "bar">
    return
  }


  func.func @B_daaeddbd_fptrunc_f16_to_f32(%arg0 : f16) {
    %0 = arith.truncf %arg0 : f16 to f32
    return
  }


  func.func @B_daaeddbd_fptrunc_f32_to_f32(%arg0 : f32) {
    %0 = arith.truncf %arg0 : f32 to f32
    return
  }


  func.func @B_daaeddbd_fptrunc_i32_to_f32(%arg0 : i32) {
    %0 = arith.truncf %arg0 : i32 to f32
    return
  }


  func.func @B_daaeddbd_fptrunc_f32_to_i32(%arg0 : f32) {
    %0 = arith.truncf %arg0 : f32 to i32
    return
  }


  func.func @B_daaeddbd_fptrunc_vec(%arg0 : vector<2xf16>) {
    %0 = arith.truncf %arg0 : vector<2xf16> to vector<3xf32>
    return
  }


  func.func @B_daaeddbd_fptrunc_vec_f16_to_f32(%arg0 : vector<2xf16>) {
    %0 = arith.truncf %arg0 : vector<2xf16> to vector<2xf32>
    return
  }


  func.func @B_daaeddbd_fptrunc_vec_f32_to_f32(%arg0 : vector<2xf32>) {
    %0 = arith.truncf %arg0 : vector<2xf32> to vector<2xf32>
    return
  }


  func.func @B_daaeddbd_fptrunc_vec_i32_to_f32(%arg0 : vector<2xi32>) {
    %0 = arith.truncf %arg0 : vector<2xi32> to vector<2xf32>
    return
  }


  func.func @B_daaeddbd_fptrunc_vec_f32_to_i32(%arg0 : vector<2xf32>) {
    %0 = arith.truncf %arg0 : vector<2xf32> to vector<2xi32>
    return
  }


  func.func @B_daaeddbd_convertf_same_type(%arg0 : f16) {
    %0 = arith.convertf %arg0 : f16 to f16
    return
  }


  func.func @B_daaeddbd_convertf_different_bitwidth(%arg0 : f16) {
    %0 = arith.convertf %arg0 : f16 to f32
    return
  }


  func.func @B_daaeddbd_convertf_different_bitwidth_trunc(%arg0 : f32) {
    %0 = arith.convertf %arg0 : f32 to f16
    return
  }


  func.func @B_daaeddbd_convertf_vec_same_type(%arg0 : vector<2xf16>) {
    %0 = arith.convertf %arg0 : vector<2xf16> to vector<2xf16>
    return
  }


  func.func @B_daaeddbd_convertf_vec_different_bitwidth(%arg0 : vector<2xf16>) {
    %0 = arith.convertf %arg0 : vector<2xf16> to vector<2xf32>
    return
  }


  func.func @B_daaeddbd_convertf_shape_mismatch(%arg0 : vector<2xf16>) {
    %0 = arith.convertf %arg0 : vector<2xf16> to vector<3xbf16>
    return
  }


  func.func @B_daaeddbd_sexti_index_as_operand(%arg0 : index) {
    %0 = arith.extsi %arg0 : index to i128
    return
  }


  func.func @B_daaeddbd_zexti_index_as_operand(%arg0 : index) {
    %0 = arith.extui %arg0 : index to i128
    return
  }


  func.func @B_daaeddbd_trunci_index_as_operand(%arg0 : index) {
    %2 = arith.trunci %arg0 : index to i128
    return
  }


  func.func @B_daaeddbd_sexti_index_as_result(%arg0 : i1) {
    %0 = arith.extsi %arg0 : i1 to index
    return
  }


  func.func @B_daaeddbd_zexti_index_as_operand(%arg0 : i1) {
    %0 = arith.extui %arg0 : i1 to index
    return
  }


  func.func @B_daaeddbd_trunci_index_as_result(%arg0 : i128) {
    %2 = arith.trunci %arg0 : i128 to index
    return
  }


  func.func @B_daaeddbd_sexti_cast_to_narrower(%arg0 : i16) {
    %0 = arith.extsi %arg0 : i16 to i15
    return
  }


  func.func @B_daaeddbd_zexti_cast_to_narrower(%arg0 : i16) {
    %0 = arith.extui %arg0 : i16 to i15
    return
  }


  func.func @B_daaeddbd_trunci_cast_to_wider(%arg0 : i16) {
    %0 = arith.trunci %arg0 : i16 to i17
    return
  }


  func.func @B_daaeddbd_sexti_cast_to_same_width(%arg0 : i16) {
    %0 = arith.extsi %arg0 : i16 to i16
    return
  }


  func.func @B_daaeddbd_zexti_cast_to_same_width(%arg0 : i16) {
    %0 = arith.extui %arg0 : i16 to i16
    return
  }


  func.func @B_daaeddbd_trunci_cast_to_same_width(%arg0 : i16) {
    %0 = arith.trunci %arg0 : i16 to i16
    return
  }


  func.func @B_daaeddbd_trunci_scalable_to_fl(%arg0 : vector<[4]xi32>) {
    %0 = arith.trunci %arg0 : vector<[4]xi32> to vector<4xi8>
    return
  }


  func.func @B_daaeddbd_truncf_scalable_to_fl(%arg0 : vector<[4]xf64>) {
    %0 = arith.truncf %arg0 : vector<[4]xf64> to vector<4xf32>
    return
  }


  func.func @B_daaeddbd_extui_scalable_to_fl(%arg0 : vector<[4]xi32>) {
    %0 = arith.extui %arg0 : vector<[4]xi32> to vector<4xi64>
    return
  }


  func.func @B_daaeddbd_extsi_scalable_to_fl(%arg0 : vector<[4]xi32>) {
    %0 = arith.extsi %arg0 : vector<[4]xi32> to vector<4xi64>
    return
  }


  func.func @B_daaeddbd_extsi_tensor_dim(%arg0 : tensor<4xi32>) {
    %0 = arith.extsi %arg0 : tensor<4xi32> to tensor<?xi64>
    return
  }


  func.func @B_daaeddbd_extf_scalable_to_fl(%arg0 : vector<[4]xf32>) {
    %0 = arith.extf %arg0 : vector<[4]xf32> to vector<4xf64>
    return
  }


  func.func @B_daaeddbd_fptoui_scalable_to_fl(%arg0 : vector<[4]xf64>) {
    %0 = arith.fptoui %arg0 : vector<[4]xf64> to vector<4xi32>
    return
  }


  func.func @B_daaeddbd_fptosi_scalable_to_fl(%arg0 : vector<[4]xf32>) {
    %0 = arith.fptosi %arg0 : vector<[4]xf32> to vector<4xi32>
    return
  }


  func.func @B_daaeddbd_uitofp_scalable_to_fl(%arg0 : vector<[4]xi32>) {
    %0 = arith.uitofp %arg0 : vector<[4]xi32> to vector<4xf32>
    return
  }


  func.func @B_daaeddbd_sitofp_scalable_to_fl(%arg0 : vector<[4]xi32>) {
    %0 = arith.sitofp %arg0 : vector<[4]xi32> to vector<4xf32>
    return
  }


  func.func @B_daaeddbd_bitcast_scalable_to_fl(%arg0 : vector<[4]xf32>) {
    %0 = arith.bitcast %arg0 : vector<[4]xf32> to vector<4xi32>
    return
  }


  func.func @B_daaeddbd_bitcast_tensor_dim(%arg0 : tensor<4xf32>) {
    %0 = arith.bitcast %arg0 : tensor<4xf32> to tensor<?xi32>
    return
  }


  func.func @B_daaeddbd_bitcast_tensor_dim(%arg0 : tensor<?xf32>) {
    %0 = arith.bitcast %arg0 : tensor<?xf32> to tensor<4xi32>
    return
  }


  func.func @B_daaeddbd_trunci_fl_to_scalable(%arg0 : vector<4xi32>) {
    %0 = arith.trunci %arg0 : vector<4xi32> to vector<[4]xi8>
    return
  }


  func.func @B_daaeddbd_truncf_fl_to_scalable(%arg0 : vector<4xf64>) {
    %0 = arith.truncf %arg0 : vector<4xf64> to vector<[4]xf32>
    return
  }


  func.func @B_daaeddbd_truncf_tensor_dim(%arg0 : tensor<4xf64>) {
    %0 = arith.truncf %arg0 : tensor<4xf64> to tensor<?xf32>
    return
  }


  func.func @B_daaeddbd_extui_fl_to_scalable(%arg0 : vector<4xi32>) {
    %0 = arith.extui %arg0 : vector<4xi32> to vector<[4]xi64>
    return
  }


  func.func @B_daaeddbd_extsi_fl_to_scalable(%arg0 : vector<4xi32>) {
    %0 = arith.extsi %arg0 : vector<4xi32> to vector<[4]xi64>
    return
  }


  func.func @B_daaeddbd_extf_fl_to_scalable(%arg0 : vector<4xf32>) {
    %0 = arith.extf %arg0 : vector<4xf32> to vector<[4]xf64>
    return
  }


  func.func @B_daaeddbd_fptoui_fl_to_scalable(%arg0 : vector<4xf64>) {
    %0 = arith.fptoui %arg0 : vector<4xf64> to vector<[4]xi32>
    return
  }


  func.func @B_daaeddbd_fptosi_fl_to_scalable(%arg0 : vector<4xf32>) {
    %0 = arith.fptosi %arg0 : vector<4xf32> to vector<[4]xi32>
    return
  }


  func.func @B_daaeddbd_uitofp_fl_to_scalable(%arg0 : vector<4xi32>) {
    %0 = arith.uitofp %arg0 : vector<4xi32> to vector<[4]xf32>
    return
  }


  func.func @B_daaeddbd_sitofp_fl_to_scalable(%arg0 : vector<4xi32>) {
    %0 = arith.sitofp %arg0 : vector<4xi32> to vector<[4]xf32>
    return
  }


  func.func @B_daaeddbd_bitcast_fl_to_scalable(%arg0 : vector<4xf32>) {
    %0 = arith.bitcast %arg0 : vector<4xf32> to vector<[4]xi32>
    return
  }


  func.func @B_daaeddbd_func() {
    %c0 = arith.constant  // expected-error {{expected attribute value}}

    %x = arith.constant 1 : i32
  }


  func.func @B_daaeddbd_disallow_zero_rank_tensor_with_ranked_tensor(%arg0 : tensor<i1>, %arg1 : tensor<2xi64>, %arg2 : tensor<2xi64>) -> tensor<2xi64> {
    %0 = arith.select %arg0, %arg1, %arg2 : tensor<i1>, tensor<2xi64>
    return %0 : tensor<2xi64>
  }


  func.func @B_daaeddbd_disallow_zero_rank_tensor_with_unranked_tensor(%arg0 : tensor<i1>, %arg1 : tensor<2x?xi64>, %arg2 : tensor<2x?xi64>) -> tensor<2x?xi64> {
    %0 = arith.select %arg0, %arg1, %arg2 : tensor<i1>, tensor<2x?xi64>
    return %0 : tensor<2x?xi64>
  }


  func.func @B_daaeddbd_select_tensor_encoding(
    %arg0 : tensor<8xi1, "bar">, %arg1 : tensor<8xi32, "foo">, %arg2 : tensor<8xi32, "foo">) -> tensor<8xi32, "foo"> {
    %0 = arith.select %arg0, %arg1, %arg2 : tensor<8xi1, "bar">, tensor<8xi32, "foo">
    return %0 : tensor<8xi32, "foo">
  }


  func.func @B_daaeddbd_bitcast_index_0(%arg0 : i64) -> index {
    %0 = arith.bitcast %arg0 : i64 to index
    return %0 : index
  }


  func.func @B_daaeddbd_bitcast_index_1(%arg0 : index) -> i64 {
    %0 = arith.bitcast %arg0 : index to i64
    return %0 : i64
  }


  func.func @B_daaeddbd_select_vector_condition_scalar_operands(%arg0: vector<1xi1>, %arg1: i32) {
    %0 = arith.select %arg0, %arg1, %arg1 : vector<1xi1>, i32
    return
  }


  // Verify that i0 (zero-bitwidth integer) is rejected by arith integer ops.

  func.func @B_daaeddbd_addi_i0(%a: i0, %b: i0) -> i0 {
    %0 = arith.addi %a, %b : i0
    return %0 : i0
  }


  func.func @B_daaeddbd_addi_vector_i0(%a: vector<4xi0>, %b: vector<4xi0>) -> vector<4xi0> {
    %0 = arith.addi %a, %b : vector<4xi0>
    return %0 : vector<4xi0>
  }


  func.func @B_daaeddbd_trunci_to_i0(%a: i32) -> i0 {
    %0 = arith.trunci %a : i32 to i0
    return %0 : i0
  }


  func.func @B_daaeddbd_extsi_from_i0(%a: i0) -> i16 {
    %0 = arith.extsi %a : i0 to i16
    return %0 : i16
  }


  func.func @B_daaeddbd_extui_from_i0(%a: i0) -> i16 {
    %0 = arith.extui %a : i0 to i16
    return %0 : i16
  }


  func.func @B_daaeddbd_cmpi_i0(%a: i0, %b: i0) -> i1 {
    %0 = arith.cmpi eq, %a, %b : i0
    return %0 : i1
  }


  // Arith_TotalIntBinaryOp (andi, ori, xori, maxsi, maxui, minsi, minui,
  // floordivsi, remui, remsi).
  func.func @B_daaeddbd_andi_i0(%a: i0, %b: i0) -> i0 {
    %0 = arith.andi %a, %b : i0
    return %0 : i0
  }


  // Arith_IntBinaryOpWithExactFlag (divsi, divui, shrsi, shrui).
  func.func @B_daaeddbd_divsi_i0(%a: i0, %b: i0) -> i0 {
    %0 = arith.divsi %a, %b : i0
    return %0 : i0
  }


  // Arith_IntBinaryOp (ceildivsi, ceildivui).
  func.func @B_daaeddbd_ceildivsi_i0(%a: i0, %b: i0) -> i0 {
    %0 = arith.ceildivsi %a, %b : i0
    return %0 : i0
  }


  func.func @B_daaeddbd_mulsi_extended_i0(%a: i0, %b: i0) -> (i0, i0) {
    %0:2 = arith.mulsi_extended %a, %b : i0
    return %0#0, %0#1 : i0, i0
  }


  func.func @B_daaeddbd_mului_extended_i0(%a: i0, %b: i0) -> (i0, i0) {
    %0:2 = arith.mului_extended %a, %b : i0
    return %0#0, %0#1 : i0, i0
  }


  // IToFCastOp (sitofp, uitofp) — cast FROM i0.
  func.func @B_daaeddbd_sitofp_i0(%a: i0) -> f32 {
    %0 = arith.sitofp %a : i0 to f32
    return %0 : f32
  }


  // FToICastOp (fptosi, fptoui) — cast TO i0.
  func.func @B_daaeddbd_fptosi_i0(%a: f32) -> i0 {
    %0 = arith.fptosi %a : f32 to i0
    return %0 : i0
  }


  // arith.bitcast rejects i0 source and result.
  func.func @B_daaeddbd_bitcast_i0(%a: i0) -> i0 {
    %0 = arith.bitcast %a : i0 to i0
    return %0 : i0
  }


  // arith.index_cast rejects i0.
  func.func @B_daaeddbd_index_cast_i0(%a: i0) -> index {
    %0 = arith.index_cast %a : i0 to index
    return %0 : index
  }


  // arith.index_castui rejects i0.
  func.func @B_daaeddbd_index_castui_i0(%a: i0) -> index {
    %0 = arith.index_castui %a : i0 to index
    return %0 : index
  }


  func.func @B_daaeddbd_convertf_same_type(%arg0 : f32) {
    %0 = arith.convertf %arg0 : f32 to f32
    return
  }


  func.func @B_daaeddbd_convertf_same_type_vec(%arg0 : vector<2xf16>) {
    %0 = arith.convertf %arg0 : vector<2xf16> to vector<2xf16>
    return
  }


  func.func @B_daaeddbd_convertf_shape_mismatch(%arg0 : vector<2xf16>) {
    %0 = arith.convertf %arg0 : vector<2xf16> to vector<3xf32>
    return
  }


  func.func @B_daaeddbd_convertf_int_input(%arg0 : i32) {
    %0 = arith.convertf %arg0 : i32 to f32
    return
  }


  func.func @B_daaeddbd_convertf_int_output(%arg0 : f32) {
    %0 = arith.convertf %arg0 : f32 to i32
    return
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
