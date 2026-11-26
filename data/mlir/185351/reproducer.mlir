func.func @get_inf() -> f32 {
  %c = arith.constant 0xFF800000 : f32
  return %c : f32
}

func.func @entry() {
  %inf = func.call @get_inf() : () -> f32
  %trunc = arith.truncf %inf : f32 to f4E2M1FN
  %bitcast = arith.bitcast %trunc : f4E2M1FN to i4
  %ext = arith.extui %bitcast : i4 to i64
  return
}
