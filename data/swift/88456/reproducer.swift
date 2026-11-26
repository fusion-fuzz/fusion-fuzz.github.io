func divide(_ a: Int, byDividend b: Int) -> Int { return a / b }

var f: (_: Int, _ byDividend: Int) -> Int = divide

@preconcurrency @MainActor func f() { }

@preconcurrency typealias OtherHandler = @Sendable () -> Void
@preconcurrency typealias Handler = (@Sendable () -> OtherHandler?)?
@preconcurrency func f(arg: Int, withFn: Handler?) {}

func test() {
  var _: (@Sendable () -> Void) = { f() }
}
