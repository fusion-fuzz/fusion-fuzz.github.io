import _Differentiation

// --- Seed A ---
// RUN: %target-swift-emit-silgen -parse-stdlib %s | %FileCheck %s

typealias Int = Builtin.Int64

var zero: Int

func call(f: () -> Int) -> Int {
  return f()
}

// CHECK: sil hidden [ossa] @$s17capture_typealias3fooyyF : $@convention(thin) () -> () {
// CHECK: function_ref [[CLOSURE:@\$s17capture_typealias3fooyyFBi64_yXEfU_]]
func foo() {
  typealias X = Int

  call {
    var x: X = zero
    return x
  }
}

// CHECK: sil private [ossa] @$s17capture_typealias3fooyyFBi64_yXEfU_ : $@convention(thin) () -> Builtin.Int64 {
// RUN: %target-swift-frontend -typecheck -verify -verify-ignore-unrelated -primary-file %s %S/Inputs/struct_differentiable_other_module.swift


// Verify that a type `T` conforms to `AdditiveArithmetic`.
func assertConformsToAdditiveArithmetic<T>(_: T.Type)
where T: AdditiveArithmetic {}

struct Empty: Differentiable {}
func testEmpty() {
  assertConformsToAdditiveArithmetic(Empty.TangentVector.self)
}

struct EmptyWithConcreteNonmutatingMoveAlong: Differentiable {
  typealias TangentVector = Empty.TangentVector
  func move(by _: TangentVector) {}
  static func proof_that_i_have_nonmutating_move_along() {
    let empty = Self()
    empty.move(by: .init())
  }
}

protocol DifferentiableWithNonmutatingMoveAlong: Differentiable {}
extension DifferentiableWithNonmutatingMoveAlong {
  func move(by _: TangentVector) {}
}

struct EmptyWithInheritedNonmutatingMoveAlong: DifferentiableWithNonmutatingMoveAlong {
  typealias TangentVector = Empty.TangentVector
  static func proof_that_i_have_nonmutating_move_along() {
    let empty = Self()
    empty.move(by: .init())
  }
}

class EmptyClass: Differentiable {}
func testEmptyClass() {
  assertConformsToAdditiveArithmetic(EmptyClass.TangentVector.self)
}

// Test interaction with `AdditiveArithmetic` derived conformances.
// Previously, this crashed due to duplicate memberwise initializer synthesis.
struct EmptyAdditiveArithmetic: AdditiveArithmetic, Differentiable {}

// Test structs with `let` stored properties.
// Derived conformances fail because `mutating func move` requires all stored
// properties to be mutable.
struct ImmutableStoredProperties: Differentiable {
  var okay: Float

  // expected-warning @+1 {{stored property 'nondiff' has no derivative because 'Int' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
  let nondiff: Int

  // expected-warning @+1 {{synthesis of the 'Differentiable.move(by:)' requirement for 'ImmutableStoredProperties' requires all stored properties not marked with '@noDerivative' to be mutable or have a non-mutating 'move(by:)'; use 'var' instead, or add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
  let diff: Float

  let nonmutatingMoveAlongStruct: EmptyWithConcreteNonmutatingMoveAlong

  let inheritedNonmutatingMoveAlongStruct: EmptyWithInheritedNonmutatingMoveAlong
  
  let diffClass: EmptyClass // No error on class-bound `let` with a non-mutating `move(by:)`.
}
func testImmutableStoredProperties() {
  _ = ImmutableStoredProperties.TangentVector(
    okay: 1, 
    nonmutatingMoveAlongStruct: Empty.TangentVector(), 
    inheritedNonmutatingMoveAlongStruct: Empty.TangentVector(),
    diffClass: EmptyClass.TangentVector())
}
struct MutableStoredPropertiesWithInitialValue: Differentiable {
  var x = Float(1)
  var y = Double(1)
}
// Test struct with both an empty constructor and memberwise initializer.
struct AllMixedStoredPropertiesHaveInitialValue: Differentiable {
  // expected-warning @+1 {{synthesis of the 'Differentiable.move(by:)' requirement for 'AllMixedStoredPropertiesHaveInitialValue' requires all stored properties not marked with '@noDerivative' to be mutable or have a non-mutating 'move(by:)'; use 'var' instead, or add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
  let x = Float(1)
  var y = Float(1)
  // Memberwise initializer should be `init(y:)` since `x` is immutable.
  static func testMemberwiseInitializer() {
    _ = AllMixedStoredPropertiesHaveInitialValue(y: 1)
  }
}
struct HasCustomConstructor: Differentiable {
  var x = Float(1)
  var y = Float(1)
  // Custom constructor should not affect synthesis.
  init(x: Float, y: Float, z: Bool) {}
}

