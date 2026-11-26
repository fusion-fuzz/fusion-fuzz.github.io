class A {
    subscript(property: String) -> Any? {
        set { _stdObject[property] = newValue }
}
class B: A {
    override subscript(property: String) -> Any? {}
}
