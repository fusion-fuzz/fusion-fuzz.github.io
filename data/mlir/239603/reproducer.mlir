module attributes {gpu.container_module} {
  func.func @f() {
    "foo.unknown_region"() ({
      %c1 = arith.constant 1 : index
      gpu.launch_func @kernels::@kernel blocks in (%c1, %c1, %c1) threads in (%c1, %c1, %c1)
    }) : () -> ()
    return
  }
}
