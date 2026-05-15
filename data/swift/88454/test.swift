@preconcurrency @MainActor func f() { }

@preconcurrency typealias Handler = (@Sendable () -> Void)?
@preconcurrency func f(arg: Int, withFn: Handler?) {}

func foo(`_`: Int) {}
foo(`_`: 3)
let f = foo(`_`:)
f(3)
