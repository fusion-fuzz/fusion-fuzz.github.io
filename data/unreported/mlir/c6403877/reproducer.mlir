module {
shard.grid @grid0(shape = 3x4x5)
func.func @H_7f36fa3b_s1_process_multi_index() -> (index, index, index) {
  %0:3 = shard.process_multi_index on @grid0 axes = [] : index, index, index
  return %0#0, %0#1, %0#2 : index, index, index
}

func.func @H_7f36fa3b_s1_process_multi_index_reorder() -> (index, index) {
  %0:2 = shard.process_multi_index on @grid0 axes = [2, 0] : index, index
  return %0#0, %0#1 : index, index
}

func.func @H_7f36fa3b_s1_process_linear_index() -> index {
  %0 = shard.process_linear_index on @grid0 : index
  return %0 : index
}

func.func @H_7f36fa3b_s1_neighbors_dim0(%arg0 : tensor<120x120x120xi8>) -> (index, index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c4 = arith.constant 4 : index
  %idx:2 = shard.neighbors_linear_indices on @grid0[%c1, %c0, %c4] split_axes = [0] : index, index
  return %idx#0, %idx#1 : index, index
}

func.func @H_7f36fa3b_s1_neighbors_dim1(%arg0 : tensor<120x120x120xi8>) -> (index, index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c4 = arith.constant 4 : index
  %idx:2 = shard.neighbors_linear_indices on @grid0[%c1, %c0, %c4] split_axes = [1] : index, index
  return %idx#0, %idx#1 : index, index
}

func.func @H_7f36fa3b_s1_neighbors_dim2(%arg0 : tensor<120x120x120xi8>) -> (index, index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c4 = arith.constant 4 : index
  %idx:2 = shard.neighbors_linear_indices on @grid0[%c1, %c0, %c4] split_axes = [2] : index, index
  return %idx#0, %idx#1 : index, index
}


module attributes { mpi.dlti = #dlti.map<"MPI:comm_world_rank" = 24> } {
  shard.grid @grid0(shape = 3x4x5)
  func.func @H_7f36fa3b_s2_process_multi_index() -> (index, index, index) {
    %0:3 = shard.process_multi_index on @grid0 axes = [] : index, index, index
    return %0#0, %0#1, %0#2 : index, index, index
  }

  func.func @H_7f36fa3b_s2_process_linear_index() -> index {
    %0 = shard.process_linear_index on @grid0 : index
    return %0 : index
  }
}


module {
  shard.grid @grid0(shape = 3x4x5)
  func.func @H_7f36fa3b_s3_all_slice(%arg0 : tensor<3x5xf32>) -> tensor<3x1xf32> {
    %1 = shard.all_slice %arg0 on @grid0 grid_axes = [2] slice_axis = 1 : tensor<3x5xf32> -> tensor<3x1xf32>
    return %1 : tensor<3x1xf32>
  }
}


module attributes { mpi.dlti = #dlti.map<"MPI:comm_world_rank" = 7> } {
  shard.grid @grid0(shape = 3x4x5)
  func.func @H_7f36fa3b_s4_allreduce_tensor(
    %arg0 : tensor<3x4xf32>) -> tensor<3x4xf32> {
    %0 = shard.all_reduce %arg0 on @grid0 grid_axes = [0, 1] reduction = max : tensor<3x4xf32> -> tensor<3x4xf32>
    return %0 : tensor<3x4xf32>
  }

  func.func @H_7f36fa3b_s4_allreduce_memref(
    %arg0 : memref<3x4xf32>) -> memref<3x4xf32> {
    %0 = shard.all_reduce %arg0 on @grid0 grid_axes = [0, 1] reduction = max : memref<3x4xf32> -> memref<3x4xf32>
    return %0 : memref<3x4xf32>
  }

  func.func @H_7f36fa3b_s4_allreduce_new_type(
    %arg0 : memref<3x4xf32>) -> memref<3x4xf64> {
    %0 = shard.all_reduce %arg0 on @grid0 grid_axes = [0, 1] reduction = max : memref<3x4xf32> -> memref<3x4xf64>
    return %0 : memref<3x4xf64>
  }

  func.func @H_7f36fa3b_s4_reduce_scatter_memref(
    %arg0 : memref<3x4xf32>) -> memref<1x4xf32> {
    %0 = shard.reduce_scatter %arg0 on @grid0 grid_axes = [0] scatter_dim = 0 : memref<3x4xf32> -> memref<1x4xf32>
    return %0 : memref<1x4xf32>
  }

  func.func @H_7f36fa3b_s4_reduce_scatter_tensor_dim1(
    %arg0 : tensor<2x12xf32>) -> tensor<2x4xf32> {
    %0 = shard.reduce_scatter %arg0 on @grid0 grid_axes = [0] scatter_dim = 1 : tensor<2x12xf32> -> tensor<2x4xf32>
    return %0 : tensor<2x4xf32>
  }

  func.func @H_7f36fa3b_s4_allgather_tensor_0(%arg0 : tensor<3x4xf32>) -> tensor<12x4xf32> {
    %0 = shard.all_gather %arg0 on @grid0 grid_axes = [1] gather_axis = 0 : tensor<3x4xf32> -> tensor<12x4xf32>
    return %0 : tensor<12x4xf32>
  }

  func.func @H_7f36fa3b_s4_allgather_tensor(
      %arg0 : tensor<3x4xf32>) -> tensor<3x20xf32> {
    %0 = shard.all_gather %arg0 on @grid0 grid_axes = [2] gather_axis = 1 : tensor<3x4xf32> -> tensor<3x20xf32>
    return %0 : tensor<3x20xf32>
  }

  func.func @H_7f36fa3b_s4_allgather_memref(
      %arg0 : memref<3x4xf32>) -> memref<3x20xf32> {
    %0 = shard.all_gather %arg0 on @grid0 grid_axes = [2] gather_axis = 1 : memref<3x4xf32> -> memref<3x20xf32>
    return %0 : memref<3x20xf32>
  }
}


shard.grid @grid0(shape = 3x4x5)
func.func @H_7f36fa3b_s5_update_halo_1d_first(
  %arg0 : memref<120x120x120xi8>) -> memref<120x120x120xi8> {
  %res = shard.update_halo %arg0 on @grid0 split_axes = [[0]] halo_sizes = [2, 3] : memref<120x120x120xi8>
  return %res : memref<120x120x120xi8>
}


module attributes { mpi.dlti = #dlti.map<"MPI:comm_world_rank" = 1> } {
  shard.grid @grid0(shape = 4)
  func.func @H_7f36fa3b_s6_update_halo_1d_with_zero (
    %arg0 : memref<120x120x120xi8>) -> memref<120x120x120xi8> {
    %res = shard.update_halo %arg0 on @grid0 split_axes = [[0]] halo_sizes = [2, 0] : memref<120x120x120xi8>
    %d3f24de82_sharding = shard.sharding @grid0 split_axes = [[0, 1], [2]] sharded_dims_offsets = [0, 3, 5, 7, 8, 0, 0, 5, 10, 16] : !shard.sharding
    return %res : memref<120x120x120xi8>
  }
}


module attributes { mpi.dlti = #dlti.map<"MPI:comm_world_rank" = 24> } {
  shard.grid @grid0(shape = 3x4x5)
  func.func @H_7f36fa3b_s7_update_halo_3d(
    %arg0 : memref<120x120x120xi8>) -> memref<120x120x120xi8> {
    %res = shard.update_halo %arg0 on @grid0 split_axes = [[2], [1], [0]] halo_sizes = [1, 2, 3, 4, 5, 6] : memref<120x120x120xi8>
    return %res : memref<120x120x120xi8>
  }

  func.func @H_7f36fa3b_s7_update_halo_3d_tensor(
    %arg0 : tensor<120x120x120xi8>) -> tensor<120x120x120xi8> {
    %res = shard.update_halo %arg0 on @grid0 split_axes = [[2], [1], [0]] halo_sizes = [1, 2, 3, 4, 5, 6] : tensor<120x120x120xi8>
    return %res : tensor<120x120x120xi8>
  }
}


shard.grid @grid0(shape = 2x2x4)
func.func @H_7f36fa3b_s8_return_sharding(%arg0: tensor<2x4xf32>) -> (tensor<2x4xf32>, !shard.sharding) {
  %sharding = shard.sharding @grid0 split_axes = [[0, 1], [2]] : !shard.sharding
  return %arg0, %sharding : tensor<2x4xf32>, !shard.sharding
}

func.func @H_7f36fa3b_s8_return_sharding_halos(%arg0: tensor<6x8xf32>) -> (tensor<6x8xf32>, !shard.sharding) {
  %sharding = shard.sharding @grid0 split_axes = [[0, 1], [2]] halo_sizes = [0, 4, 3, 1] : !shard.sharding
  return %arg0, %sharding : tensor<6x8xf32>, !shard.sharding
}

func.func @H_7f36fa3b_s8_return_sharding_offs(%arg0: tensor<?x?xf32>) -> (tensor<?x?xf32>, !shard.sharding) {
  %sharding = shard.sharding @grid0 split_axes = [[0, 1], [2]] sharded_dims_offsets = [0, 3, 5, 7, 8, 0, 0, 5, 10, 16] : !shard.sharding
  return %arg0, %sharding : tensor<?x?xf32>, !shard.sharding
}


shard.grid @grid_1d_4(shape = 4)
func.func @H_7f36fa3b_s9_mlp_1dgrid(%arg0: tensor<512x512xf32>, %arg1: tensor<2048x256xf32>, %arg2: tensor<256x2048xf32>) -> tensor<512x2048xf32> attributes {llvm.emit_c_interface} {
  %cst = arith.constant 0.000000e+00 : f32
  %c0 = arith.constant 0 : index
  %all_gather = shard.all_gather %arg0 on @grid_1d_4 grid_axes = [0] gather_axis = 1 : tensor<512x512xf32> -> tensor<512x2048xf32>
  %0 = tensor.empty() : tensor<512x256xf32>
  %1 = linalg.fill ins(%cst : f32) outs(%0 : tensor<512x256xf32>) -> tensor<512x256xf32>
  %2 = linalg.matmul ins(%all_gather, %arg1 : tensor<512x2048xf32>, tensor<2048x256xf32>) outs(%1 : tensor<512x256xf32>) -> tensor<512x256xf32>
  %3 = tosa.sigmoid %2 : (tensor<512x256xf32>) -> tensor<512x256xf32>
  %4 = tensor.empty() : tensor<512x2048xf32>
  %5 = linalg.fill ins(%cst : f32) outs(%4 : tensor<512x2048xf32>) -> tensor<512x2048xf32>
  %proc_linear_idx = shard.process_multi_index on @grid_1d_4 axes = [0] : index
  %grid_shape = shard.grid_shape @grid_1d_4 axes = [0] : index
  %6 = arith.cmpi eq, %proc_linear_idx, %c0 : index
  %7 = scf.if %6 -> (tensor<512x2048xf32>) {
    scf.yield %5 : tensor<512x2048xf32>
  } else {
    %9 = tensor.empty() : tensor<512x2048xf32>
    %10 = linalg.fill ins(%cst : f32) outs(%9 : tensor<512x2048xf32>) -> tensor<512x2048xf32>
    scf.yield %10 : tensor<512x2048xf32>
  }
  %8 = linalg.matmul ins(%3, %arg2 : tensor<512x256xf32>, tensor<256x2048xf32>) outs(%7 : tensor<512x2048xf32>) -> tensor<512x2048xf32>
  %all_reduce = shard.all_reduce %8 on @grid_1d_4 grid_axes = [0] : tensor<512x2048xf32> -> tensor<512x2048xf32>
  return %all_reduce : tensor<512x2048xf32>
}
}
