final class E<R> {
  var b: Bool { true }
}
struct Foo<each R> {
  let e: (repeat E<each R>)
  func f() {
    for x in repeat each e {
      if x.b { break }
    }
  }
}
Foo(e: E<Int>()).f()
fatalError()
