func.func @callee(%arg0: i32) -> i32 {
  %fn = "test.functional_region_op"() ({
  ^bb0(%a : i32):
    %b = arith.addi %a, %a : i32
    cf.br ^bb1(%b: i32)
  ^bb1(%c: i32):
    %d = arith.addi %c, %c : i32
    "test.return"(%d) : (i32) -> ()
  }) : () -> ((i32) -> i32)
  %0 = call_indirect %fn(%arg0) : (i32) -> i32
  return %0 : i32
}

func.func @caller(%arg0: i32) -> i32 {
  %0 = func.call @callee(%arg0) : (i32) -> i32
  return %0 : i32
}
