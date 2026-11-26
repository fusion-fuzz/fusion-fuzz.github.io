module attributes {"ttg.num-warps" = 4 : i32, "ttg.num-ctas" = 1 : i32, "ttg.threads-per-warp" = 32 : i32, ttg.target = "cuda:90"} {
tt.func public @infer_efficient(%in_ptr : !tt.ptr<f32>, %out_ptr : !tt.ptr<f32>) {
    %mask = arith.constant dense<0> : tensor<128x256xi1, #gluon.auto_encoding>
    %in_ptrs_1 = tt.splat %in_ptr : !tt.ptr<f32> -> tensor<128x256x!tt.ptr<f32>, #gluon.auto_encoding>
    %in_ptrs_2 = gluon.set_auto_layout %in_ptrs_1 : tensor<128x256x!tt.ptr<f32>, #gluon.auto_encoding> -> tensor<128x256x!tt.ptr<f32>, #gluon.coalesced_encoding>
    %mask_in = gluon.set_auto_layout %mask : tensor<128x256xi1, #gluon.auto_encoding> -> tensor<128x256xi1, #gluon.coalesced_encoding>
    %value = tt.load %in_ptrs_2, %mask_in : tensor<128x256x!tt.ptr<f32>, #gluon.coalesced_encoding>
    tt.return
  }
}
