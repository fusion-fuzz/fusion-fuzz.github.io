module {
shard.grid @grid(shape = 1)
func.func @f(%arg: tensor<6x6xi32>) -> tensor<6x6xi32> {
  %s1 = shard.sharding @grid split_axes = [[0]] : !shard.sharding
  %a = shard.shard %arg to %s1 : tensor<6x6xi32>
  %e = tensor.empty() : tensor<6x6xi32>
  %r = linalg.generic {indexing_maps = [affine_map<(d0,d1)->(d0,d1)>, affine_map<(d0,d1)->(d0,d1)>], iterator_types = ["parallel","parallel"]} ins(%a : tensor<6x6xi32>) outs(%e : tensor<6x6xi32>) {
  ^bb0(%in: i32, %out: i32):
    %s2 = shard.sharding @grid split_axes = [[1]] : !shard.sharding
    %b = shard.shard %arg to %s2 : tensor<6x6xi32>
    linalg.yield %in : i32
  } -> tensor<6x6xi32>
  return %r : tensor<6x6xi32>
}
}
