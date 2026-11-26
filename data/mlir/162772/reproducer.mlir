#trait = {
    indexing_maps = [
      affine_map<(m, n, k) -> (m, k)>,
      affine_map<(m, n, k) -> (k, n)>,
      affine_map<(m, n, k) -> (m, n)>
    ],
    iterator_types = ["parallel", "parallel", "reduction"] 
  }
  func.func @B_hoist_linalg_ops_div_by_zero(%a : tensor<128x128xi32>, 
                              %b : tensor<128x128xi32>, 
                              %c: tensor<128x128xi32>,
                              %lb : index,
                              %ub : index,
                              %step : index,
                              %output : tensor<?x128xi32>) -> tensor<?x128xi32> {
    %final = 
    scf.for %i = %lb to %ub step %step iter_args(%acc = %output) 
                                              -> tensor<?x128xi32> {
      %compute = linalg.generic #trait
                 ins(%a, %b : tensor<128x128xi32>, tensor<128x128xi32>) 
                 outs(%c : tensor<128x128xi32>) {
      ^bb0(%in : i32, %in2 : i32, %in3 : i32):
        linalg.yield %in3 : i32
      } -> tensor<128x128xi32>
      %newacc = tensor.insert_slice %compute into 
                                    %output[%i, 0][128, 128][1, 1] 
                                    : tensor<128x128xi32> into tensor<?x128xi32>
      scf.yield %newacc : tensor<?x128xi32>
    }
    func.return %final : tensor<?x128xi32>
  }
