final class A<T> {}
extension A: ExpressibleByNilLiteral where T: ExpressibleByNilLiteral {}
class B<T>: A {}
let x: B<Int?> = B(nil)
