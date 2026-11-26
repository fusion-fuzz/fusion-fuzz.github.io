@propertyWrapper
public struct Wrapper<T> {
  public var wrappedValue: T
  public init(wrappedValue: T) {
  }
}
@propertyWrapper
public struct ProjectedValueWrapper<T> {
  public var wrappedValue: T
  public init(projectedValue: Wrapper<T>) {
  }
  public var projectedValue: Wrapper<T> {
    get { Wrapper(wrappedValue: wrappedValue) }
    set { wrappedValue = newValue.wrappedValue }
  }
}
@propertyWrapper public struct HasTwoTypeParameters<Value, Other> {
  public var wrappedValue: Value
  init(wrappedValue: Value, _ other: Other) {
  }
  public func hasParameterWithAPIWrapperComposed(@ProjectedValueWrapper @Wrapper x: Int) { }
}
