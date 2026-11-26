#H_ade5a09b_s1_map = affine_map<(d0) -> (d0)>
#D_91ad4a68_B_ade5a09b_s1_map = affine_map<(d0) -> (d0)>
module {
func.func @H_ade5a09b_test_conv_op_not_linalg_op(%arg0 : tensor<?xf32>, %arg1 : tensor<?xf32>,
    %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = "test.conv_op_not_linalg_op"(%arg0, %arg1, %arg2)
      : (tensor<?xf32>, tensor<?xf32>, tensor<?xf32>) -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


// Check for number of operands being >= 2.
func.func @H_ade5a09b_s1_test_conv_op_wrong_num_operands(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [#H_ade5a09b_s1_map, #H_ade5a09b_s1_map],
      iterator_types = [#test.iterator_type<parallel>]}
      ins(%arg0 : tensor<?xf32>) outs(%arg1 : tensor<?xf32>) {
      ^bb0(%arg2 : f32, %arg3 : f32):
         linalg.yield  %arg3 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


func.func @H_ade5a09b_s2_test_conv_op_wrong_input_indexing_map1(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1) -> (d0 * 2)>,
                       affine_map<(d0, d1) -> (d1)>,
                       affine_map<(d0, d1) -> (d0)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<reduction>]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


func.func @H_ade5a09b_s3_test_conv_op_wrong_input_indexing_map2(%arg0 : tensor<?x?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1) -> (d0 + d1, d0)>,
                       affine_map<(d0, d1) -> (d1)>,
                       affine_map<(d0, d1) -> (d0)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<reduction>]}
      ins(%arg0, %arg1 : tensor<?x?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


func.func @H_ade5a09b_s4_test_conv_op_filter_index_map_not_projection(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1) -> (d1)>,
                       affine_map<(d0, d1) -> (d1 + d0)>,
                       affine_map<(d0, d1) -> (d0)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<reduction>]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


func.func @H_ade5a09b_s5_test_conv_op_output_index_map_not_projection(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1) -> (d0)>,
                       affine_map<(d0, d1) -> (d1)>,
                       affine_map<(d0, d1) -> (d0 + d1)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<parallel>]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


// Convolution op illegal if a loop dimension is used to access
// output, filter and is convolved.
func.func @H_ade5a09b_s6_test_conv_op_output_filter_convolved(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?x?xf32>) -> tensor<?x?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1) -> (d0 + d1)>,
                       affine_map<(d0, d1) -> (d1)>,
                       affine_map<(d0, d1) -> (d0, d1)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<parallel>]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?x?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?x?xf32>
  return %0 : tensor<?x?xf32>
}


// Convolution op illegal if a loop dimension is used only in the output.
func.func @H_ade5a09b_s7_test_conv_op_output_only_dim(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?x?xf32>) -> tensor<?x?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1, d2) -> (d0 + d1)>,
                       affine_map<(d0, d1, d2) -> (d1)>,
                       affine_map<(d0, d1, d2) -> (d0, d2)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<reduction>,
                        #test.iterator_type<parallel>]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?x?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?x?xf32>
  return %0 : tensor<?x?xf32>
}


// Convolution op illegal if a loop dimension is used only in the filter.
func.func @H_ade5a09b_s8_test_conv_op_filter_only_dim(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?x?xf32>, %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1, d2) -> (d0 + d1)>,
                       affine_map<(d0, d1, d2) -> (d1, d2)>,
                       affine_map<(d0, d1, d2) -> (d0)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<reduction>,
                        #test.iterator_type<reduction>]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?x?xf32>)
      outs(%arg2 : tensor<?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


// Convolution op illegal if a loop dimension is used only in the input.
func.func @H_ade5a09b_s9_test_conv_op_input_only_dim(%arg0 : tensor<?x?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op {
      indexing_maps = [affine_map<(d0, d1, d2) -> (d0 + d1, d2)>,
                       affine_map<(d0, d1, d2) -> (d1)>,
                       affine_map<(d0, d1, d2) -> (d0)>],
      iterator_types = [#test.iterator_type<parallel>,
                        #test.iterator_type<reduction>,
                        #test.iterator_type<reduction>]}
      ins(%arg0, %arg1 : tensor<?x?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}


// Convolution op illegal if a loop dimension accessing output is not parallel.
func.func @H_ade5a09b_s10_test_conv_op_non_output_access_loop_parallel(%arg0 : tensor<?xf32>,
    %arg1 : tensor<?xf32>, %arg2 : tensor<?xf32>) -> tensor<?xf32> {
  %0 = test.linalg_conv_op  {
      indexing_maps = [affine_map<(d0, d1) -> (d0 + d1)>,
                       affine_map<(d0, d1) -> (d1)>,
                       affine_map<(d0, d1) -> (d0)>],
      iterator_types = [#test.iterator_type<parallel>,
      affine_map<(d0, d1) -> (d1)>,
                        #test.iterator_type<parallel>]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?xf32>)
      outs(%arg2 : tensor<?xf32>) {
      ^bb0(%arg3 : f32, %arg4 : f32, %arg5 : f32):
         linalg.yield %arg5 : f32
      } -> tensor<?xf32>
  return %0 : tensor<?xf32>
}
}
