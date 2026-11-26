module attributes {omp.is_target_device = false, omp.target_triples = ["amdgcn-amd-amdhsa"]} {
llvm.func @H_752b1ea8__QQmain() attributes {fir.bindc_name = "main"} {
    %0 = llvm.mlir.constant(39 : i64) : i64
    %1 = llvm.mlir.constant(0 : i64) : i64
    %2 = llvm.mlir.constant(1 : i64) : i64
    %3 = llvm.mlir.constant(40 : i64) : i64
    %4 = llvm.mlir.addressof @H_752b1ea8__QFEa : !llvm.ptr
    %5 = llvm.mlir.addressof @H_752b1ea8__QFEb : !llvm.ptr
    %6 = llvm.mlir.constant(1 : i64) : i64
    %7 = llvm.alloca %6 x i32 {bindc_name = "i"} : (i64) -> !llvm.ptr
    %8 = llvm.mlir.addressof @H_752b1ea8__QFEn : !llvm.ptr
    omp.task {
      %14 = llvm.mlir.constant(1 : i64) : i64
      %15 = llvm.alloca %14 x i32 {bindc_name = "i", pinned} : (i64) -> !llvm.ptr
      %16 = llvm.load %8 : !llvm.ptr -> i32
      %17 = llvm.sext %16 : i32 to i64
      %18 = llvm.trunc %2 : i64 to i32
      llvm.br ^bb1(%18, %17 : i32, i64)
    ^bb1(%19: i32, %20: i64):  // 2 preds: ^bb0, ^bb2
      %21 = llvm.icmp "sgt" %20, %1 : i64
      llvm.cond_br %21, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      llvm.store %19, %15 : i32, !llvm.ptr
      %22 = llvm.load %15 : !llvm.ptr -> i32
      %23 = llvm.sext %22 : i32 to i64
      %24 = llvm.mlir.constant(1 : i64) : i64
      %25 = llvm.mlir.constant(0 : i64) : i64
      %26 = llvm.sub %23, %24 overflow<nsw> : i64
      %27 = llvm.mul %26, %24 overflow<nsw> : i64
      %28 = llvm.mul %27, %24 overflow<nsw> : i64
      %29 = llvm.add %28, %25 overflow<nsw> : i64
      %30 = llvm.mul %24, %3 overflow<nsw> : i64
      %31 = llvm.getelementptr %4[%29] : (!llvm.ptr, i64) -> !llvm.ptr, i32
      llvm.store %22, %31 : i32, !llvm.ptr
      %32 = llvm.load %15 : !llvm.ptr -> i32
      %33 = llvm.add %32, %18 : i32
      %34 = llvm.sub %20, %2 : i64
      llvm.br ^bb1(%33, %34 : i32, i64)
    ^bb3:  // pred: ^bb1
      llvm.store %19, %15 : i32, !llvm.ptr
      omp.terminator
    }
    %9 = omp.map.bounds lower_bound(%1 : i64) upper_bound(%0 : i64) extent(%3 : i64) stride(%2 : i64) start_idx(%2 : i64)
    %dc91051d1_4 = llvm.mlir.addressof @D_c91051d1_B_752b1ea8__QFEa : !llvm.ptr
    %dc91051d1_14 = llvm.mlir.constant(1 : i64) : i64
    %dc91051d1_15 = llvm.alloca %dc91051d1_14 x i32 {bindc_name = "i", pinned} : (i64) -> !llvm.ptr
    %dc91051d1_22 = llvm.load %dc91051d1_15 : !llvm.ptr -> i32
    %dc91051d1_23 = llvm.sext %dc91051d1_22 : i32 to i64
    %dc91051d1_24 = llvm.mlir.constant(1 : i64) : i64
    %dc91051d1_25 = llvm.mlir.constant(0 : i64) : i64
    %dc91051d1_26 = llvm.sub %dc91051d1_23, %dc91051d1_24 overflow<nsw> : i64
    %dc91051d1_27 = llvm.mul %dc91051d1_26, %dc91051d1_24 overflow<nsw> : i64
    %dc91051d1_28 = llvm.mul %dc91051d1_27, %dc91051d1_24 overflow<nsw> : i64
    %dc91051d1_29 = llvm.add %dc91051d1_28, %dc91051d1_25 overflow<nsw> : i64
    %dc91051d1_30 = llvm.mul %dc91051d1_24, %27 overflow<nsw> : i64
    %dc91051d1_31 = llvm.getelementptr %dc91051d1_4[%dc91051d1_29] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    llvm.store %dc91051d1_22, %dc91051d1_31 : i32, !llvm.ptr
    %dc91051d1_32 = llvm.load %dc91051d1_15 : !llvm.ptr -> i32
    %dc91051d1_33 = llvm.add %dc91051d1_32, %32 : i32
    %dc91051d1_34 = llvm.sub %24, %22 : i64
    %10 = omp.map.info var_ptr(%4 : !llvm.ptr, !llvm.array<40 x i32>) map_clauses(to) capture(ByRef) bounds(%9) name("a") -> !llvm.ptr
    %11 = omp.map.info var_ptr(%5 : !llvm.ptr, !llvm.array<40 x i32>) map_clauses(from) capture(ByRef) bounds(%9) name("b") -> !llvm.ptr
    %12 = omp.map.info var_ptr(%7 : !llvm.ptr, i32) map_clauses(implicit, exit_release_or_enter_alloc) capture(ByCopy) name("i") -> !llvm.ptr
    %13 = omp.map.info var_ptr(%8 : !llvm.ptr, i32) map_clauses(implicit, exit_release_or_enter_alloc) capture(ByCopy) name("n") -> !llvm.ptr
    omp.target kernel_type(generic) depend(taskdependin -> %4 : !llvm.ptr) map_entries(%10 -> %arg0, %11 -> %arg1, %12 -> %arg2, %13 -> %arg3 : !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) {
      %14 = llvm.mlir.constant(0 : i64) : i64
      %15 = llvm.mlir.constant(10 : i32) : i32
      %16 = llvm.mlir.constant(1 : i64) : i64
      %17 = llvm.mlir.constant(40 : i64) : i64
      %18 = llvm.load %arg3 : !llvm.ptr -> i32
      %19 = llvm.sext %18 : i32 to i64
      %20 = llvm.trunc %16 : i64 to i32
      llvm.br ^bb1(%20, %19 : i32, i64)
    ^bb1(%21: i32, %22: i64):  // 2 preds: ^bb0, ^bb2
      %23 = llvm.icmp "sgt" %22, %14 : i64
      llvm.cond_br %23, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      llvm.store %21, %arg2 : i32, !llvm.ptr
      %24 = llvm.load %arg2 : !llvm.ptr -> i32
      %25 = llvm.sext %24 : i32 to i64
      %26 = llvm.mlir.constant(1 : i64) : i64
      %27 = llvm.mlir.constant(0 : i64) : i64
      %28 = llvm.sub %25, %26 overflow<nsw> : i64
      %29 = llvm.mul %28, %26 overflow<nsw> : i64
      %30 = llvm.mul %29, %26 overflow<nsw> : i64
      %31 = llvm.add %30, %27 overflow<nsw> : i64
      %32 = llvm.mul %26, %17 overflow<nsw> : i64
      %33 = llvm.getelementptr %arg0[%31] : (!llvm.ptr, i64) -> !llvm.ptr, i32
      %34 = llvm.load %33 : !llvm.ptr -> i32
      %35 = llvm.add %34, %15 : i32
      %36 = llvm.mlir.constant(1 : i64) : i64
      %37 = llvm.mlir.constant(0 : i64) : i64
      %38 = llvm.sub %25, %36 overflow<nsw> : i64
      %39 = llvm.mul %38, %36 overflow<nsw> : i64
      %40 = llvm.mul %39, %36 overflow<nsw> : i64
      %41 = llvm.add %40, %37 overflow<nsw> : i64
      %42 = llvm.mul %36, %17 overflow<nsw> : i64
      %43 = llvm.getelementptr %arg1[%41] : (!llvm.ptr, i64) -> !llvm.ptr, i32
      llvm.store %35, %43 : i32, !llvm.ptr
      %44 = llvm.load %arg2 : !llvm.ptr -> i32
      %45 = llvm.add %44, %20 : i32
      %46 = llvm.sub %22, %16 : i64
      llvm.br ^bb1(%45, %46 : i32, i64)
    ^bb3:  // pred: ^bb1
      llvm.store %21, %arg2 : i32, !llvm.ptr
      omp.terminator
    }
    llvm.return
  }
  llvm.mlir.global internal @H_752b1ea8__QFEa() {addr_space = 0 : i32} : !llvm.array<40 x i32> {
    %0 = llvm.mlir.zero : !llvm.array<40 x i32>
    llvm.return %0 : !llvm.array<40 x i32>
  }
  llvm.mlir.global internal @H_752b1ea8__QFEb() {addr_space = 0 : i32} : !llvm.array<40 x i32> {
    %0 = llvm.mlir.zero : !llvm.array<40 x i32>
    llvm.return %0 : !llvm.array<40 x i32>
  }
  llvm.mlir.global internal @H_752b1ea8__QFEc() {addr_space = 0 : i32} : !llvm.array<40 x i32> {
    %0 = llvm.mlir.zero : !llvm.array<40 x i32>
    llvm.return %0 : !llvm.array<40 x i32>
  }
  llvm.mlir.global internal @H_752b1ea8__QFEn() {addr_space = 0 : i32} : i32 {
    %0 = llvm.mlir.constant(40 : i32) : i32
    llvm.return %0 : i32
  }
  llvm.func @H_752b1ea8__FortranAProgramStart(i32, !llvm.ptr, !llvm.ptr, !llvm.ptr) attributes {sym_visibility = "private"}
  llvm.func @H_752b1ea8__FortranAProgramEndStatement() attributes {sym_visibility = "private"}
  llvm.func @H_752b1ea8_main(%arg0: i32, %arg1: !llvm.ptr, %arg2: !llvm.ptr) -> i32 {
    %0 = llvm.mlir.constant(0 : i32) : i32
    %1 = llvm.mlir.zero : !llvm.ptr
    llvm.call @H_752b1ea8__FortranAProgramStart(%arg0, %arg1, %arg2, %1) {fastmathFlags = #llvm.fastmath<contract>} : (i32, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.call @H_752b1ea8__QQmain() {fastmathFlags = #llvm.fastmath<contract>} : () -> ()
    llvm.call @H_752b1ea8__FortranAProgramEndStatement() {fastmathFlags = #llvm.fastmath<contract>} : () -> ()
    llvm.return %0 : i32
  }
}
