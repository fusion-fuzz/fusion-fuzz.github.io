class Klass_d52d4c8 {
  dynamic init(x_d52d4c8: Int) {
  }
}
extension Klass_d52d4c8 {
  @_dynamicReplacement(for: init(x_d52d4c8:))
    init(xr: Int) {
  }
}
class B: Klass_d52d4c8, Equatable {
  static func == (lhs: B, rhs: B) -> Bool { fatalError() }
}
class C : B {}
