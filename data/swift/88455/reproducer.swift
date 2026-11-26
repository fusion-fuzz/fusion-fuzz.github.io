@propertyWrapper
public struct Wrapper<T> {
    public var wrappedValue: T
    public init(wrappedValue: T) { self.wrappedValue = wrappedValue }
}

@propertyWrapper
public struct ProjectedValueWrapper<T> {
    public var wrappedValue: T
    public init(wrappedValue: T) { self.wrappedValue = wrappedValue }
    public init(projectedValue: Wrapper<T>) { self.wrappedValue = projectedValue.wrappedValue }
    public var projectedValue: Wrapper<T> {
        get { Wrapper(wrappedValue: wrappedValue) }
        set { wrappedValue = newValue.wrappedValue }
    }
}

public struct S {
    public func hasParameterWithAPIWrapper(@ProjectedValueWrapper x: Int) { }
}