struct Simple: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
}
func testSimple() {
  var simple = Simple(w: 1, b: 1)
  simple.move(by: simple)
}

// Test type with mixed members.
struct Mixed: AdditiveArithmetic, Differentiable {
  var simple: Simple
  var float: Float
}
func testMixed(_ simple: Simple) {
  var mixed = Mixed(simple: simple, float: 1)
  mixed.move(by: mixed)
}

// Test type with manual definition of vector space types to `Self`.
struct VectorSpacesEqualSelf: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
  typealias TangentVector = VectorSpacesEqualSelf
}

// Test generic type with vector space types to `Self`.
struct GenericVectorSpacesEqualSelf<T>: AdditiveArithmetic, Differentiable
where T: Differentiable, T == T.TangentVector {
  var w: T
  var b: T
}
func testGenericVectorSpacesEqualSelf() {
  var genericSame = GenericVectorSpacesEqualSelf<Double>(w: 1, b: 1)
  genericSame.move(by: genericSame)
}

// Test nested type.
struct Nested: AdditiveArithmetic, Differentiable {
  var simple: Simple
  var mixed: Mixed
  var generic: GenericVectorSpacesEqualSelf<Double>
}
func testNested(
  _ simple: Simple, _ mixed: Mixed,
  _ genericSame: GenericVectorSpacesEqualSelf<Double>
) {
  var nested = Nested(simple: simple, mixed: mixed, generic: genericSame)
  nested.move(by: nested)
}

// Test type that does not conform to `AdditiveArithmetic` but whose members do.
// Thus, `Self` cannot be used as `TangentVector` or `TangentVector`.
// Vector space structs types must be synthesized.
// Note: it would be nice to emit a warning if conforming `Self` to
// `AdditiveArithmetic` is possible.
struct AllMembersAdditiveArithmetic: Differentiable {
  var w: Float
  var b: Float
}

// Test type whose properties are not all differentiable.
struct DifferentiableSubset: Differentiable {
  var w: Float
  var b: Float
  @noDerivative var flag: Bool
  @noDerivative let technicallyDifferentiable: Float = .pi
}
func testDifferentiableSubset() {
  _ = DifferentiableSubset.TangentVector(w: 1, b: 1)
  _ = DifferentiableSubset.TangentVector(w: 1, b: 1)
}

// Test nested type whose properties are not all differentiable.
struct NestedDifferentiableSubset: Differentiable {
  var x: DifferentiableSubset
  var mixed: Mixed
  @noDerivative var technicallyDifferentiable: Float
}

// Test type that uses synthesized vector space types but provides custom
// method.
struct HasCustomMethod: Differentiable {
  var simple: Simple
  var mixed: Mixed
  var generic: GenericVectorSpacesEqualSelf<Double>
  mutating func move(by offset: TangentVector) {
    print("Hello world")
    simple.move(by: offset.simple)
    mixed.move(by: offset.mixed)
    generic.move(by: offset.generic)
  }
}

// Test type with user-defined memberwise initializer.
struct TF_25: Differentiable {
  public var bar: Float
  public init(bar: Float) {
    self.bar = bar
  }
}
// Test user-defined memberwise initializer.
struct TF_25_Generic<T: Differentiable>: Differentiable {
  public var bar: T
  public init(bar: T) {
    self.bar = bar
  }
}

// Test initializer that is not a memberwise initializer because of stored property name vs parameter label mismatch.
struct HasCustomNonMemberwiseInitializer<T: Differentiable>: Differentiable {
  var value: T
  init(randomLabel value: T) { self.value = value }
}

// Test type with generic environment.
struct HasGenericEnvironment<Scalar: FloatingPoint & Differentiable>: Differentiable
{
  var x: Float
}

