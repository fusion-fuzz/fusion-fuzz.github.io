public struct NC: ~Copyable {
  var id = 0
}
public struct Box: ~Copyable {
  var a = NC()
}
public struct S: ~Copyable {
  var _k = NC()
  var _p = Box()
  var k: NC {
    borrow { return _k }
  }
  var p: Box {
    borrow { return _p }
  }
}
func use(_ k: borrowing NC) { print(k.id) }
func test() {
  let s = S()
  use(s.k)
  use(s.p.a)
}
