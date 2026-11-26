// FUSED MLIR (FFL)  A: e855836e  B: 5e5f3d8d  bridge: rename
#A_e855836e_H_c057525a_s2_SortedCOO = #sparse_tensor.encoding<{
  map = (d0, d1) -> (d0 : compressed(nonunique), d1 : singleton)
}>
#A_e855836e_H_c057525a_s2_SortedCOOI32 = #sparse_tensor.encoding<{
  map = (d0, d1) -> (d0 : compressed(nonunique), d1 : singleton),
  posWidth = 32,
  crdWidth = 32
}>
#A_e855836e_H_c057525a_s2_CSR = #sparse_tensor.encoding<{
  map = (d0, d1) -> (d0 : dense, d1 : compressed),
  posWidth = 32,
  crdWidth = 32
}>
#A_e855836e_H_c057525a_s2_BCOO = #sparse_tensor.encoding<{
  map = (d0, d1, d2) -> (d0 : dense, d1 : loose_compressed(nonunique), d2 : singleton)
}>

module {
  // ===== Seed A =====
  //
    // Main driver.
    //
    func.func @A_e855836e_H_c057525a_s2_main() {
      %c0 = arith.constant 0 : index
      %f0 = arith.constant 0.0 : f64
      %i0 = arith.constant 0 : i32

      //
      // Setup COO.
      //

      %data = arith.constant dense<
         [ 1.0,  2.0,  3.0 ]
      > : tensor<3xf64>

      %pos = arith.constant dense<
         [0, 3]
      > : tensor<2xindex>

      %index = arith.constant dense<
         [[  1,  2],
          [  5,  6],
          [  7,  8]]
      > : tensor<3x2xindex>

      %pos32 = arith.constant dense<
         [0, 3]
      > : tensor<2xi32>

      %index32 = arith.constant dense<
         [[  1,  2],
          [  5,  6],
          [  7,  8]]
      > : tensor<3x2xi32>

      %s4 = sparse_tensor.assemble (%pos, %index), %data : (tensor<2xindex>, tensor<3x2xindex>), tensor<3xf64>
                                            to tensor<10x10xf64, #A_e855836e_H_c057525a_s2_SortedCOO>
      %s5 = sparse_tensor.assemble (%pos32, %index32), %data : (tensor<2xi32>, tensor<3x2xi32>), tensor<3xf64>
                                            to tensor<10x10xf64, #A_e855836e_H_c057525a_s2_SortedCOOI32>

      //
      // Setup CSR.
      //

      %csr_data = arith.constant dense<
         [ 1.0,  2.0,  3.0 ]
      > : tensor<3xf64>

      %csr_pos32 = arith.constant dense<
         [0, 1, 3]
      > : tensor<3xi32>

      %csr_index32 = arith.constant dense<
         [1, 0, 1]
      > : tensor<3xi32>
      %csr = sparse_tensor.assemble (%csr_pos32, %csr_index32), %csr_data : (tensor<3xi32>, tensor<3xi32>), tensor<3xf64>
                                             to tensor<2x2xf64, #A_e855836e_H_c057525a_s2_CSR>

      //
      // Setup BCOO.
      //

      %bdata = arith.constant dense<
         [ 1.0,  2.0,  3.0,  4.0,  5.0 ]
      > : tensor<5xf64>

      %bpos = arith.constant dense<
         [0, 3, 3, 5]
      > : tensor<4xindex>

      %bindex = arith.constant dense<
        [[  1,  2],
         [  5,  6],
         [  7,  8],
         [  2,  3],
         [  4,  2],
         [ 10, 10]]
      > : tensor<6x2xindex>

      %bs = sparse_tensor.assemble (%bpos, %bindex), %bdata :
            (tensor<4xindex>,  tensor<6x2xindex>), tensor<5xf64> to tensor<2x10x10xf64, #A_e855836e_H_c057525a_s2_BCOO>

      //
      // Verify results.
      //

      //
      //
      sparse_tensor.foreach in %s4 : tensor<10x10xf64, #A_e855836e_H_c057525a_s2_SortedCOO> do {
        ^bb0(%1: index, %2: index, %v: f64) :
          vector.print %1: index
          vector.print %2: index
          vector.print %v: f64
          spirv.Return
      }

      //
      //
      sparse_tensor.foreach in %s5 : tensor<10x10xf64, #A_e855836e_H_c057525a_s2_SortedCOOI32> do {
        ^bb0(%1: index, %2: index, %v: f64) :
          vector.print %1: index
          vector.print %2: index
          vector.print %v: f64
      }

      //
      //
      sparse_tensor.foreach in %csr : tensor<2x2xf64, #A_e855836e_H_c057525a_s2_CSR> do {
        ^bb0(%1: index, %2: index, %v: f64) :
          vector.print %1: index
          vector.print %2: index
          vector.print %v: f64
      }

      //
      //
      //
      //
      sparse_tensor.foreach in %bs : tensor<2x10x10xf64, #A_e855836e_H_c057525a_s2_BCOO> do {
        ^bb0(%0: index, %1: index, %2: index, %v: f64) :
          vector.print %0: index
          vector.print %1: index
          vector.print %2: index
          vector.print %v: f64
      }

      //
      // Verify disassemble operations.
      //

      %od = tensor.empty() : tensor<3xf64>
      %op = tensor.empty() : tensor<2xi32>
      %oi = tensor.empty() : tensor<3x2xi32>
      %p, %i, %d, %pl, %il, %dl = sparse_tensor.disassemble %s5 : tensor<10x10xf64, #A_e855836e_H_c057525a_s2_SortedCOOI32>
                   out_lvls(%op, %oi : tensor<2xi32>, tensor<3x2xi32>)
                   out_vals(%od : tensor<3xf64>)
                   -> (tensor<2xi32>, tensor<3x2xi32>), tensor<3xf64>, (i32, i64), index

      %vd = vector.transfer_read %d[%c0], %f0 : tensor<3xf64>, vector<3xf64>
      vector.print %vd : vector<3xf64>

      %vi = vector.transfer_read %i[%c0, %c0], %i0 : tensor<3x2xi32>, vector<3x2xi32>
      vector.print %vi : vector<3x2xi32>

      vector.print %dl : index

      %d_csr = tensor.empty() : tensor<4xf64>
      %p_csr = tensor.empty() : tensor<3xi32>
      %i_csr = tensor.empty() : tensor<3xi32>
      %rp_csr, %ri_csr, %rd_csr, %lp_csr, %li_csr, %ld_csr = sparse_tensor.disassemble %csr : tensor<2x2xf64, #A_e855836e_H_c057525a_s2_CSR>
                   out_lvls(%p_csr, %i_csr : tensor<3xi32>, tensor<3xi32>)
                   out_vals(%d_csr : tensor<4xf64>)
                   -> (tensor<3xi32>, tensor<3xi32>), tensor<4xf64>, (i32, i64), index

      %vd_csr = vector.transfer_read %rd_csr[%c0], %f0 : tensor<4xf64>, vector<3xf64>
      vector.print %vd_csr : vector<3xf64>

      vector.print %ld_csr : index

      %bod = tensor.empty() : tensor<6xf64>
      %bop = tensor.empty() : tensor<4xindex>
      %boi = tensor.empty() : tensor<6x2xindex>
      %bp, %bi, %bd, %lp, %li, %ld = sparse_tensor.disassemble %bs : tensor<2x10x10xf64, #A_e855836e_H_c057525a_s2_BCOO>
                      out_lvls(%bop, %boi : tensor<4xindex>, tensor<6x2xindex>)
                      out_vals(%bod : tensor<6xf64>)
                      -> (tensor<4xindex>, tensor<6x2xindex>), tensor<6xf64>, (i32, tensor<i64>), index

      %vbd = vector.transfer_read %bd[%c0], %f0 : tensor<6xf64>, vector<5xf64>
      vector.print %vbd : vector<5xf64>

      vector.print %ld : index

      %vbi = vector.transfer_read %bi[%c0, %c0], %c0 : tensor<6x2xindex>, vector<6x2xindex>
      vector.print %vbi : vector<6x2xindex>

      %si = tensor.extract %li[] : tensor<i64>
      vector.print %si : i64

      // TODO: This check is no longer needed once the codegen path uses the
      // buffer deallocation pass. "dealloc_tensor" turn into a no-op in the
      // codegen path.
      %has_runtime = sparse_tensor.has_runtime_library
      scf.if %has_runtime {
        // sparse_tensor.assemble copies buffers when running with the runtime
        // library. Deallocations are not needed when running in codegen mode.
        bufferization.dealloc_tensor %s4 : tensor<10x10xf64, #A_e855836e_H_c057525a_s2_SortedCOO>
        bufferization.dealloc_tensor %s5 : tensor<10x10xf64, #A_e855836e_H_c057525a_s2_SortedCOOI32>
        bufferization.dealloc_tensor %csr : tensor<2x2xf64, #A_e855836e_H_c057525a_s2_CSR>
        bufferization.dealloc_tensor %bs : tensor<2x10x10xf64, #A_e855836e_H_c057525a_s2_BCOO>
      }

      bufferization.dealloc_tensor %li : tensor<i64>
      bufferization.dealloc_tensor %od : tensor<3xf64>
      bufferization.dealloc_tensor %op : tensor<2xi32>
      bufferization.dealloc_tensor %oi : tensor<3x2xi32>
      bufferization.dealloc_tensor %d_csr : tensor<4xf64>
      bufferization.dealloc_tensor %p_csr : tensor<3xi32>
      bufferization.dealloc_tensor %i_csr : tensor<3xi32>
      bufferization.dealloc_tensor %bod : tensor<6xf64>
      bufferization.dealloc_tensor %bop : tensor<4xindex>
      bufferization.dealloc_tensor %boi : tensor<6x2xindex>

      return
    }

  // ===== Seed B =====
  spirv.module Logical GLSL450 requires #spirv.vce<v1.3, [Shader, GroupNonUniformArithmetic], [SPV_KHR_non_semantic_info, SPV_KHR_storage_buffer_storage_class]> attributes {spirv.target_env = #spirv.target_env<#spirv.vce<v1.3, [Shader, GroupNonUniformArithmetic], [SPV_KHR_non_semantic_info, SPV_KHR_storage_buffer_storage_class]>, #spirv.resource_limits<>>} {
    spirv.GlobalVariable @var0 bind(0, 1) : !spirv.ptr<f32, Input>
    spirv.func @B_5e5f3d8d_arithmetic(%arg0 : vector<4xf32>, %arg1 : vector<4xf32>) "None" {
      %0 = spirv.FAdd %arg0, %arg1 : vector<4xf32>
      %1 = spirv.FNegate %arg0 : vector<4xf32>
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_atomic(%ptr: !spirv.ptr<i32, Workgroup>, %value: i32, %comparator: i32) "None" {
      %1 = spirv.AtomicAnd <Device> <None> %ptr, %value : !spirv.ptr<i32, Workgroup>
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_bitwiser(%arg0 : i32, %arg1 : i32) "None" {
      %0 = spirv.BitwiseAnd %arg0, %arg1 : i32
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_convert(%arg0 : f32) "None" {
      %0 = spirv.ConvertFToU %arg0 : f32 to i32
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_composite(%arg0 : !spirv.struct<(f32, !spirv.struct<(!spirv.array<4xf32>, f32)>)>, %arg1: !spirv.array<4xf32>, %arg2 : f32, %arg3 : f32) "None" {
      %0 = spirv.CompositeInsert %arg1, %arg0[1 : i32, 0 : i32] : !spirv.array<4xf32> into !spirv.struct<(f32, !spirv.struct<(!spirv.array<4xf32>, f32)>)>
      %1 = spirv.CompositeConstruct %arg2, %arg3 : (f32, f32) -> vector<2xf32>
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_group_non_uniform(%val: f32) "None" {
      %0 = spirv.GroupNonUniformFAdd <Subgroup> <Reduce> %val : f32 -> f32
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_local_var() "None" {
      %zero = spirv.Constant 0: i32
      %var = spirv.Variable init(%zero) : !spirv.ptr<i32, Function>
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_logical(%arg0: i32, %arg1: i32) "None" {
      %0 = spirv.IEqual %arg0, %arg1 : i32
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_memory_accesses(%arg0 : !spirv.ptr<!spirv.array<4x!spirv.array<4xf32>>, StorageBuffer>, %arg1 : i32, %arg2 : i32) "None" {
      %2 = spirv.AccessChain %arg0[%arg1, %arg2] : !spirv.ptr<!spirv.array<4x!spirv.array<4xf32>>, StorageBuffer>, i32, i32 -> !spirv.ptr<f32, StorageBuffer>
      %3 = spirv.Load "StorageBuffer" %2 : f32
      spirv.Store "StorageBuffer" %2, %3 : f32
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_loop(%count : i32) -> () "None" {
      %zero = spirv.Constant 0: i32
      %one = spirv.Constant 1: i32
      %ivar = spirv.Variable init(%zero) : !spirv.ptr<i32, Function>
      %jvar = spirv.Variable init(%zero) : !spirv.ptr<i32, Function>
      spirv.mlir.loop {
        spirv.Branch ^header
      ^header:
        %ival0 = spirv.Load "Function" %ivar : i32
        %icmp = spirv.SLessThan %ival0, %count : i32
        spirv.BranchConditional %icmp, ^body, ^merge
      ^body:
        spirv.Store "Function" %jvar, %zero : i32
        spirv.mlir.loop {
          spirv.Branch ^header
        ^header:
          %jval0 = spirv.Load "Function" %jvar : i32
          %jcmp = spirv.SLessThan %jval0, %count : i32
          spirv.BranchConditional %jcmp, ^body, ^merge
        ^body:
          spirv.Branch ^continue
        ^continue:
          %jval1 = spirv.Load "Function" %jvar : i32
          %add = spirv.IAdd %jval1, %one : i32
          spirv.Store "Function" %jvar, %add : i32
          spirv.Branch ^header
        ^merge:
          spirv.mlir.merge
        }
        spirv.Branch ^continue
      ^continue:
        %ival1 = spirv.Load "Function" %ivar : i32
        %add = spirv.IAdd %ival1, %one : i32
        spirv.Store "Function" %ivar, %add : i32
        spirv.Branch ^header
      ^merge:
        spirv.mlir.merge
      }
      spirv.Return
    }

    spirv.func @B_5e5f3d8d_selection(%cond: i1) -> () "None" {
      %zero = spirv.Constant 0: i32
      %one = spirv.Constant 1: i32
      %two = spirv.Constant 2: i32
      %var = spirv.Variable init(%zero) : !spirv.ptr<i32, Function>
      spirv.mlir.selection {
        spirv.BranchConditional %cond [5, 10], ^then, ^else
      ^then:
        spirv.Store "Function" %var, %one : i32
        spirv.Branch ^merge
      ^else:
        spirv.Store "Function" %var, %two : i32
        spirv.Branch ^merge
      ^merge:
        spirv.mlir.merge
      }
      spirv.Return
    }

    spirv.EntryPoint "GLCompute" @B_5e5f3d8d_local_var
  }


  // P5: Float conversion & NaN/Inf constant folding
  func.func @_ffl_p5_float() -> f64 {
    %imin = arith.constant -2147483648 : i32    // INT_MIN
    %f32  = arith.sitofp %imin : i32 to f32
    %f64  = arith.extf %f32 : f32 to f64
    // 0.0 / 0.0 produces NaN — constant folder must not crash
    %zero = arith.constant 0.0 : f64
    %nan  = arith.divf %zero, %zero : f64
    // minimumf with NaN: result must be NaN per IEEE 754-2019
    %r    = arith.minimumf %f64, %nan : f64
    // extf then truncf roundtrip: must be idempotent for finite values
    %back = arith.truncf %r : f64 to f32
    %out  = arith.extf %back : f32 to f64
    return %out : f64
  }
}
