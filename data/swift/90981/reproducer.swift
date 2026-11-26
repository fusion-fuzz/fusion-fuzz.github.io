protocol P2: P3 {
  associatedtype A9: P12
}
protocol P12: Codable, Equatable, C {}
protocol P14: P16 {
  associatedtype A1: P2
}
class C<X: P14, Y: P15> where X.A1: Codable, X.A1.A3.A6: Codable, X.A1.A3.A6 == Y.A6 {}
