---
render_with_liquid: false
---

**Date:** `2026-04-14`
**Date:** `2026-04-14`
# [[Swift] Assertion "Expected type to have been set!" in ConstraintSystem::getType when type-checking a call through a function-value binding that shadows an overloaded @preconcurrency @MainActor function](https://github.com/swiftlang/swift/issues/88454)

**Description**

`swiftc` crashes with an assertion failure in `ConstraintSystem::getType` (`"Expected type to have been set!"`) when type-checking a call `f(3)` where `f` is a top-level `let` binding of a function reference `foo(`_`:)`, and the name `f` is already declared as an overloaded `@preconcurrency @MainActor` function and a `@preconcurrency` overload taking a complex `Handler` parameter. The redeclaration of `f` as a `let` binding causes the constraint system to attempt to repair a type mismatch, and during `repairFailures` it calls `getType` on an AST node whose type has not been set, triggering the assertion.

**Reproducer**

```swift
@preconcurrency @MainActor func f() { }

@preconcurrency typealias Handler = (@Sendable () -> Void)?
@preconcurrency func f(arg: Int, withFn: Handler?) {}

func foo(`_`: Int) {}
foo(`_`: 3)
let f = foo(`_`:)
f(3)
```

**Command**

```
swiftc reproduce.swift
```

**Expected behavior**

The compiler should emit diagnostics about the invalid redeclaration of `f` and the argument mismatch in `f(3)`, then exit gracefully. It should not crash.

**Actual behavior**

```
reproduce.swift:8:5: error: invalid redeclaration of 'f'
reproduce.swift:9:3: error: argument passed to call that takes no arguments

Assertion failed: (found != NodeTypes.end() && "Expected type to have been set!"),
function getType at ConstraintSystem.h:3075.

While type-checking statement at [reproduce.swift:9:1] RangeText="f(3"
While type-checking expression at [reproduce.swift:9:1] RangeText="f(3"
```

**Call chain**

```
TypeCheckPrimaryFileRequest::evaluate
  → typeCheckTopLevelCodeDecl
    → typeCheckExpression
      → ConstraintSystem::solve
        → ConstraintSystem::salvage
          → ConstraintSystem::solveImpl
            → DisjunctionChoice::attempt
              → ConstraintSystem::simplifyDisjunctionChoice
                → ConstraintSystem::simplifyConstraint
                  → simplifyRestrictedConstraintImpl
                    → matchTypes
                      → repairFailures
                        → ConstraintSystem::getType   ← assertion failure
```

**Root cause**

When `f` is redeclared as a `let` binding of `foo(`_`:)`, the compiler still attempts to type-check `f(3)` with all candidates for `f` in scope — including the `@preconcurrency @MainActor func f()` and `@preconcurrency func f(arg:withFn:)` overloads. During constraint solving, `repairFailures` is called to handle the type mismatch between the integer argument `3` and the expected parameter types of the overloaded `f` candidates. It calls `ConstraintSystem::getType` on an expression node that was never assigned a type in the constraint system (because the redeclaration error caused it to be skipped during constraint generation), triggering the assertion. The fix should guard `repairFailures` against calling `getType` on nodes that have no recorded type, or ensure that redeclared bindings do not generate constraint system entries for the shadowed candidates.

**Environment**

- Compiler: Swift 6.3 (swift-6.3-RELEASE)
- Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)
- Command: `swiftc reproduce.swift` (no special flags required)
- Crash site: `swift/lib/Sema/ConstraintSystem.h:3075` (`ConstraintSystem::getType`)
- Affected pass: `repairFailures` in `swift/lib/Sema/CSSimplify.cpp`
