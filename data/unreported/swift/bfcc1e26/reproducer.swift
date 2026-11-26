await withCheckedContinuation { (cc: CheckedContinuation<Void, Never>) in
}
@_silgen_name("exit") public func exit () -> Never
public func testNoReturnAttrPoly<T>(x: T) -> Never { exit() }
