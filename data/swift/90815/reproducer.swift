  @dynamicMemberLookup
  struct S<T> {
    subscript<U>(dynamicMember keyPath: KeyPath<T, U> & Sendable) -> U {
  struct Foo {
  func test(s: S<Foo>) {
    _ = s[bar: NonSendable()]
