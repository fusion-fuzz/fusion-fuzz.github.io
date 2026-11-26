class C<T> {
}
protocol P2 {
  associatedtype A: C<B>
  associatedtype B
}
extension P2 where Self == A, A == B {
  func g() -> C<Self> {
    return self
  }
}