// Test type with generic members that conform to `Differentiable`.
struct GenericSynthesizeAllStructs<T: Differentiable>: Differentiable {
  var w: T
  var b: T
}

// Test type in generic context.
struct A<T: Differentiable> {
  struct B<U: Differentiable, V>: Differentiable {
    struct InGenericContext: Differentiable {
      @noDerivative var a: A
      var b: B
      var t: T
      var u: U
    }
  }
}

// Test extension.
struct Extended {
  var x: Float
}
extension Extended: Differentiable {}

// Test extension of generic type.
struct GenericExtended<T> {
  var x: T
}
extension GenericExtended: Differentiable where T: Differentiable {}

// Test constrained extension of generic type.
struct GenericConstrained<T> {
  var x: T
}
extension GenericConstrained: Differentiable
where T: Differentiable {}

struct TF_260<T: Differentiable>: Differentiable, AdditiveArithmetic {
  var x: T.TangentVector
}

// TF-269: Test crash when differentiation properties have no getter.
// Related to access levels and associated type inference.
public protocol TF_269_Layer: Differentiable {
  associatedtype Input: Differentiable
  associatedtype Output: Differentiable
  func applied(to input: Input) -> Output
}

public struct TF_269: TF_269_Layer {
  public var filter: Float
  public typealias Activation = @differentiable(reverse) (Output) -> Output
  @noDerivative public let activation: Activation

  public func applied(to input: Float) -> Float {
    return input
  }
}

// Test errors.

// Test manually customizing vector space types.
// These should fail. Synthesis is semantically unsupported if vector space
// types are customized.
// expected-error @+1 {{type 'VectorSpaceTypeAlias' does not conform to protocol 'Differentiable'}}
struct VectorSpaceTypeAlias: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
  typealias TangentVector = Simple
}
// expected-error @+1 {{type 'VectorSpaceCustomStruct' does not conform to protocol 'Differentiable'}}
struct VectorSpaceCustomStruct: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
  struct TangentVector: AdditiveArithmetic, Differentiable {
    var w: Float.TangentVector
    var b: Float.TangentVector
    typealias TangentVector = VectorSpaceCustomStruct.TangentVector
  }
}

struct StaticNoDerivative: Differentiable {
  @noDerivative static var s: Bool = true
}

struct StaticMembersShouldNotAffectAnything: AdditiveArithmetic, Differentiable
{
  static var x: Bool = true
  static var y: Bool = false
}

struct ImplicitNoDerivative: Differentiable {
  var a: Float
  var b: Bool  // expected-warning {{stored property 'b' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
}

struct ImplicitNoDerivativeWithSeparateTangent: Differentiable {
  var x: DifferentiableSubset
  var b: Bool  // expected-warning {{stored property 'b' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
}

// TF-1018: verify that `@noDerivative` warnings are always silenceable, even
// when the `Differentiable` conformance context is not the nominal type
// declaration.

struct ExtensionDifferentiableNoDerivative<T> {
  // expected-warning @+2 {{stored property 'x' has no derivative because 'T' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  // expected-warning @+1 {{stored property 'y' has no derivative because 'T' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  var x, y: T
  // expected-warning @+1 {{stored property 'nondiff' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  var nondiff: Bool
}
extension ExtensionDifferentiableNoDerivative: Differentiable {}

struct ExtensionDifferentiableNoDerivativeFixed<T> {
  @noDerivative var x, y: T
  @noDerivative var nondiff: Bool
}
extension ExtensionDifferentiableNoDerivativeFixed: Differentiable {}

struct ConditionalDifferentiableNoDerivative<T> {
  var x, y: T
  // expected-warning @+1 {{stored property 'nondiff' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  var nondiff: Bool
}
extension ConditionalDifferentiableNoDerivative: Differentiable
where T: Differentiable {}

struct ConditionalDifferentiableNoDerivativeFixed<T> {
  var x, y: T
  @noDerivative var nondiff: Bool
}
extension ConditionalDifferentiableNoDerivativeFixed: Differentiable
where T: Differentiable {}

// TF-265: Test invalid initializer (that uses a non-existent type).
struct InvalidInitializer: Differentiable {
  init(filterShape: (Int, Int, Int, Int), blah: NonExistentType) {}  // expected-error {{cannot find type 'NonExistentType' in scope}}
}

