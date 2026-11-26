protocol InheritsAsyncSequence: AsyncSequence { }
extension InheritsAsyncSequence {
  func blah() async rethrows -> [Element] {
    @propertyWrapper
    struct SomeLongFooName<Holder, T> {
    var wrappedValue: T
    struct Bar {
    typealias Foo<T> = SomeLongFooName<Self, T>
    @Foo var baz: Bool = false
