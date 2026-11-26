module {
  func.func @H_1c384501_A_e0ef377c_main() {
      return
    }
  func.func @H_1c384501_B_d3599203_memref_subview(%arg0: memref<8x16x4xf32, strided<[64, 4, 1]>>, %arg1: memref<1x128x1x32x1xf32, strided<[4096, 32, 32, 1, 1]>>, %arg2: memref<8x16x4xf32, strided<[1, 64, 8], offset: 16>>, %arg3: index, %arg4: index, %arg5: index) {
    return
  }
  func.func @H_1c384501__ffl_p6_index_boundary() -> index {
    %large = arith.constant 9223372036854775807 : i64   // i64 MAX
    %idx   = arith.index_cast %large : i64 to index
    %c1    = arith.constant 1 : index
    %r     = arith.addi %idx, %c1 : index
    %i64   = arith.index_cast %r : index to i64
    %i32   = arith.trunci %i64 : i64 to i32
    %dd3599203_arg0 = ub.poison : memref<8x16x4xf32, strided<[64, 4, 1]>>
    %dd3599203_subview = memref.subview %dd3599203_arg0[%r, %r, %r] [%idx, %r, %c1] [%r, %r, %r] : memref<8x16x4xf32, strided<[64, 4, 1]>> to memref<?x?x?xf32, strided<[?, ?, ?], offset: ?>>
    %dd3599203_subview_0 = memref.subview %dd3599203_subview[%r, %r, %r] [%idx, %idx, %idx] [%c1, %c1, %c1] : memref<?x?x?xf32, strided<[?, ?, ?], offset: ?>> to memref<?x?x?xf32, strided<[?, ?, ?], offset: ?>>
    %back  = arith.index_cast %i32 : i32 to index
    return %back : index
  }
}
