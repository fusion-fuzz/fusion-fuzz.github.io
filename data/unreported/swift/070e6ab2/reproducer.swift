@_silgen_name("use")
public func use<T: ~Copyable>(_: borrowing T)
public struct NCL: ~Copyable { var x: AnyObject }
public enum MultiNCL: ~Copyable {
	case foo(NCL)
	case bar(NCL)
}
public func testNCL_privateImpl(foo: borrowing MultiNCL) {
	switch foo {
	case .foo(let x):
		use(x)
	case .bar(let x):
		use(x)
	}
}
@inlinable
public func testNCL_inlinableImpl(foo: borrowing MultiNCL) {
	switch foo {
	case .foo(let x):
		use(x)
	@unknown default:
		break
	}
}