// Test memberwise initializer synthesis.
struct NoMemberwiseInitializerExtended<T> {
  var value: T
  init(_ value: T) {
    self.value = value
  }
}
extension NoMemberwiseInitializerExtended: Equatable, AdditiveArithmetic
where T: AdditiveArithmetic {}
extension NoMemberwiseInitializerExtended: Differentiable
where T: Differentiable & AdditiveArithmetic {}

// https://github.com/apple/swift/issues/55238
// Test interaction with `@differentiable` and `@derivative` type-checking.

struct S_55238: Differentiable {
  var x: Float

  @differentiable(reverse)
  func method() -> Float { x }

  @derivative(of: method)
  func vjpMethod() -> (value: Float, pullback: (Float) -> TangentVector) { fatalError() }

  // Test usage of synthesized `TangentVector` type.
  // This should not produce an error: "reference to invalid associated type 'TangentVector'".
  mutating func move(by offset: TangentVector) {}
}

// Test property wrappers.

@propertyWrapper
struct ImmutableWrapper<Value> {
  private var value: Value
  var wrappedValue: Value { value }
}

@propertyWrapper
struct Wrapper<Value> {
  var wrappedValue: Value
}

@propertyWrapper
class ClassWrapper<Value> {
  var wrappedValue: Value
  init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}

struct Generic<T> {}
extension Generic: Differentiable where T: Differentiable {}

struct WrappedProperties: Differentiable {
  // expected-warning @+1 {{synthesis of the 'Differentiable.move(by:)' requirement for 'WrappedProperties' requires 'wrappedValue' in property wrapper 'ImmutableWrapper' to be mutable or have a non-mutating 'move(by:)'; add an explicit '@noDerivative' attribute}}
  @ImmutableWrapper var immutableInt: Generic<Int>

  // expected-warning @+1 {{stored property 'mutableInt' has no derivative because 'Generic<Int>' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  @Wrapper var mutableInt: Generic<Int>

  @Wrapper var float: Generic<Float>
  @ClassWrapper var float2: Generic<Float>

  // https://github.com/apple/swift/issues/55517
  // Test `@differentiable` wrapped property.
  @differentiable(reverse) @Wrapper var float3: Generic<Float>

  @noDerivative @ImmutableWrapper var nondiff: Generic<Int>

  static func testTangentMemberwiseInitializer() {
    _ = TangentVector(float: .init(), float2: .init(), float3: .init())
  }
}

// Verify that cross-file derived conformances are disallowed.

extension OtherFileNonconforming: Differentiable {}
// expected-error@-1 {{extension outside of file declaring struct 'OtherFileNonconforming' prevents automatic synthesis of 'move(by:)' for protocol 'Differentiable'}}
// expected-note@-2 {{add stubs for conformance}}

extension GenericOtherFileNonconforming: Differentiable {}
// expected-error@-1 {{extension outside of file declaring generic struct 'GenericOtherFileNonconforming' prevents automatic synthesis of 'move(by:)' for protocol 'Differentiable'}}
// expected-note@-2 {{add stubs for conformance}}
// --- Seed B ---
// RUN: %target-swift-frontend -typecheck -verify -verify-ignore-unrelated -primary-file %s %S/Inputs/struct_differentiable_other_module.swift


// Verify that a type `T` conforms to `AdditiveArithmetic`.
func assertConformsToAdditiveArithmetic_b93a83d<T>(_: T.Type)
where T: AdditiveArithmetic {}

struct Empty_b93a83d: Differentiable {}
func testEmpty_b93a83d() {
  assertConformsToAdditiveArithmetic_b93a83d(Empty_b93a83d.TangentVector.self)
}

struct EmptyWithConcreteNonmutatingMoveAlong_b93a83d: Differentiable {
  typealias TangentVector = Empty_b93a83d.TangentVector
  func move(by _: TangentVector) {}
  static func proof_that_i_have_nonmutating_move_along() {
    let empty = Self()
    empty.move(by: .init())
  }
}

protocol DifferentiableWithNonmutatingMoveAlong_b93a83d: Differentiable {}
extension DifferentiableWithNonmutatingMoveAlong_b93a83d {
  func move(by _: TangentVector) {}
}

