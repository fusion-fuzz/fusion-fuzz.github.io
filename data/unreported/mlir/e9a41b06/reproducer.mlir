module {
func.func @H_6ff7b428_main() {
    %c0 = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %cneg1 = arith.constant -1 : i32
    %a = arith.constant -1 : i32
    %b = arith.constant 0 : i32
    %lt = arith.cmpi slt, %a, %b : i32
    scf.if %lt {
      %r = arith.constant -1 : i32
      scf.yield
    } else {
      %eq = arith.cmpi eq, %a, %b : i32
      scf.if %eq {
        %r = arith.constant 0 : i32
        scf.yield
      } else {
        %r = arith.constant 1 : i32
        scf.yield
      }
    }
    return
  }
}
