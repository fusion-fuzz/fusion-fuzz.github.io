public final class List<Element> where Element: ~Copyable {
    public static var defaultCapacity: Int { 2 }
    @_alwaysEmitIntoClient
    private var buffer: UnsafeMutableBufferPointer<Element>
    public init(emptyWithCapacity initialCapacity: Int = defaultCapacity) {
    }
}