struct EmptyWithInheritedNonmutatingMoveAlong_b93a83d: DifferentiableWithNonmutatingMoveAlong_b93a83d {
  typealias TangentVector = Empty_b93a83d.TangentVector
  static func proof_that_i_have_nonmutating_move_along() {
    let empty = Self()
    empty.move(by: .init())
  }
}

class EmptyClass_b93a83d: Differentiable {}
func testEmptyClass_b93a83d() {
  assertConformsToAdditiveArithmetic_b93a83d(EmptyClass_b93a83d.TangentVector.self)
}

// Test interaction with `AdditiveArithmetic` derived conformances.
// Previously, this crashed due to duplicate memberwise initializer synthesis.
struct EmptyAdditiveArithmetic_b93a83d: AdditiveArithmetic, Differentiable {}

// Test structs with `let` stored properties.
// Derived conformances fail because `mutating func move` requires all stored
// properties to be mutable.
struct ImmutableStoredProperties_b93a83d: Differentiable {
  var okay: Float

  // expected-warning @+1 {{stored property 'nondiff' has no derivative because 'Int' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
  let nondiff: Int

  // expected-warning @+1 {{synthesis of the 'Differentiable.move(by:)' requirement for 'ImmutableStoredProperties_b93a83d' requires all stored properties not marked with '@noDerivative' to be mutable or have a non-mutating 'move(by:)'; use 'var' instead, or add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
  let diff: Float

  let nonmutatingMoveAlongStruct: EmptyWithConcreteNonmutatingMoveAlong_b93a83d

  let inheritedNonmutatingMoveAlongStruct: EmptyWithInheritedNonmutatingMoveAlong_b93a83d
  
  let diffClass: EmptyClass_b93a83d // No error on class-bound `let` with a non-mutating `move(by:)`.
}
func testImmutableStoredProperties_b93a83d() {
  _ = ImmutableStoredProperties_b93a83d.TangentVector(
    okay: 1, 
    nonmutatingMoveAlongStruct: Empty_b93a83d.TangentVector(), 
    inheritedNonmutatingMoveAlongStruct: Empty_b93a83d.TangentVector(),
    diffClass: EmptyClass_b93a83d.TangentVector())
}
struct MutableStoredPropertiesWithInitialValue_b93a83d: Differentiable {
  var x = Float(1)
  var y = Double(1)
}
// Test struct with both an empty constructor and memberwise initializer.
struct AllMixedStoredPropertiesHaveInitialValue_b93a83d: Differentiable {
  // expected-warning @+1 {{synthesis of the 'Differentiable.move(by:)' requirement for 'AllMixedStoredPropertiesHaveInitialValue_b93a83d' requires all stored properties not marked with '@noDerivative' to be mutable or have a non-mutating 'move(by:)'; use 'var' instead, or add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
  let x = Float(1)
  var y = Float(1)
  // Memberwise initializer should be `init(y:)` since `x` is immutable.
  static func testMemberwiseInitializer() {
    _ = AllMixedStoredPropertiesHaveInitialValue_b93a83d(y: 1)
  }
}
struct HasCustomConstructor_b93a83d: Differentiable {
  var x = Float(1)
  var y = Float(1)
  // Custom constructor should not affect synthesis.
  init(x: Float, y: Float, z: Bool) {}
}

struct Simple_b93a83d: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
}
func testSimple_b93a83d() {
  var simple = Simple_b93a83d(w: 1, b: 1)
  simple.move(by: simple)
}

// Test type with mixed members.
struct Mixed_b93a83d: AdditiveArithmetic, Differentiable {
  var simple: Simple_b93a83d
  var float: Float
}
func testMixed_b93a83d(_ simple: Simple_b93a83d) {
  var mixed = Mixed_b93a83d(simple: simple, float: 1)
  mixed.move(by: mixed)
}

// Test type with manual definition of vector space types to `Self`.
struct VectorSpacesEqualSelf_b93a83d: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
  typealias TangentVector = VectorSpacesEqualSelf_b93a83d
}

// Test generic type with vector space types to `Self`.
struct GenericVectorSpacesEqualSelf_b93a83d<T>: AdditiveArithmetic, Differentiable
where T: Differentiable, T == T.TangentVector {
  var w: T
  var b: T
}
func testGenericVectorSpacesEqualSelf_b93a83d() {
  var genericSame = GenericVectorSpacesEqualSelf_b93a83d<Double>(w: 1, b: 1)
  genericSame.move(by: genericSame)
}

