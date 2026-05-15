func outer() {
  protocol Foo {}
  extension Int: Foo {}

  func foo(_: Int) -> some Foo { return 1738 }
  func foo(_: String) -> some Foo { return 679 }
  func foo<T: Foo>(_ x: T) -> some Foo { return x }

  var globalVarTuple: (some Foo, some Foo) = (123, foo(123))
}
