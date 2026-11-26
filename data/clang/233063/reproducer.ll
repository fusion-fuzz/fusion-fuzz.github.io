define <8 x i32> @f(<8 x i32> %x) {
  %v0 = call <8 x i32> @llvm.ucmp.v8i32.v8i32(<8 x i32> %x, <8 x i32> %x)       ; = 0, but only folded during vector legalization
  %v1 = call <8 x i32> @llvm.fshr.v8i32(<8 x i32> %v0, <8 x i32> <i32 16, i32 32, i32 48, i32 64, i32 80, i32 96, i32 112, i32 128>,
                                        <8 x i32> <i32 1, i32 2, i32 1, i32 2, i32 1, i32 2, i32 1, i32 2>)
  ret <8 x i32> %v1
}
