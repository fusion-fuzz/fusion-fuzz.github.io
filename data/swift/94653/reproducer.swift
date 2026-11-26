protocol P {}
extension P {
  init(_: String) { fatalError() }
}
struct S: P {
  init(_: Int) {}
  func callAsFunction(_: () -> Void) -> S { self }
}
let _: S = .init(1) {}