// Test nested type.
struct Nested_b93a83d: AdditiveArithmetic, Differentiable {
  var simple: Simple_b93a83d
  var mixed: Mixed_b93a83d
  var generic: GenericVectorSpacesEqualSelf_b93a83d<Double>
}
func testNested_b93a83d(
  _ simple: Simple_b93a83d, _ mixed: Mixed_b93a83d,
  _ genericSame: GenericVectorSpacesEqualSelf_b93a83d<Double>
) {
  var nested = Nested_b93a83d(simple: simple, mixed: mixed, generic: genericSame)
  nested.move(by: nested)
}

// Test type that does not conform to `AdditiveArithmetic` but whose members do.
// Thus, `Self` cannot be used as `TangentVector` or `TangentVector`.
// Vector space structs types must be synthesized.
// Note: it would be nice to emit a warning if conforming `Self` to
// `AdditiveArithmetic` is possible.
struct AllMembersAdditiveArithmetic_b93a83d: Differentiable {
  var w: Float
  var b: Float
}

// Test type whose properties are not all differentiable.
struct DifferentiableSubset_b93a83d: Differentiable {
  var w: Float
  var b: Float
  @noDerivative var flag: Bool
  @noDerivative let technicallyDifferentiable: Float = .pi
}
func testDifferentiableSubset_b93a83d() {
  _ = DifferentiableSubset_b93a83d.TangentVector(w: 1, b: 1)
  _ = DifferentiableSubset_b93a83d.TangentVector(w: 1, b: 1)
}

// Test nested type whose properties are not all differentiable.
struct NestedDifferentiableSubset_b93a83d: Differentiable {
  var x: DifferentiableSubset_b93a83d
  var mixed: Mixed_b93a83d
  @noDerivative var technicallyDifferentiable: Float
}

// Test type that uses synthesized vector space types but provides custom
// method.
struct HasCustomMethod_b93a83d: Differentiable {
  var simple: Simple_b93a83d
  var mixed: Mixed_b93a83d
  var generic: GenericVectorSpacesEqualSelf_b93a83d<Double>
  mutating func move(by offset: TangentVector) {
    print("Hello world")
    simple.move(by: offset.simple)
    mixed.move(by: offset.mixed)
    generic.move(by: offset.generic)
  }
}

// Test type with user-defined memberwise initializer.
struct TF_25_b93a83d: Differentiable {
  public var bar: Float
  public init(bar: Float) {
    self.bar = bar
  }
}
// Test user-defined memberwise initializer.
struct TF_25_Generic_b93a83d<T: Differentiable>: Differentiable {
  public var bar: T
  public init(bar: T) {
    self.bar = bar
  }
}

// Test initializer that is not a memberwise initializer because of stored property name vs parameter label mismatch.
struct HasCustomNonMemberwiseInitializer_b93a83d<T: Differentiable>: Differentiable {
  var value: T
  init(randomLabel value: T) { self.value = value }
}

// Test type with generic environment.
struct HasGenericEnvironment_b93a83d<Scalar: FloatingPoint & Differentiable>: Differentiable
{
  var x: Float
}

// Test type with generic members that conform to `Differentiable`.
struct GenericSynthesizeAllStructs_b93a83d<T: Differentiable>: Differentiable {
  var w: T
  var b: T
}

// Test type in generic context.
struct A_b93a83d<T: Differentiable> {
  struct B<U: Differentiable, V>: Differentiable {
    struct InGenericContext: Differentiable {
      @noDerivative var a: A_b93a83d
      var b: B
      var t: T
      var u: U
    }
  }
}

// Test extension.
struct Extended_b93a83d {
  var x: Float
}
extension Extended_b93a83d: Differentiable {}

// Test extension of generic type.
struct GenericExtended_b93a83d<T> {
  var x: T
}
extension GenericExtended_b93a83d: Differentiable where T: Differentiable {}

// Test constrained extension of generic type.
struct GenericConstrained_b93a83d<T> {
  var x: T
}
extension GenericConstrained_b93a83d: Differentiable
where T: Differentiable {}

