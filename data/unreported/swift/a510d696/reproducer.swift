public struct R {}
struct S {
  var _z: (Int, R)
  var z: (Int, R) {
    @storageRestrictions(initializes: _z)
    init { _z = newValue }
    get { _z }
  }
  init() { z = (0, R()) }
}
