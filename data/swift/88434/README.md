---
render_with_liquid: false
---

# [[Swift] Crash in PackConformance::getAssociatedConformance → PackType::get when type-checking variadic generic call with deeply nested associated type pack expansion in presence of ambiguous type name](https://github.com/swiftlang/swift/issues/88434)

### Description

**Description**

`swiftc` crashes with a null pointer dereference (SEGV at `0x0000000000000008`) when type-checking a call to a variadic generic function whose return type is a deeply nested associated type pack expansion (`repeat (each T).A.A.A.A`), when the module also contains a duplicate declaration of `S` that makes `S` ambiguous. The ambiguity error causes `struct S: P` to fail its conformance check, and the subsequent pack conformance substitution during effects checking dereferences a null pointer. No special compiler flags are required to reproduce.

**Reproducer**

```swift
protocol P {
  associatedtype A: P
}

struct S: P {
  typealias A = S
}

func f<each T: P>(_: repeat each T) -> (repeat (each T).A.A.A.A) {}

f(S(), S(), S())

public struct S {}
```

**Command**

```
swiftc reproduce.swift
```

**Expected behavior**

The compiler should emit diagnostics about the ambiguous `S` and the conformance failure, then exit gracefully. It should not crash.

**Actual behavior**

```
reproduce.swift:6:17: error: 'S' is ambiguous for type lookup in this context
reproduce.swift:5:8: error: type 'S' does not conform to protocol 'P'

💣 Program crashed: Bad pointer dereference at 0x0000000000000008

While evaluating request TypeCheckPrimaryFileRequest(source_file "reproduce.swift")
error: compile command failed due to signal 11
```

**Call chain**

```
TypeCheckPrimaryFileRequest::evaluate
  → typeCheckTopLevelCodeDecl
    → checkTopLevelEffects
      → classifyApply                              (TypeCheckEffects.cpp)
        → GenericFunctionType::substGenericArgs
          → Type::subst
            → expandPackExpansionShape
              → transformPackExpansionType
                → transformDependentMemberType     (TypeSubstitution.cpp)
                  → InFlightSubstitution::lookupConformance
                    → LookUpConformanceInSubstitutionMap::operator()
                      → SubstitutionMap::lookupConformance
                        → ProtocolConformanceRef::getAssociatedConformance
                          → PackConformance::getAssociatedConformance
                            → PackType::get        ← SEGV at 0x8
```

**Root cause**

When `S` is ambiguous, the conformance of `struct S: P` fails and `S.A` is unresolved. During effects checking of `f(S(), S(), S())`, the compiler substitutes the pack type parameter `each T` with `Pack{S, S, S}` and walks the associated type chain `.A.A.A.A`. `PackConformance::getAssociatedConformance` is called for each `.A` step, but because the conformance is broken due to the ambiguity error, it calls `PackType::get` with an invalid or null `ASTContext`, causing the null pointer dereference. The compiler should guard against performing pack conformance substitutions when conformances are in an error state.

**Environment**

- Compiler: Swift 6.3 (swift-6.3-RELEASE)
- Platform: x86_64 Linux (Ubuntu 24.04.4 LTS)
- Command: `swiftc reproduce.swift` (no special flags required)
- Crash site: `swift/lib/AST/PackConformance.cpp` (`PackConformance::getAssociatedConformance`) → `swift/lib/AST/Type.cpp` (`PackType::get`)
