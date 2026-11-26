protocol Q {
  associatedtype V: Q
}
protocol P3: Q {}
protocol P6 {
  associatedtype V: P6 & P3
}
protocol P5 {
  associatedtype U: P3
}
struct G1<T: P6>: P5 {
  typealias U = T.V
}
