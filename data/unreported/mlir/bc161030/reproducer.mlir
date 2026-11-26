#H_4f391162_B_e96f562a_SparseVector = #sparse_tensor.encoding<{map = (d0) -> (d0 : compressed)}>
#H_4f391162_B_e96f562a_COO = #sparse_tensor.encoding<{map = (d0, d1) -> (d0 : compressed(nonunique), d1 : singleton)}>
#H_4f391162_B_e96f562a_BSR = #sparse_tensor.encoding<{
  map = ( i, j ) ->
  ( i floordiv 2 : dense,
    j floordiv 3 : compressed,
    i mod 2      : dense,
    j mod 3      : dense
  )
}>
#H_4f391162_B_e96f562a_DSDD = #sparse_tensor.encoding<{
  map = (i, j, k, l) -> (i: dense, j: compressed, k: dense, l: dense)
}>
#D_e96f562a_SparseVector = #sparse_tensor.encoding<{map = (d0) -> (d0 : compressed)}>
#D_e96f562a_COO = #sparse_tensor.encoding<{map = (d0, d1) -> (d0 : compressed(nonunique), d1 : singleton)}>
#D_e96f562a_BSR = #sparse_tensor.encoding<{
  map = ( i, j ) ->
  ( i floordiv 2 : dense,
    j floordiv 3 : compressed,
    i mod 2      : dense,
    j mod 3      : dense
  )
}>
#D_e96f562a_DSDD = #sparse_tensor.encoding<{
  map = (i, j, k, l) -> (i: dense, j: compressed, k: dense, l: dense)
}>
module {
// ===== Seed A =====
  func.func @H_4f391162_A_29752695_fmaf(%x: f32, %y: f32, %z: f32) -> f32 {
      %0 = arith.mulf %x, %y : f32
      %1 = arith.addf %0, %z : f32
      return %1 : f32
    }

    func.func @H_4f391162_A_29752695_bar() -> i32 {
      %0 = arith.constant 0 : i32
      return %0 : i32
    }

    func.func @H_4f391162_A_29752695_vfma32(%x: f32, %y: f32, %z: f32) -> f32 {
      %0 = call @H_4f391162_A_29752695_fmaf(%x, %y, %z) : (f32, f32, f32) -> f32
      return %0 : f32
    }

    func.func @H_4f391162_A_29752695_restored() -> i32 {
      %0 = call @H_4f391162_A_29752695_bar() : () -> i32
      return %0 : i32
    }

    func.func @H_4f391162_A_29752695_main() {
      %a = arith.constant 1.0 : f32
      %b = arith.constant 2.0 : f32
      %c = arith.constant 3.0 : f32
      %d = call @H_4f391162_A_29752695_vfma32(%a, %b, %c) : (f32, f32, f32) -> f32
      %e = call @H_4f391162_A_29752695_restored() : () -> i32
      %f = arith.extf %d : f32 to f64
      %g = arith.sitofp %e : i32 to f64
      %h = arith.addf %f, %g : f64
      return
    }

  // ===== Seed B =====
  func.func @H_4f391162_B_e96f562a_sparse_nop_dense2dense_convert(%arg0: tensor<64xf32>) -> tensor<64xf32> {
    %0 = sparse_tensor.convert %arg0 : tensor<64xf32> to tensor<64xf32>
    return %0 : tensor<64xf32>
  }

  func.func @H_4f391162_B_e96f562a_sparse_dce_convert(%arg0: tensor<64xf32>) {
    %0 = sparse_tensor.convert %arg0 : tensor<64xf32> to tensor<64xf32, #H_4f391162_B_e96f562a_SparseVector>
    return
  }

  func.func @H_4f391162_B_e96f562a_sparse_dce_getters(%arg0: tensor<64xf32, #H_4f391162_B_e96f562a_SparseVector>) {
    %0 = sparse_tensor.positions %arg0 level = 0 : tensor<64xf32, #H_4f391162_B_e96f562a_SparseVector> to memref<?xindex>
    %1 = sparse_tensor.coordinates %arg0 level = 0 : tensor<64xf32, #H_4f391162_B_e96f562a_SparseVector> to memref<?xindex>
    %2 = sparse_tensor.values %arg0 : tensor<64xf32, #H_4f391162_B_e96f562a_SparseVector> to memref<?xf32>
    return
  }

  func.func @H_4f391162_B_e96f562a_sparse_concat_dce(%arg0: tensor<2xf64, #H_4f391162_B_e96f562a_SparseVector>,
                               %arg1: tensor<3xf64, #H_4f391162_B_e96f562a_SparseVector>,
                               %arg2: tensor<4xf64, #H_4f391162_B_e96f562a_SparseVector>) {
    %0 = sparse_tensor.concatenate %arg0, %arg1, %arg2 dimension = 0
         : tensor<2xf64, #H_4f391162_B_e96f562a_SparseVector>,
           tensor<3xf64, #H_4f391162_B_e96f562a_SparseVector>,
           tensor<4xf64, #H_4f391162_B_e96f562a_SparseVector> to tensor<9xf64, #H_4f391162_B_e96f562a_SparseVector>
    return
  }

  func.func @H_4f391162_B_e96f562a_sparse_get_specifier_dce_fold(%arg0: !sparse_tensor.storage_specifier<#H_4f391162_B_e96f562a_SparseVector>, %arg1: index, %arg2: index) -> index {
    %0 = sparse_tensor.storage_specifier.set %arg0 lvl_sz at 0 with %arg1
         : !sparse_tensor.storage_specifier<#H_4f391162_B_e96f562a_SparseVector>
    %1 = sparse_tensor.storage_specifier.set %0 pos_mem_sz at 0 with %arg2
         : !sparse_tensor.storage_specifier<#H_4f391162_B_e96f562a_SparseVector>
    %2 = sparse_tensor.storage_specifier.get %1 lvl_sz at 0
         : !sparse_tensor.storage_specifier<#H_4f391162_B_e96f562a_SparseVector>
    return %2 : index
  }




  func.func @H_4f391162_B_e96f562a_sparse_reorder_coo(%arg0 : tensor<?x?xf32, #H_4f391162_B_e96f562a_COO>) -> tensor<?x?xf32, #H_4f391162_B_e96f562a_COO> {
    %ret = sparse_tensor.reorder_coo quick_sort %arg0 : tensor<?x?xf32, #H_4f391162_B_e96f562a_COO> to tensor<?x?xf32, #H_4f391162_B_e96f562a_COO>
    return %ret : tensor<?x?xf32, #H_4f391162_B_e96f562a_COO>
  }



  func.func @H_4f391162_B_e96f562a_sparse_crd_translate(%arg0: index, %arg1: index) -> (index, index) {
    %l0, %l1, %l2, %l3 = sparse_tensor.crd_translate dim_to_lvl [%arg0, %arg1] as #H_4f391162_B_e96f562a_BSR : index, index, index, index
    %d0, %d1 = sparse_tensor.crd_translate lvl_to_dim [%l0, %l1, %l2, %l3] as #H_4f391162_B_e96f562a_BSR : index, index
    return  %d0, %d1 : index, index
  }

  func.func @H_4f391162_B_e96f562a_sparse_lvl_0(%t : tensor<10x?xi32, #H_4f391162_B_e96f562a_BSR>) -> index {
    %lvl = arith.constant 0 : index
    %l0 = sparse_tensor.lvl %t, %lvl : tensor<10x?xi32, #H_4f391162_B_e96f562a_BSR>
    return  %l0 : index
  }

  func.func @H_4f391162_B_e96f562a_sparse_lvl_3(%t : tensor<?x?xi32, #H_4f391162_B_e96f562a_BSR>) -> index {
    %lvl = arith.constant 3 : index
    %l0 = sparse_tensor.lvl %t, %lvl : tensor<?x?xi32, #H_4f391162_B_e96f562a_BSR>
    return  %l0 : index
  }



  func.func @H_4f391162_B_e96f562a_sparse_reinterpret_map(%t0 : tensor<6x12xi32, #H_4f391162_B_e96f562a_BSR>) -> tensor<6x12xi32, #H_4f391162_B_e96f562a_BSR> {
    %t1 = sparse_tensor.reinterpret_map %t0 : tensor<6x12xi32, #H_4f391162_B_e96f562a_BSR>
                                           to tensor<3x4x2x3xi32, #H_4f391162_B_e96f562a_DSDD>
    %t2 = sparse_tensor.reinterpret_map %t1 : tensor<3x4x2x3xi32, #H_4f391162_B_e96f562a_DSDD>
                                           to tensor<6x12xi32, #H_4f391162_B_e96f562a_BSR>
    return %t2 : tensor<6x12xi32, #H_4f391162_B_e96f562a_BSR>
  }


  // P2: scf.for with iter_args nested inside scf.if — dominance stress
  func.func @H_4f391162__ffl_p2_scf_nested() -> i64 {
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
        %de96f562a_t = ub.poison : tensor<?x?xi32, #D_e96f562a_BSR>
        %de96f562a_lvl = arith.constant 3 : index
        %de96f562a_l0 = sparse_tensor.lvl %de96f562a_t, %de96f562a_lvl : tensor<?x?xi32, #D_e96f562a_BSR>
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
