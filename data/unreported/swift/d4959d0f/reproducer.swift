protocol B: P {
  associatedtype A
}
protocol P: B {
  override associatedtype A: P
}
