public protocol P {
  func f()
}
public struct S<T>: P {
  public func f() {}
}
