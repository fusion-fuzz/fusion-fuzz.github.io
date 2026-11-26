#blocked = #ttg.blocked<{sizePerThread = [4], threadsPerWarp = [32], warpsPerCTA = [4], order = [0]}>
module attributes {"ttg.num-ctas" = 1 : i32, "ttg.num-warps" = 4 : i32, ttg.target = "cuda:75", "ttg.threads-per-warp" = 32 : i32} {
  tt.func public @change_value(%X: !tt.ptr<f32> {tt.divisibility = 16 : i32}) attributes {noinline = false} {
    %c2_i32 = arith.constant 2 : i32
    %cst = arith.constant dense<0.000000e+00> : tensor<2xf32, #blocked>
    %cst_0 = arith.constant dense<2.000000e+00> : tensor<2xf32, #blocked>
    %pid = tt.get_program_id x : i32
    %block_start = arith.muli %pid, %c2_i32 : i32
    %offsets = tt.make_range {end = 2 : i32, start = 0 : i32} : tensor<2xi32, #blocked>
    %offsets_1 = tt.splat %block_start : i32 -> tensor<2xi32, #blocked>
    %offsets_2 = arith.addi %offsets_1, %offsets : tensor<2xi32, #blocked>
    %0 = tt.splat %X : !tt.ptr<f32> -> tensor<2x!tt.ptr<f32>, #blocked>
    %1 = tt.addptr %0, %offsets_2 : tensor<2x!tt.ptr<f32>, #blocked>, tensor<2xi32, #blocked>
    %2 = tt.atomic_cas acquire, gpu, %1, %cst, %cst_0 : (tensor<2x!tt.ptr<f32>, #blocked>, tensor<2xf32, #blocked>, tensor<2xf32, #blocked>) -> tensor<2xf32, #blocked>
    tt.return
  }
}
