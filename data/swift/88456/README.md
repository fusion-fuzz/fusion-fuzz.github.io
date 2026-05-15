---
render_with_liquid: false
---

**Date:** `2026-04-14`
# [[Swift] Assertion "Expected non-null node" in ConstraintSystem::getType when type-checking a @Sendable closure calling an overloaded @preconcurrency @MainActor function shadowed by a global var binding](https://github.com/swiftlang/swift/issues/88456)

**Description**

`swiftc -typecheck -Onone -sil-verify-all -enable-library-evolution` crashes with an assertion failure in `ConstraintSystem::getType` (`"Expected non-null node"` at `ConstraintSystem.h:3073`) when type-checking a `@Sendable` closure that calls an overloaded `@preconcurrency @MainActor` function, in a module where that function name is also shadowed by a global `var` binding of a different function type, and a `@preconcurrency` overload taking a complex `Handler` parameter exists. The constraint system attempts to repair a type mismatch during closure type-checking and calls `getType` on a null AST node, triggering the assertion.

**Reproducer**

```swift
func divide(_ a: Int, byDividend b: Int) -> Int { return a / b }

var f: (_: Int, _ byDividend: Int) -> Int = divide

@preconcurrency @MainActor func f() { }

@preconcurrency typealias OtherHandler = @Sendable () -> Void
@preconcurrency typealias Handler = (@Sendable () -> OtherHandler?)?
@preconcurrency func f(arg: Int, withFn: Handler?) {}

func test() {
  var _: (@Sendable () -> Void) = { f() }
}
```

**Command**

```
swiftc -typecheck -Onone -sil-verify-all -enable-library-evolution reproduce.swift
```

**Expected behavior**

The compiler should emit diagnostics about the ambiguous `f` reference or concurrency violations, then exit gracefully. It should not crash.

**Actual behavior**

```
Assertion failed: (!node.isNull() && "Expected non-null node"),
function getType at ConstraintSystem.h:3073.

While evaluating request TypeCheckFunctionBodyRequest for 'test()'
While type-checking expression at [reproduce.swift:12:28] RangeText="{ f() }"
While type-checking-target starting at reproduce.swift:12:28
```

**Call chain**

```
TypeCheckPrimaryFileRequest::evaluate
  → TypeCheckFunctionBodyRequest::evaluate
    → typeCheckPatternBinding       (var _: @Sendable () -> Void = { f() })
      → typeCheckExpression
        → ConstraintSystem::solve
          → ConstraintSystem::salvage
            → ConstraintSystem::solveImpl
              → DisjunctionChoice::attempt
                → simplifyDisjunctionChoice
                  → simplifyRestrictedConstraintImpl
                    → matchTypes
                      → repairFailures
                        → ConstraintSystem::getType   ← assertion: null node
```

**Root cause**

The global `var f` binding shadows `@preconcurrency @MainActor func f()`. When the constraint system type-checks `{ f() }` as a `@Sendable () -> Void`, it encounters multiple overloads of `f` (the var binding, the `@MainActor` function, and the `@preconcurrency func f(arg:withFn:Handler?)` overload). During disjunction solving, `repairFailures` is called to handle a type mismatch between the inferred closure body type and the expected `@Sendable () -> Void`. It calls `ConstraintSystem::getType` on an AST node that was never assigned a type in the constraint system (because the shadowing caused it to be skipped during constraint generation), triggering the null node assertion. The fix should guard `repairFailures` against calling `getType` on nodes with no recorded type when multiple overloaded candidates exist for a shadowed name.

**Environment**

- Compiler: Swift 6.3 (swift-6.3-RELEASE)
- Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)
- Command: `swiftc -typecheck -Onone -sil-verify-all -enable-library-evolution reproduce.swift`
- Crash site: `swift/lib/Sema/ConstraintSystem.h:3073` (`ConstraintSystem::getType`)
- Affected pass: `repairFailures` in `swift/lib/Sema/CSSimplify.cpp`
