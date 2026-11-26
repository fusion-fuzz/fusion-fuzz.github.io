protocol P {
    associatedtype A
}
enum E<T: P> {
    case recursive(T.A)
}
struct ER: P {
    typealias A = E<ER>
}
enum EU<T: P> {
    case x(E<T>)
}
func zim(x: EU<ER>) -> EU<ER> { return x }
