class ImageSet {
}
protocol Storage<T> {
  associatedtype T
  func getValue<V>(_: KeyPath<T, V>) -> V
}
struct NoopStorage<T>: Storage {
  func getValue<V>(_: KeyPath<T, V>) -> V { fatalError() }
}
final class TestIndirectionThroughStorage: ImageSet {
  var age: Int? = nil {
    init {
    }
    get { _storage.getValue(\.age) }
    set { }
  }
  private var _storage: any Storage<TestIndirectionThroughStorage> = NoopStorage()
  init(name: String, age: Int) {
    self.age = age
  }
  struct Test1 {
    var age: Int = 0 {
      init {
      }
      get {
      }
    }
  }
}
