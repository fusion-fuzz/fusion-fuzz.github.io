module {
func.func @H_f70f2a9e_parallel_insert_slice(%arg0: index) {
  scf.forall (%arg1) in (%arg0) {
  }
  return
}
func.func @H_f70f2a9e_s1_reduce(%buffer: memref<100xf32>) {
  %init = arith.constant 0.0 : f32
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  scf.parallel (%iv) = (%c0) to (%c1) step (%c1) init (%init) -> f32 {
    %elem_to_reduce = memref.load %buffer[%iv] : memref<100xf32>
    scf.reduce(%elem_to_reduce : f32) {
      ^bb0(%lhs : f32, %rhs: f32):
        %alloc = memref.alloc() : memref<2xf32>
        %d9a82e0a2_arg0 = ub.poison : index
        %d9a82e0a2_alloc = memref.alloc() : memref<2xf32>
        scf.forall (%d9a82e0a2_arg1) in (%d9a82e0a2_arg0) {
        %d9a82e0a2_alloc0 = memref.alloc() : memref<2xf32>
        %d9a82e0a2_0 = memref.load %d9a82e0a2_alloc[%c1] : memref<2xf32>
        linalg.fill ins(%d9a82e0a2_0 : f32) outs(%d9a82e0a2_alloc0 : memref<2xf32>)
        }
        %0 = memref.load %alloc[%c0] : memref<2xf32>
        %1 = memref.load %alloc[%c1] : memref<2xf32>
        %res = arith.addf %0, %1 : f32
        scf.reduce.return %res : f32
    }
  }
  func.return
}
}
