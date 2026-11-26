module {
  test.graph_region {
    %0 = builtin.unrealized_conversion_cast %0 : i32 to i32
    "test.return"() : () -> ()
  }
}