struct TF_260_b93a83d<T: Differentiable>: Differentiable, AdditiveArithmetic {
  var x: T.TangentVector
}

// TF-269: Test crash when differentiation properties have no getter.
// Related to access levels and associated type inference.
public protocol TF_269_Layer_b93a83d: Differentiable {
  associatedtype Input: Differentiable
  associatedtype Output: Differentiable
  func applied(to input: Input) -> Output
}

public struct TF_269_b93a83d: TF_269_Layer_b93a83d {
  public var filter: Float
  public typealias Activation = @differentiable(reverse) (Output) -> Output
  @noDerivative public let activation: Activation

  public func applied(to input: Float) -> Float {
    return input
  }
}

// Test errors.

// Test manually customizing vector space types.
// These should fail. Synthesis is semantically unsupported if vector space
// types are customized.
// expected-error @+1 {{type 'VectorSpaceTypeAlias_b93a83d' does not conform to protocol 'Differentiable'}}
struct VectorSpaceTypeAlias_b93a83d: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
  typealias TangentVector = Simple_b93a83d
}
// expected-error @+1 {{type 'VectorSpaceCustomStruct_b93a83d' does not conform to protocol 'Differentiable'}}
struct VectorSpaceCustomStruct_b93a83d: AdditiveArithmetic, Differentiable {
  var w: Float
  var b: Float
  struct TangentVector: AdditiveArithmetic, Differentiable {
    var w: Float.TangentVector
    var b: Float.TangentVector
    typealias TangentVector = VectorSpaceCustomStruct_b93a83d.TangentVector
  }
}

struct StaticNoDerivative_b93a83d: Differentiable {
  @noDerivative static var s: Bool = true
}

struct StaticMembersShouldNotAffectAnything_b93a83d: AdditiveArithmetic, Differentiable
{
  static var x: Bool = true
  static var y: Bool = false
}

struct ImplicitNoDerivative_b93a83d: Differentiable {
  var a: Float
  var b: Bool  // expected-warning {{stored property 'b' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
}

struct ImplicitNoDerivativeWithSeparateTangent_b93a83d: Differentiable {
  var x: DifferentiableSubset_b93a83d
  var b: Bool  // expected-warning {{stored property 'b' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}} {{3-3=@noDerivative }}
}

// TF-1018: verify that `@noDerivative` warnings are always silenceable, even
// when the `Differentiable` conformance context is not the nominal type
// declaration.

struct ExtensionDifferentiableNoDerivative_b93a83d<T> {
  // expected-warning @+2 {{stored property 'x' has no derivative because 'T' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  // expected-warning @+1 {{stored property 'y' has no derivative because 'T' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  var x, y: T
  // expected-warning @+1 {{stored property 'nondiff' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  var nondiff: Bool
}
extension ExtensionDifferentiableNoDerivative_b93a83d: Differentiable {}

struct ExtensionDifferentiableNoDerivativeFixed_b93a83d<T> {
  @noDerivative var x, y: T
  @noDerivative var nondiff: Bool
}
extension ExtensionDifferentiableNoDerivativeFixed_b93a83d: Differentiable {}

struct ConditionalDifferentiableNoDerivative_b93a83d<T> {
  var x, y: T
  // expected-warning @+1 {{stored property 'nondiff' has no derivative because 'Bool' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  var nondiff: Bool
}
extension ConditionalDifferentiableNoDerivative_b93a83d: Differentiable
where T: Differentiable {}

struct ConditionalDifferentiableNoDerivativeFixed_b93a83d<T> {
  var x, y: T
  @noDerivative var nondiff: Bool
}
extension ConditionalDifferentiableNoDerivativeFixed_b93a83d: Differentiable
where T: Differentiable {}

// TF-265: Test invalid initializer (that uses a non-existent type).
struct InvalidInitializer_b93a83d: Differentiable {
  init(filterShape: (Int, Int, Int, Int), blah: NonExistentType) {}  // expected-error {{cannot find type 'NonExistentType' in scope}}
}

// Test memberwise initializer synthesis.
struct NoMemberwiseInitializerExtended_b93a83d<T> {
  var value: T
  init(_ value: T) {
    self.value = value
  }
}
extension NoMemberwiseInitializerExtended_b93a83d: Equatable, AdditiveArithmetic
where T: AdditiveArithmetic {}
extension NoMemberwiseInitializerExtended_b93a83d: Differentiable
where T: Differentiable & AdditiveArithmetic {}

