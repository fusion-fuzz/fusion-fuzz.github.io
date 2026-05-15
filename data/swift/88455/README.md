---
render_with_liquid: false
---

**Date:** `2026-04-14`
# [[Swift][SILGen] Assertion "Illegal convention for non-address types" in getFunctionArgOwnership when compiling a function parameter with a @propertyWrapper that has a projectedValue](https://github.com/swiftlang/swift/issues/88455)

**Description**

`swiftc -sil-verify-all` crashes with an assertion failure in `getFunctionArgOwnership` (`"Illegal convention for non-address types"`) at `OperandOwnership.cpp:531` when SIL-generating a struct method whose parameter is annotated with a `@propertyWrapper` that exposes a `projectedValue`. The SIL verifier detects an illegal ownership convention in the synthesized setter for the projected value parameter (`$x`), indicating that SILGen emits an incorrect calling convention for the non-address projected value type.

**Reproducer**

```swift
@propertyWrapper
public struct Wrapper<T> {
    public var wrappedValue: T
    public init(wrappedValue: T) { self.wrappedValue = wrappedValue }
}

@propertyWrapper
public struct ProjectedValueWrapper<T> {
    public var wrappedValue: T
    public init(wrappedValue: T) { self.wrappedValue = wrappedValue }
    public init(projectedValue: Wrapper<T>) { self.wrappedValue = projectedValue.wrappedValue }
    public var projectedValue: Wrapper<T> {
        get { Wrapper(wrappedValue: wrappedValue) }
        set { wrappedValue = newValue.wrappedValue }
    }
}

public struct S {
    public func hasParameterWithAPIWrapper(@ProjectedValueWrapper x: Int) { }
}
```

**Command**

```
swiftc -sil-verify-all reproduce.swift
```

**Expected behavior**

The compiler should successfully lower the AST to SIL and verify ownership without assertion failures. A `@propertyWrapper` with a `projectedValue` used as a function parameter should generate correct SIL ownership conventions.

**Actual behavior**

```
Assertion failed: (false && "Illegal convention for non-address types"),
function getFunctionArgOwnership at OperandOwnership.cpp:531.

While evaluating request ASTLoweringRequest(Lowering AST to SIL for module main)
While silgen emitFunction for 'hasParameterWithAPIWrapper(x:)'
While silgen emitFunction for setter for $x
While verifying SIL function for setter for $x
```

**Call chain**

```
ASTLoweringRequest::evaluate
  → SILGenModule::emitSourceFile
    → SILGenModule::visitNominalTypeDecl
      → SILGenType::emitType
        → SILGenModule::emitFunction         (hasParameterWithAPIWrapper)
          → SILGenFunction::emitFunction
            → SILGenFunction::visitVarDecl   ($x projected value var)
              → SILGenModule::emitFunction   (setter for $x)
                → SILGenModule::postEmitFunction
                  → SILFunction::verify
                    → SILVerifier::checkValueBaseOwnership
                      → SILValue::verifyOwnership
                        → SILValueOwnershipChecker::check
                          → gatherNonGuaranteedUsers
                            → Operand::getOperandOwnership
                              → visitFullApply
                                → getFunctionArgOwnership  ← assertion
```

**Root cause**

When SILGen lowers a function parameter annotated with `@ProjectedValueWrapper` (a `@propertyWrapper` that exposes a `projectedValue`), it synthesizes a local setter for the projected value binding `$x`. The synthesized setter incorrectly assigns an address-only calling convention to the `Wrapper<T>` projected value argument, which is not an address type. The SIL verifier catches this as an illegal ownership convention. The fix should ensure that SILGen uses the correct non-address ownership convention (`@owned` or `@guaranteed`) when emitting the setter for projected value parameters of non-address wrapper types.

**Environment**

- Compiler: Swift 6.3 (swift-6.3-RELEASE)
- Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)
- Command: `swiftc -sil-verify-all reproduce.swift`
- Crash site: `swift/lib/SIL/Verifier/OperandOwnership.cpp:531` (`getFunctionArgOwnership`)
- Affected pass: SILGen (`swift/lib/SILGen/`)
