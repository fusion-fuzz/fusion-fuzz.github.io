func.func @f() {
  "foo.region"() ({
    %0 = affine.apply affine_map<()[s0] -> (s0 + 1)>()[%0]
    "foo.yield"() : () -> ()
  }) : () -> ()
  return
}
