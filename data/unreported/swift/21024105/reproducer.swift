class C {}
protocol P: C {
  associatedtype T: Q
}
protocol Q {
  associatedtype U
}
struct S<T: Q>: P {}
struct G<X: P, Y: Q> where X.T.U == Int {}
extension G where X == S<Y> {}
