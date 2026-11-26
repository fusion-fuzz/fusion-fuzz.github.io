#map = affine_map<(d0)[s0, s1] -> (s1, -d0 + s0)>
#map1 = affine_map<(d0, d1, d2) -> (d0, d1, d2)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
#map4 = affine_map<(d0, d1) -> (d0)>
module {
  func.func @B_multi_slice_fusion_with_broadcast(%arg0: tensor<?x?x?xf32>, %arg1: tensor<?x?xf32>, %arg2: tensor<?xf32>, %arg3: index, %arg4: index) -> tensor<?x?xf32> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %dim = tensor.dim %arg0, %c0 : tensor<?x?x?xf32>
    %dim_0 = tensor.dim %arg0, %c1 : tensor<?x?x?xf32>
    %dim_1 = tensor.dim %arg0, %c2 : tensor<?x?x?xf32>
    %0:2 = scf.forall (%arg5, %arg6) = (%c0, %c0) to (%dim, %dim_0) step (%arg3, %arg4) shared_outs(%arg7 = %arg1, %arg8 = %arg2) -> (tensor<?x?xf32>, tensor<?xf32>) {
      %3 = affine.min #map(%arg5)[%dim, %arg3]
      %4 = affine.min #map(%arg6)[%dim_0, %arg4]
      %extracted_slice = tensor.extract_slice %arg0[%arg5, %arg6, 0] [%3, %4, %dim_1] [1, 1, 1] : tensor<?x?x?xf32> to tensor<?x?x?xf32>
      %extracted_slice_2 = tensor.extract_slice %arg7[%arg5, %arg6] [%3, %4] [1, 1] : tensor<?x?xf32> to tensor<?x?xf32>
      %5 = linalg.generic {indexing_maps = [#map1, #map2], iterator_types = ["parallel", "parallel", "reduction"]} ins(%extracted_slice : tensor<?x?x?xf32>) outs(%extracted_slice_2 : tensor<?x?xf32>) {
      ^bb0(%in: f32, %out: f32):
        %7 = arith.mulf %in, %out : f32
        linalg.yield %7 : f32
      } -> tensor<?x?xf32>
      %extracted_slice_3 = tensor.extract_slice %arg8[%arg5] [%3] [1] : tensor<?xf32> to tensor<?xf32>
      %6 = linalg.generic {indexing_maps = [#map3, #map4], iterator_types = ["parallel", "reduction"]} ins(%5 : tensor<?x?xf32>) outs(%extracted_slice_3 : tensor<?xf32>) {
      ^bb0(%in: f32, %out: f32):
        %7 = arith.addf %in, %out : f32
        linalg.yield %7 : f32
      } -> tensor<?xf32>
      scf.forall.in_parallel {
        tensor.parallel_insert_slice %6 into %arg8[%arg5] [%3] [1] : tensor<?xf32> into tensor<?xf32>
      }
    }
    %1 = tensor.empty(%dim, %dim_0) : tensor<?x?xf32>
    %2 = linalg.generic {indexing_maps = [#map3, #map4, #map3], iterator_types = ["parallel", "parallel"]} ins(%0#0, %0#1 : tensor<?x?xf32>, tensor<?xf32>) outs(%1 : tensor<?x?xf32>) {
    ^bb0(%in: f32, %in_2: f32, %out: f32):
      %3 = arith.addf %in, %in_2 : f32
      linalg.yield %3 : f32
    } -> tensor<?x?xf32>
    return %2 : tensor<?x?xf32>
  }
}