// https://github.com/apple/swift/issues/55238
// Test interaction with `@differentiable` and `@derivative` type-checking.

struct S_55238_b93a83d: Differentiable {
  var x: Float

  @differentiable(reverse)
  func method() -> Float { x }

  @derivative(of: method)
  func vjpMethod() -> (value: Float, pullback: (Float) -> TangentVector) { fatalError() }

  // Test usage of synthesized `TangentVector` type.
  // This should not produce an error: "reference to invalid associated type 'TangentVector'".
  mutating func move(by offset: TangentVector) {}
}

// Test property wrappers.

@propertyWrapper
struct ImmutableWrapper_b93a83d<Value> {
  private var value: Value
  var wrappedValue: Value { value }
}

@propertyWrapper
struct Wrapper_b93a83d<Value> {
  var wrappedValue: Value
}

@propertyWrapper
class ClassWrapper_b93a83d<Value> {
  var wrappedValue: Value
  init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}

struct Generic_b93a83d<T> {}
extension Generic_b93a83d: Differentiable where T: Differentiable {}

struct WrappedProperties_b93a83d: Differentiable {
  // expected-warning @+1 {{synthesis of the 'Differentiable.move(by:)' requirement for 'WrappedProperties_b93a83d' requires 'wrappedValue' in property wrapper 'ImmutableWrapper_b93a83d' to be mutable or have a non-mutating 'move(by:)'; add an explicit '@noDerivative' attribute}}
  @ImmutableWrapper_b93a83d var immutableInt: Generic_b93a83d<Int>

  // expected-warning @+1 {{stored property 'mutableInt' has no derivative because 'Generic_b93a83d<Int>' does not conform to 'Differentiable'; add an explicit '@noDerivative' attribute}}
  @Wrapper_b93a83d var mutableInt: Generic_b93a83d<Int>

  @Wrapper_b93a83d var float: Generic_b93a83d<Float>
  @ClassWrapper_b93a83d var float2: Generic_b93a83d<Float>

  // https://github.com/apple/swift/issues/55517
  // Test `@differentiable` wrapped property.
  @differentiable(reverse) @Wrapper_b93a83d var float3: Generic_b93a83d<Float>

  @noDerivative @ImmutableWrapper_b93a83d var nondiff: Generic_b93a83d<Int>

  static func testTangentMemberwiseInitializer() {
    _ = TangentVector(float: .init(), float2: .init(), float3: .init())
  }
}

// Verify that cross-file derived conformances are disallowed.

extension OtherFileNonconforming: Differentiable {}
// expected-error@-1 {{extension outside of file declaring struct 'OtherFileNonconforming' prevents automatic synthesis of 'move(by:)' for protocol 'Differentiable'}}
// expected-note@-2 {{add stubs for conformance}}

extension GenericOtherFileNonconforming: Differentiable {}
// expected-error@-1 {{extension outside of file declaring generic struct 'GenericOtherFileNonconforming' prevents automatic synthesis of 'move(by:)' for protocol 'Differentiable'}}
// expected-note@-2 {{add stubs for conformance}}
// --- Bug Primitive ---

// P2: Existential boxing / any-Protocol metatype stress
protocol _FflShape {
    func area() -> Double
    var tag: String { get }
}
struct _FflCircle: _FflShape {
    let r: Double
    func area() -> Double { .pi * r * r }
    var tag: String { "circle" }
}
struct _FflRect: _FflShape {
    let w, h: Double
    func area() -> Double { w * h }
    var tag: String { "rect" }
}
func _ffl_p2_sum(_ shapes: [any _FflShape]) -> Double {
    shapes.reduce(0.0) { $0 + $1.area() }
}
do {
    let _ffl_r = Double(String(describing: y).count)
    let _ffl_shapes: [any _FflShape] = [_FflCircle(r: _ffl_r), _FflRect(w: _ffl_r, h: 2.0)]
    _ = _ffl_p2_sum(_ffl_shapes)
    let _ffl_meta: any _FflShape.Type = _FflCircle.self
    _ = _ffl_meta.init(r: _ffl_r)
}
