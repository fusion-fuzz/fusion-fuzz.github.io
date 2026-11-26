llvm.func @repeated_successor(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i1) {
    omp.wsloop {
      omp.loop_nest (%arg4) : i64 = (%arg0) to (%arg1) step (%arg2)  {
        llvm.cond_br %arg3, ^bb1(%arg0 : i64), ^bb1(%arg1 : i64)
      ^bb1(%0: i64):  // 2 preds: ^bb0, ^bb0
        omp.yield
      }
    }
    llvm.return
  }
