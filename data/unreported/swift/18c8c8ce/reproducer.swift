import _Differentiation

// --- Seed A ---
// RUN: %target-typecheck-verify-swift -playground
// RUN: %target-swift-frontend -emit-sil -verify %s

// Test differentiation transform diagnostics.


//===----------------------------------------------------------------------===//
// Basic function
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func basic(_ x: Float) -> Float {
  return x
}

//===----------------------------------------------------------------------===//
// Control flow
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func conditional(_ x: Float, _ flag: Bool) -> Float {
  let y: Float
  if flag {
    y = x
  } else {
    y = x
  }
  return y
}

// TF-433: Test `try_apply` differentiation.

func throwing() throws -> Void {}

@differentiable(reverse)
func try_apply(_ x: Float) -> Float {
  try! throwing()
  return x
}

func rethrowing(_ x: () throws -> Void) rethrows -> Void {}

@differentiable(reverse)
func try_apply_rethrows(_ x: Float) -> Float {
  rethrowing({})
  return x
}

func throwing_result(_ x: Float) throws -> Float { return x; }

@differentiable(reverse)
func active_try_apply(_ x: Float) -> Float {
  do {
    return try throwing_result(x);
  } catch {
    return x
  }
}

@differentiable(reverse)
func map_nondiff(_ a: [Float]) -> [Float] {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate functions that have not been marked '@differentiable' and that are defined in other files}}
  return a.map { $0 }
}

//===----------------------------------------------------------------------===//
// Unreachable
//===----------------------------------------------------------------------===//

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse)
func noReturn(_ x: Float) -> Float {
  let _ = x
  // expected-error @+2 {{missing return in global function expected to return 'Float'}}
  // expected-note @+1 {{missing return for differentiation}}
}

//===----------------------------------------------------------------------===//
// Global variables
//===----------------------------------------------------------------------===//

var global: Float = 3.0

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse, wrt: x)
func testWriteToGlobalVariable(x: Float) -> Float {
  // expected-note @+1 {{cannot differentiate writes to global variables}}
  global = global + x
  return global
}

//===----------------------------------------------------------------------===//
// Class differentiation
//===----------------------------------------------------------------------===//

class Class : Differentiable {
  @differentiable(reverse)
  var stored: Float = 1

  @differentiable(reverse)
  func testRefElementAddr(_ x: Float) -> Float {
    return stored * x
  }

  var nonDifferentiableStored: Float = 1

  @differentiable(reverse)
  func testNonDifferentiableRefElementAddr(_ x: Float) -> Float {
    // expected-error @+2 {{expression is not differentiable}}
    // expected-note @+1 {{member is not differentiable because the corresponding class member is not '@differentiable'}}
    return nonDifferentiableStored * x
  }

  @differentiable(reverse)
  func method(_ x: Float) -> Float { x }

  @differentiable(reverse)
  static func testClassMethod(x: Float) -> Float {
    return Class().method(x)
  }

  func nonDifferentiableMethod(_ x: Float) -> Float { x }

  @differentiable(reverse)
  static func testDifferentiableClassMethod(x: Float) -> Float {
    // expected-error @+2 {{expression is not differentiable}}
    // expected-note @+1 {{member is not differentiable because the corresponding class member is not '@differentiable'}}
    return Class().nonDifferentiableMethod(x)
  }
}

// TF-676: Test differentiation of class method with multiple `@differentiable`
// attributes.
class ClassMethodMultipleDifferentiableAttribute : Differentiable {
  @differentiable(reverse, wrt: (self, x))
  @differentiable(reverse, wrt: x)
  func f(_ x: Float) -> Float { x }
}
func testMultipleDiffAttrsClass<C: ClassMethodMultipleDifferentiableAttribute>(
  _ c: C, _ x: Float
) {
  _ = gradient(at: c, x) { c, x in c.f(x) }
  _ = gradient(at: x) { x in c.f(x) }
}

// TF-1149: Test class with loadable type but address-only `TangentVector` type.
class C<T: Differentiable>: Differentiable {
  @differentiable(reverse)
  var stored: T

  init(_ stored: T) {
    self.stored = stored
  }

  @differentiable(reverse)
  func method(_ x: T) -> T {
    stored
  }
}

//===----------------------------------------------------------------------===//
// Enum differentiation
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func usesOptionals(_ x: Float) -> Float {
  var maybe: Float? = 10
  maybe = x
  return maybe!
}

enum DirectEnum: Differentiable & AdditiveArithmetic {
  case leaf(Float)

  typealias TangentVector = Self

  static var zero: Self { fatalError() }
  static func +(_ lhs: Self, _ rhs: Self) -> Self { fatalError() }
  static func -(_ lhs: Self, _ rhs: Self) -> Self { fatalError() }
}

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse, wrt: e)
// expected-note @+2 {{when differentiating this function definition}}

var a = 1, b = 2
let z = 3

a
(a, b)
(a, z)
// expected-note @+1 {{differentiating enum values is not yet supported}}
func enum_active(_ e: DirectEnum, _ x: Float) -> Float {
  switch e {
  case let .leaf(y): return y
  }
}

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse, wrt: e)
// expected-note @+2 {{when differentiating this function definition}}
// expected-note @+1 {{differentiating enum values is not yet supported}}
func activeEnumValue(_ e: DirectEnum, _ x: Float) -> Float {
  switch e {
  case let .leaf(y): return y
  }
}

enum IndirectEnum<T: Differentiable>: Differentiable & AdditiveArithmetic {
  case leaf(T)

  typealias TangentVector = Self

  static func ==(_ lhs: Self, _ rhs: Self) -> Bool { fatalError() }
  static var zero: Self { fatalError() }
  static func +(_ lhs: Self, _ rhs: Self) -> Self { fatalError() }
  static func -(_ lhs: Self, _ rhs: Self) -> Self { fatalError() }
}

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse, wrt: e)
// expected-note @+2 {{when differentiating this function definition}}
// expected-note @+1 {{differentiating enum values is not yet supported}}
func activeEnumAddr(_ e: IndirectEnum<Float>, _ x: Float) -> Float {
  switch e {
  case let .leaf(y): return y
  }
}

//===----------------------------------------------------------------------===//
// Unmet derivative generic requirements
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func generic<T: Differentiable & FloatingPoint>(_ x: T) -> T {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{member is not differentiable because the corresponding protocol requirement is not '@differentiable'}}
  return x + 1
}

// Test unmet generic requirements.

func weird<T>(_ x: T) -> T {
  return x
}
@derivative(of: weird)
func vjpWeirdExtraRequirements<T : Differentiable & CaseIterable>(_ x: T) -> (
  value: T, pullback: (T.TangentVector) -> T.TangentVector
) where T.AllCases : ExpressibleByStringLiteral {
  return (x, { $0 })
}
@differentiable(reverse)
func weirdWrapper<T : Differentiable>(_ x: T) -> T {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{function call is not differentiable because generic requirements are not met: 'T : CaseIterable, T.AllCases : ExpressibleByStringLiteral'}}
  return weird(x)
}

@differentiable(reverse)
func direct<T : Differentiable>(_ x: T) -> T {
  return x
}

struct Tensor<Scalar> {
  static func + (_ lhs: Tensor, rhs: Scalar) -> Tensor { return lhs }
}
extension Tensor : Differentiable where Scalar : Differentiable & FloatingPoint {}
extension Tensor where Scalar : BinaryFloatingPoint {
  @differentiable(reverse, wrt: self where Scalar : Differentiable)
  func TF_6(_ x: Float) -> Tensor {
    return self + Scalar(x)
  }
}

protocol TF8_Proto : Differentiable {
  associatedtype Scalar
  @differentiable(reverse, wrt: (self, input))
  func applied(to input: Float) -> Float
}

struct TF8_Struct<Scalar> : TF8_Proto where Scalar : FloatingPoint & Differentiable {
  @noDerivative let bar: Scalar

  @differentiable(reverse, wrt: (self, input))
  func applied(to input: Float) -> Float {
    return input
  }
}

//===----------------------------------------------------------------------===//
// `Differentiable` conformance requirement inference
//===----------------------------------------------------------------------===//

func id<T>(_ x: T) -> T { x }
let _: @differentiable(reverse) (Float) -> Float = { x in id(x) }

struct TF_691<Scalar> {
  var x: Scalar
  init(_ x: Scalar) {
    self.x = x
  }
}
extension TF_691: Differentiable where Scalar: Differentiable {}

func identity<T>(_ x: TF_691<T>) -> TF_691<T> { x }
let _: @differentiable(reverse) (Float) -> TF_691<Float> = { x in identity(TF_691(x)) }
let _: @differentiable(reverse) (Float) -> TF_691<Float> = { x in id(TF_691(x)) }

//===----------------------------------------------------------------------===//
// Non-differentiable arguments and results
//===----------------------------------------------------------------------===//

struct TF_687<T> : Differentiable {
  @noDerivative var indirectDummy: T
  var base: Float

  init(_ base: Float, dummy: T) {
    self.base = base
    self.indirectDummy = dummy
  }
}
// expected-error @+2 {{function is not differentiable}}
// expected-note @+1 {{cannot differentiate through a non-differentiable argument; do you want to use 'withoutDerivative(at:)'?}} {{87-87=withoutDerivative(at: }} {{88-88=)}}
let _: @differentiable(reverse) (Float) -> TF_687<Any> = { x in TF_687<Any>(x, dummy: x) }

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse)
// expected-note @+1 {{when differentiating this function definition}}
func roundingGivesError(x: Float) -> Float {
  // expected-note @+1 {{cannot differentiate through a non-differentiable result; do you want to use 'withoutDerivative(at:)'?}} {{16-16=withoutDerivative(at: }} {{22-22=)}}
  return Float(Int(x))
}

//===----------------------------------------------------------------------===//
// Non-varied results
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func nonVariedResult(_ x: Float) -> Float {
  // TODO(TF-788): Re-enable non-varied result warning.
  // xpected-warning @+1 {{result does not depend on differentiation arguments and will always have a zero derivative; do you want to use 'withoutDerivative(at:)'?}} {{10-10=withoutDerivative(at:}} {{15-15=)}}
  return 0
}

// Check that `withoutDerivative(at:)` silences the non-varied result warning.

struct TF_775: Differentiable {
  @differentiable(reverse, wrt: (self))
  func nonVariedResult(_ input: Float) -> Float {
    return withoutDerivative(at: input)
  }
}

//===----------------------------------------------------------------------===//
// Multiple results
//===----------------------------------------------------------------------===//

func multipleResults(_ x: Float) -> (Float, Float) {
  return (x, x)
}

@differentiable(reverse)
func usesMultipleResults(_ x: Float) -> Float {
  let tuple = multipleResults(x)
  return tuple.0 + tuple.1
}

//===----------------------------------------------------------------------===//
// `inout` parameter differentiation
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func activeInoutParam(_ x: Float) -> Float {
  var result = x
  result += x
  return result
}

@differentiable(reverse)
func activeInoutParamNonactiveInitialResult(_ x: Float) -> Float {
  var result: Float = 1
  result += x
  return result
}

@differentiable(reverse)
func activeInoutParamTuple(_ x: Float) -> Float {
  var tuple = (x, x)
  tuple.0 *= x
  return x * tuple.0
}

@differentiable(reverse)
func activeInoutParamControlFlow(_ array: [Float]) -> Float {
  var result: Float = 1
  for i in withoutDerivative(at: array).indices {
    result += array[i]
  }
  return result
}

@differentiable(reverse)
func activeInoutParamControlFlowComplex(_ array: [Float], _ bool: Bool) -> Float {
  var result: Float = 1
  if bool {
    if bool {}
    for i in withoutDerivative(at: array).indices {
      switch i % 2 {
      case 0: continue
      case 1: break
      default: break
      }
      result = result + 1
      result += array[i]
    }
  }
  return result
}

struct Mut: Differentiable {}
extension Mut {
  @differentiable(reverse, wrt: (self, x))
  mutating func mutatingMethod(_ x: Mut) {}
}

@differentiable(reverse, wrt: (nonactive, x))
func nonActiveInoutParam(_ nonactive: inout Mut, _ x: Mut) {
  nonactive.mutatingMethod(x)
}

@differentiable(reverse, wrt: x)
func activeInoutParamMutatingMethod(_ x: Mut) -> Mut {
  var result = x
  result.mutatingMethod(result)
  return result
}

@differentiable(reverse, wrt: (nonactive, x))
func activeInoutParamMutatingMethodVar(_ nonactive: inout Mut, _ x: Mut) {
  var result = nonactive
  result.mutatingMethod(x)
  nonactive = result
}

@differentiable(reverse, wrt: (nonactive, x))
func activeInoutParamMutatingMethodTuple(_ nonactive: inout Mut, _ x: Mut) {
  var result = (nonactive, x)
  result.0.mutatingMethod(result.0)
  nonactive = result.0
}

func twoInoutParameters(_ x: inout Float, _ y: inout Float) {}
@differentiable(reverse)
func testTwoInoutParameters(_ x: Float, _ y: Float) -> Float {
  var x = x
  var y = y
  twoInoutParameters(&x, &y)
  return x
}

func inoutParameterAndFormalResult(_ x: inout Float) -> Float { x }
@differentiable(reverse)
func testInoutParameterAndFormalResult(_ x: Float) -> Float {
  var x = x
  return inoutParameterAndFormalResult(&x)
}

//===----------------------------------------------------------------------===//
// Stored property access differentiation
//===----------------------------------------------------------------------===//

// Test differentiation of invalid stored property access instructions:
// `struct_extract`, `struct_element_addr`, `ref_element_addr`.

struct StructTangentVectorNotStruct: Differentiable {
  var x: Float

  enum TangentVector: Differentiable, AdditiveArithmetic {
    case x(Float)
    typealias TangentVector = Self
    static func ==(_: Self, _: Self) -> Bool { fatalError() }
    static var zero: Self { fatalError() }
    static func +(_: Self, _: Self) -> Self { fatalError() }
    static func -(_: Self, _: Self) -> Self { fatalError() }
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_vector_not_struct")
func testStructTangentVectorNotStruct(_ s: StructTangentVectorNotStruct) -> Float {
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentVectorNotStruct.x' because 'StructTangentVectorNotStruct.TangentVector' is not a struct}}
  return s.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_vector_not_struct
// CHECK: struct_extract {{%.*}} : $StructTangentVectorNotStruct, #StructTangentVectorNotStruct.x

struct StructOriginalPropertyNotDifferentiable: Differentiable {
  struct Nondiff {
    var x: Float
  }
  var nondiff: Nondiff

  struct TangentVector: Differentiable & AdditiveArithmetic {
    var nondiff: Float
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_original_property_not_differentiable")
func testStructOriginalPropertyNotDifferentiable(_ s: StructOriginalPropertyNotDifferentiable) -> Float {
  // expected-note @+1 {{cannot differentiate access to property 'StructOriginalPropertyNotDifferentiable.nondiff' because property type 'StructOriginalPropertyNotDifferentiable.Nondiff' does not conform to 'Differentiable'}}
  return s.nondiff.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_original_property_not_differentiable
// CHECK: struct_extract {{%.*}} : $StructOriginalPropertyNotDifferentiable, #StructOriginalPropertyNotDifferentiable.nondiff

struct StructTangentVectorPropertyNotFound: Differentiable {
  var x: Float

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var y: Float
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_property_not_found")
func testStructTangentPropertyNotFound(_ s: StructTangentVectorPropertyNotFound) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = s
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentVectorPropertyNotFound.x' because 'StructTangentVectorPropertyNotFound.TangentVector' does not have a stored property named 'x'}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_property_not_found
// CHECK: struct_element_addr {{%.*}} : $*StructTangentVectorPropertyNotFound, #StructTangentVectorPropertyNotFound.x

struct StructTangentPropertyWrongType: Differentiable {
  var x: Float

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Double
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_property_wrong_type")
func testStructTangentPropertyWrongType(_ s: StructTangentPropertyWrongType) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = s
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentPropertyWrongType.x' because 'StructTangentPropertyWrongType.TangentVector.x' does not have expected type 'Float.TangentVector' (aka 'Float')}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_property_wrong_type
// CHECK: struct_element_addr {{%.*}} : $*StructTangentPropertyWrongType, #StructTangentPropertyWrongType.x

final class ClassTangentPropertyWrongType: Differentiable {
  var x: Float = 0

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Double
  }
  func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_class_tangent_property_wrong_type")
func testClassTangentPropertyWrongType(_ c: ClassTangentPropertyWrongType) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = c
  // expected-note @+1 {{cannot differentiate access to property 'ClassTangentPropertyWrongType.x' because 'ClassTangentPropertyWrongType.TangentVector.x' does not have expected type 'Float.TangentVector' (aka 'Float')}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_class_tangent_property_wrong_type
// CHECK: ref_element_addr {{%.*}} : $ClassTangentPropertyWrongType, #ClassTangentPropertyWrongType.x

struct StructTangentPropertyNotStored: Differentiable {
  var x: Float

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Float { 0 }
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_property_not_stored")
func testStructTangentPropertyNotStored(_ s: StructTangentPropertyNotStored) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = s
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentPropertyNotStored.x' because 'StructTangentPropertyNotStored.TangentVector.x' is not a stored property}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_property_not_stored
// CHECK: struct_element_addr {{%.*}} : $*StructTangentPropertyNotStored, #StructTangentPropertyNotStored.x

final class ClassTangentPropertyNotStored: Differentiable {
  var x: Float = 0

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Float { 0 }
  }
  func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_class_tangent_property_not_stored")
func testClassTangentPropertyNotStored(_ c: ClassTangentPropertyNotStored) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = c
  // expected-note @+1 {{cannot differentiate access to property 'ClassTangentPropertyNotStored.x' because 'ClassTangentPropertyNotStored.TangentVector.x' is not a stored property}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_class_tangent_property_not_stored
// CHECK: ref_element_addr {{%.*}} : $ClassTangentPropertyNotStored, #ClassTangentPropertyNotStored.x

// https://github.com/apple/swift/issues/55580
// Test stored property access with conditionally `Differentiable` base type.

struct Complex<T: FloatingPoint> {
  var real: T
  var imaginary: T
}
extension Complex: Differentiable where T: Differentiable {
  typealias TangentVector = Complex
}
extension Complex: AdditiveArithmetic {}

@differentiable(reverse)
func f_55580(lhs: Complex<Float>, rhs: Complex<Float>) -> Float {
  return lhs.real + rhs.real
}

//===----------------------------------------------------------------------===//
// Wrapped property differentiation
//===----------------------------------------------------------------------===//

@propertyWrapper
struct Wrapper<Value> {
  private var value: Value
  var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }
  var projectedValue: Self { self }

  init(wrappedValue: Value) {
    self.value = wrappedValue
  }
}

@propertyWrapper
struct DifferentiableWrapper<Value> {
  private var value: Value
  var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }
  var projectedValue: Self { self }

  init(wrappedValue: Value) {
    self.value = wrappedValue
  }
}
extension DifferentiableWrapper: Differentiable where Value: Differentiable {}
// Note: property wrapped value differentiation works even if wrapper types do
// not conform to `Differentiable`. The conformance here tests projected value
// accesses.

struct Struct: Differentiable {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate access to property 'Struct._x' because 'Struct.TangentVector' does not have a stored property named '_x'}}  
  @DifferentiableWrapper @DifferentiableWrapper var x: Float = 10

  @Wrapper var y: Float = 20
  var z: Float = 30
}

@differentiable(reverse)
func differentiableProjectedValueAccess(_ s: Struct) -> Float {
  s.$x.wrappedValue.wrappedValue
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse)
func projectedValueAccess(_ s: Struct) -> Float {
  // expected-note @+1 {{cannot differentiate through a non-differentiable result; do you want to use 'withoutDerivative(at:)'?}} {{3-3=withoutDerivative(at: }} {{7-7=)}}
  s.$y.wrappedValue
}

// https://github.com/apple/swift/issues/55084
// Test `wrapperValue.modify` differentiation.

@differentiable(reverse)
func modify(_ s: Struct, _ x: Float) -> Float {
  var s = s
  s.x *= x * s.z
  return s.x
}

//===----------------------------------------------------------------------===//
// Array literal initialization
//===----------------------------------------------------------------------===//

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse)
// expected-note @+1 {{when differentiating this function definition}}
func tupleArrayLiteralInitialization(_ x: Float, _ y: Float) -> Float {
  // `Array<(Float, Float)>` does not conform to `Differentiable`.
  let array = [(x * y, x * y)]
  // expected-note @-1 {{cannot differentiate through a non-differentiable argument; do you want to use 'withoutDerivative(at:)'?}} {{15-15=withoutDerivative(at: }} {{31-31=)}}
  return array[0].0
}

//===----------------------------------------------------------------------===//
// Subset parameter differentiation thunks
//===----------------------------------------------------------------------===//

func testNoDerivativeParameter(_ f: @differentiable(reverse) (Float, @noDerivative Float) -> Float) -> Float {
  // expected-error @+2 {{function is not differentiable}}
  // expected-note @+1 {{cannot differentiate with respect to a '@noDerivative' parameter}}
  return gradient(at: 2) { x in f(x * x, x) }
}

// Test parameter subset thunk + partially-applied original function.
struct TF_675 : Differentiable {
  @differentiable(reverse)
  func method(_ x: Float) -> Float {
    return x
  }
}
let _: @differentiable(reverse) (Float) -> Float = TF_675().method

// TF-918: Test parameter subset thunk + partially-applied original function.
let _: @differentiable(reverse) (Float, @noDerivative Float) -> Float = (+) as @differentiable(reverse) (Float, Float) -> Float
let _: @differentiable(reverse) (Float, @noDerivative Float) -> Float = (+) as @differentiable(reverse) (Float, @noDerivative Float) -> Float

//===----------------------------------------------------------------------===//
// Differentiation in fragile functions
//===----------------------------------------------------------------------===//

public func implicitlyDifferentiableFromFragile(_ x: Float) -> Float { x }

public func hasImplicitlyDifferentiatedTopLevelDefaultArgument(
// expected-error @+2 {{function is not differentiable}}
// expected-note @+1 {{differentiated functions in default arguments must be marked '@differentiable' or have a public '@derivative'}}
  _ f: @differentiable(reverse) (Float) -> Float = implicitlyDifferentiableFromFragile
) {}

// No error expected
public func hasImplicitlyDifferentiatedClosureDefaultArgument(_ f: @differentiable(reverse) (Float) -> Float = { $0 }) {}

@inlinable
public func fragileFuncWithGradient() {
  // expected-error @+2 {{function is not differentiable}}
  // expected-note @+1 {{differentiated functions in '@inlinable' functions must be marked '@differentiable' or have a public '@derivative'}}
  _ = gradient(at: 0, of: implicitlyDifferentiableFromFragile)
}

@inlinable
@differentiable(reverse)
public func fragileDifferentiable(_ x: Float) -> Float {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{differentiated functions in '@inlinable' functions must be marked '@differentiable' or have a public '@derivative'}}
  implicitlyDifferentiableFromFragile(x)
}

//===----------------------------------------------------------------------===//
// Coroutines (SIL function yields, `begin_apply`) (not yet supported)
//===----------------------------------------------------------------------===//

struct HasReadAccessors: Differentiable {
  var stored: Float
  var computed: Float {
    // `_read` is a coroutine: `(Self) -> () -> ()`.
    _read { yield stored }
  }
}

struct HasModifyAccessors: Differentiable {
  var stored: Float
  var computed: Float {
    get { stored }
    // `_modify` is a coroutine: `(inout Self) -> () -> ()`.
    _modify { yield &stored }
  }
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse)
func testReadAccessorCoroutines(_ x: HasReadAccessors) -> Float {
  // expected-note @+1 {{cannot differentiate through a '_read' accessor}}
  return x.computed
}

@differentiable(reverse)
func testModifyAccessorCoroutines(_ x: HasModifyAccessors) -> Float {
  var x = x
  x.computed = x.computed
  return x.computed
}

// TF-1078: Diagnose `_modify` accessor application with active `inout` argument.
@differentiable(reverse)
func TF_1078(array: [Float], x: Float) -> Float {
  var array = array
  // Array subscript assignment below calls `Array.subscript.modify`.
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate functions that have not been marked '@differentiable' and that are defined in other files}}
  array[0] = x
  return array[0]
}

// TF-1115: Diagnose `_modify` accessor application with initially non-active `inout` argument.
@differentiable(reverse)
func TF_1115(_ x: Float) -> Float {
  var array: [Float] = [0]
  // Array subscript assignment below calls `Array.subscript.modify`.
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate functions that have not been marked '@differentiable' and that are defined in other files}}
  array[0] = x
  return array[0]
}

// TF-1115: Test `_modify` accessor application with initially non-active `inout` argument,
// where the yielded value is not a projection from `self`.
extension Float {
  static var staticProperty: Float = 1

  var projection: Float {
    get { self }
    // This `modify` accessor yields a static variable, not a projection from `self`.
    // Diagnosing active applications is nonetheless a safe over-approximation.
    _modify { yield &Float.staticProperty }
  }
}

@differentiable(reverse)
func TF_1115_modifyNonSelfProjection(x: Float) -> Float {
  var result: Float = 0
  // Assignment below calls `Float.projection.modify`.
  result.projection = x
  return result
}

//===----------------------------------------------------------------------===//
// Conversion to `@differentiable(_linear)` (not yet supported)
//===----------------------------------------------------------------------===//

// expected-error @+1 {{conversion to '@differentiable(_linear)' function type is not yet supported}}
let _: @differentiable(_linear) (Float) -> Float = { x in x }
// --- Seed B ---
// RUN: %target-swift-frontend -emit-sil -verify %s

// Test differentiation transform diagnostics.


//===----------------------------------------------------------------------===//
// Basic function
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func basic_b45c7a4(__b45c7a4 x: Float) -> Float {
  return x
}

//===----------------------------------------------------------------------===//
// Control flow
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func conditional_b45c7a4(__b45c7a4 x: Float, __b45c7a4 flag: Bool) -> Float {
  let y: Float
  if flag {
    y = x
  } else {
    y = x
  }
  return y
}

// TF-433: Test `try_apply_b45c7a4` differentiation.

func throwing_b45c7a4() throws -> Void {}

@differentiable(reverse)
func try_apply_b45c7a4(__b45c7a4 x: Float) -> Float {
  try! throwing_b45c7a4()
  return x
}

func rethrowing_b45c7a4(__b45c7a4 x: () throws -> Void) rethrows -> Void {}

@differentiable(reverse)
func try_apply_rethrows_b45c7a4(__b45c7a4 x: Float) -> Float {
  rethrowing_b45c7a4({})
  return x
}

func throwing_result_b45c7a4(__b45c7a4 x: Float) throws -> Float { return x; }

@differentiable(reverse)
func active_try_apply_b45c7a4(__b45c7a4 x: Float) -> Float {
  do {
    return try throwing_result_b45c7a4(x);
  } catch {
    return x
  }
}

@differentiable(reverse)
func map_nondiff_b45c7a4(__b45c7a4 a: [Float]) -> [Float] {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate functions that have not been marked '@differentiable' and that are defined in other files}}
  return a.map { $0 }
}

//===----------------------------------------------------------------------===//
// Unreachable
//===----------------------------------------------------------------------===//

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse)
func noReturn_b45c7a4(__b45c7a4 x: Float) -> Float {
  let __b45c7a4 = x
  // expected-error @+2 {{missing return in global_b45c7a4 function expected to return 'Float'}}
  // expected-note @+1 {{missing return for differentiation}}
}

//===----------------------------------------------------------------------===//
// Global variables
//===----------------------------------------------------------------------===//

var global_b45c7a4: Float = 3.0

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse, wrt: x)
func testWriteToGlobalVariable_b45c7a4(x: Float) -> Float {
  // expected-note @+1 {{cannot differentiate writes to global_b45c7a4 variables}}
  global_b45c7a4 = global_b45c7a4 + x
  return global_b45c7a4
}

//===----------------------------------------------------------------------===//
// Class_b45c7a4 differentiation
//===----------------------------------------------------------------------===//

class Class_b45c7a4 : Differentiable {
  @differentiable(reverse)
  var stored: Float = 1

  @differentiable(reverse)
  func testRefElementAddr(__b45c7a4 x: Float) -> Float {
    return stored * x
  }

  var nonDifferentiableStored: Float = 1

  @differentiable(reverse)
  func testNonDifferentiableRefElementAddr(__b45c7a4 x: Float) -> Float {
    // expected-error @+2 {{expression is not differentiable}}
    // expected-note @+1 {{member is not differentiable because the corresponding class member is not '@differentiable'}}
    return nonDifferentiableStored * x
  }

  @differentiable(reverse)
  func method(__b45c7a4 x: Float) -> Float { x }

  @differentiable(reverse)
  static func testClassMethod(x: Float) -> Float {
    return Class_b45c7a4().method(x)
  }

  func nonDifferentiableMethod(__b45c7a4 x: Float) -> Float { x }

  @differentiable(reverse)
  static func testDifferentiableClassMethod(x: Float) -> Float {
    // expected-error @+2 {{expression is not differentiable}}
    // expected-note @+1 {{member is not differentiable because the corresponding class member is not '@differentiable'}}
    return Class_b45c7a4().nonDifferentiableMethod(x)
  }
}

// TF-676: Test differentiation of class method with multiple `@differentiable`
// attributes.
class ClassMethodMultipleDifferentiableAttribute_b45c7a4 : Differentiable {
  @differentiable(reverse, wrt: (self, x))
  @differentiable(reverse, wrt: x)
  func f(__b45c7a4 x: Float) -> Float { x }
}
func testMultipleDiffAttrsClass_b45c7a4<C_b45c7a4: ClassMethodMultipleDifferentiableAttribute_b45c7a4>(
  __b45c7a4 c: C_b45c7a4, __b45c7a4 x: Float
) {
  __b45c7a4 = gradient(at: c, x) { c, x in c.f(x) }
  __b45c7a4 = gradient(at: x) { x in c.f(x) }
}

// TF-1149: Test class with loadable type but address-only `TangentVector` type.
class C_b45c7a4<T: Differentiable>: Differentiable {
  @differentiable(reverse)
  var stored: T

  init(__b45c7a4 stored: T) {
    self.stored = stored
  }

  @differentiable(reverse)
  func method(__b45c7a4 x: T) -> T {
    stored
  }
}

//===----------------------------------------------------------------------===//
// Enum differentiation
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func usesOptionals_b45c7a4(__b45c7a4 x: Float) -> Float {
  var maybe: Float? = 10
  maybe = x
  return maybe!
}

enum DirectEnum_b45c7a4: Differentiable & AdditiveArithmetic {
  case leaf(Float)

  typealias TangentVector = Self

  static var zero: Self { fatalError() }
  static func +(__b45c7a4 lhs: Self, __b45c7a4 rhs: Self) -> Self { fatalError() }
  static func -(__b45c7a4 lhs: Self, __b45c7a4 rhs: Self) -> Self { fatalError() }
}

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse, wrt: e)
// expected-note @+2 {{when differentiating this function definition}}
// expected-note @+1 {{differentiating enum values is not yet supported}}
func enum_active_b45c7a4(__b45c7a4 e: DirectEnum_b45c7a4, __b45c7a4 x: Float) -> Float {
  switch e {
  case let .leaf(y): return y
  }
}

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse, wrt: e)
// expected-note @+2 {{when differentiating this function definition}}
// expected-note @+1 {{differentiating enum values is not yet supported}}
func activeEnumValue_b45c7a4(__b45c7a4 e: DirectEnum_b45c7a4, __b45c7a4 x: Float) -> Float {
  switch e {
  case let .leaf(y): return y
  }
}

enum IndirectEnum_b45c7a4<T: Differentiable>: Differentiable & AdditiveArithmetic {
  case leaf(T)

  typealias TangentVector = Self

  static func ==(__b45c7a4 lhs: Self, __b45c7a4 rhs: Self) -> Bool { fatalError() }
  static var zero: Self { fatalError() }
  static func +(__b45c7a4 lhs: Self, __b45c7a4 rhs: Self) -> Self { fatalError() }
  static func -(__b45c7a4 lhs: Self, __b45c7a4 rhs: Self) -> Self { fatalError() }
}

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse, wrt: e)
// expected-note @+2 {{when differentiating this function definition}}
// expected-note @+1 {{differentiating enum values is not yet supported}}
func activeEnumAddr_b45c7a4(__b45c7a4 e: IndirectEnum_b45c7a4<Float>, __b45c7a4 x: Float) -> Float {
  switch e {
  case let .leaf(y): return y
  }
}

//===----------------------------------------------------------------------===//
// Unmet derivative generic_b45c7a4 requirements
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func generic_b45c7a4<T: Differentiable & FloatingPoint>(__b45c7a4 x: T) -> T {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{member is not differentiable because the corresponding protocol requirement is not '@differentiable'}}
  return x + 1
}

// Test unmet generic_b45c7a4 requirements.

func weird_b45c7a4<T>(__b45c7a4 x: T) -> T {
  return x
}
@derivative(of: weird_b45c7a4)
func vjpWeirdExtraRequirements_b45c7a4<T : Differentiable & CaseIterable>(__b45c7a4 x: T) -> (
  value: T, pullback: (T.TangentVector) -> T.TangentVector
) where T.AllCases : ExpressibleByStringLiteral {
  return (x, { $0 })
}
@differentiable(reverse)
func weirdWrapper_b45c7a4<T : Differentiable>(__b45c7a4 x: T) -> T {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{function call is not differentiable because generic_b45c7a4 requirements are not met: 'T : CaseIterable, T.AllCases : ExpressibleByStringLiteral'}}
  return weird_b45c7a4(x)
}

@differentiable(reverse)
func direct_b45c7a4<T : Differentiable>(__b45c7a4 x: T) -> T {
  return x
}

struct Tensor_b45c7a4<Scalar> {
  static func + (__b45c7a4 lhs: Tensor_b45c7a4, rhs: Scalar) -> Tensor_b45c7a4 { return lhs }
}
extension Tensor_b45c7a4 : Differentiable where Scalar : Differentiable & FloatingPoint {}
extension Tensor_b45c7a4 where Scalar : BinaryFloatingPoint {
  @differentiable(reverse, wrt: self where Scalar : Differentiable)
  func TF_6(__b45c7a4 x: Float) -> Tensor_b45c7a4 {
    return self + Scalar(x)
  }
}

protocol TF8_Proto_b45c7a4 : Differentiable {
  associatedtype Scalar
  @differentiable(reverse, wrt: (self, input))
  func applied(to input: Float) -> Float
}

struct TF8_Struct_b45c7a4<Scalar> : TF8_Proto_b45c7a4 where Scalar : FloatingPoint & Differentiable {
  @noDerivative let bar: Scalar

  @differentiable(reverse, wrt: (self, input))
  func applied(to input: Float) -> Float {
    return input
  }
}

//===----------------------------------------------------------------------===//
// `Differentiable` conformance requirement inference
//===----------------------------------------------------------------------===//

func id_b45c7a4<T>(__b45c7a4 x: T) -> T { x }
let __b45c7a4: @differentiable(reverse) (Float) -> Float = { x in id_b45c7a4(x) }

struct TF_691_b45c7a4<Scalar> {
  var x: Scalar
  init(__b45c7a4 x: Scalar) {
    self.x = x
  }
}
extension TF_691_b45c7a4: Differentiable where Scalar: Differentiable {}

func identity_b45c7a4<T>(__b45c7a4 x: TF_691_b45c7a4<T>) -> TF_691_b45c7a4<T> { x }
let __b45c7a4: @differentiable(reverse) (Float) -> TF_691_b45c7a4<Float> = { x in identity_b45c7a4(TF_691_b45c7a4(x)) }
let __b45c7a4: @differentiable(reverse) (Float) -> TF_691_b45c7a4<Float> = { x in id_b45c7a4(TF_691_b45c7a4(x)) }

//===----------------------------------------------------------------------===//
// Non-differentiable arguments and results
//===----------------------------------------------------------------------===//

struct TF_687_b45c7a4<T> : Differentiable {
  @noDerivative var indirectDummy: T
  var base: Float

  init(__b45c7a4 base: Float, dummy: T) {
    self.base = base
    self.indirectDummy = dummy
  }
}
// expected-error @+2 {{function is not differentiable}}
// expected-note @+1 {{cannot differentiate through a non-differentiable argument; do you want to use 'withoutDerivative(at:)'?}} {{87-87=withoutDerivative(at: }} {{88-88=)}}
let __b45c7a4: @differentiable(reverse) (Float) -> TF_687_b45c7a4<Any> = { x in TF_687_b45c7a4<Any>(x, dummy: x) }

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse)
// expected-note @+1 {{when differentiating this function definition}}
func roundingGivesError_b45c7a4(x: Float) -> Float {
  // expected-note @+1 {{cannot differentiate through a non-differentiable result; do you want to use 'withoutDerivative(at:)'?}} {{16-16=withoutDerivative(at: }} {{22-22=)}}
  return Float(Int(x))
}

//===----------------------------------------------------------------------===//
// Non-varied results
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func nonVariedResult_b45c7a4(__b45c7a4 x: Float) -> Float {
  // TODO(TF-788): Re-enable non-varied result warning.
  // xpected-warning @+1 {{result does not depend on differentiation arguments and will always have a zero derivative; do you want to use 'withoutDerivative(at:)'?}} {{10-10=withoutDerivative(at:}} {{15-15=)}}
  return 0
}

// Check that `withoutDerivative(at:)` silences the non-varied result warning.

struct TF_775_b45c7a4: Differentiable {
  @differentiable(reverse, wrt: (self))
  func nonVariedResult_b45c7a4(__b45c7a4 input: Float) -> Float {
    return withoutDerivative(at: input)
  }
}

//===----------------------------------------------------------------------===//
// Multiple results
//===----------------------------------------------------------------------===//

func multipleResults_b45c7a4(__b45c7a4 x: Float) -> (Float, Float) {
  return (x, x)
}

@differentiable(reverse)
func usesMultipleResults_b45c7a4(__b45c7a4 x: Float) -> Float {
  let tuple = multipleResults_b45c7a4(x)
  return tuple.0 + tuple.1
}

//===----------------------------------------------------------------------===//
// `inout` parameter differentiation
//===----------------------------------------------------------------------===//

@differentiable(reverse)
func activeInoutParam_b45c7a4(__b45c7a4 x: Float) -> Float {
  var result = x
  result += x
  return result
}

@differentiable(reverse)
func activeInoutParamNonactiveInitialResult_b45c7a4(__b45c7a4 x: Float) -> Float {
  var result: Float = 1
  result += x
  return result
}

@differentiable(reverse)
func activeInoutParamTuple_b45c7a4(__b45c7a4 x: Float) -> Float {
  var tuple = (x, x)
  tuple.0 *= x
  return x * tuple.0
}

@differentiable(reverse)
func activeInoutParamControlFlow_b45c7a4(__b45c7a4 array: [Float]) -> Float {
  var result: Float = 1
  for i in withoutDerivative(at: array).indices {
    result += array[i]
  }
  return result
}

@differentiable(reverse)
func activeInoutParamControlFlowComplex_b45c7a4(__b45c7a4 array: [Float], __b45c7a4 bool: Bool) -> Float {
  var result: Float = 1
  if bool {
    if bool {}
    for i in withoutDerivative(at: array).indices {
      switch i % 2 {
      case 0: continue
      case 1: break
      default: break
      }
      result = result + 1
      result += array[i]
    }
  }
  return result
}

struct Mut_b45c7a4: Differentiable {}
extension Mut_b45c7a4 {
  @differentiable(reverse, wrt: (self, x))
  mutating func mutatingMethod(__b45c7a4 x: Mut_b45c7a4) {}
}

@differentiable(reverse, wrt: (nonactive, x))
func nonActiveInoutParam_b45c7a4(__b45c7a4 nonactive: inout Mut_b45c7a4, __b45c7a4 x: Mut_b45c7a4) {
  nonactive.mutatingMethod(x)
}

@differentiable(reverse, wrt: x)
func activeInoutParamMutatingMethod_b45c7a4(__b45c7a4 x: Mut_b45c7a4) -> Mut_b45c7a4 {
  var result = x
  result.mutatingMethod(result)
  return result
}

@differentiable(reverse, wrt: (nonactive, x))
func activeInoutParamMutatingMethodVar_b45c7a4(__b45c7a4 nonactive: inout Mut_b45c7a4, __b45c7a4 x: Mut_b45c7a4) {
  var result = nonactive
  result.mutatingMethod(x)
  nonactive = result
}

@differentiable(reverse, wrt: (nonactive, x))
func activeInoutParamMutatingMethodTuple_b45c7a4(__b45c7a4 nonactive: inout Mut_b45c7a4, __b45c7a4 x: Mut_b45c7a4) {
  var result = (nonactive, x)
  result.0.mutatingMethod(result.0)
  nonactive = result.0
}

func twoInoutParameters_b45c7a4(__b45c7a4 x: inout Float, __b45c7a4 y: inout Float) {}
@differentiable(reverse)
func testTwoInoutParameters_b45c7a4(__b45c7a4 x: Float, __b45c7a4 y: Float) -> Float {
  var x = x
  var y = y
  twoInoutParameters_b45c7a4(&x, &y)
  return x
}

func inoutParameterAndFormalResult_b45c7a4(__b45c7a4 x: inout Float) -> Float { x }
@differentiable(reverse)
func testInoutParameterAndFormalResult_b45c7a4(__b45c7a4 x: Float) -> Float {
  var x = x
  return inoutParameterAndFormalResult_b45c7a4(&x)
}

//===----------------------------------------------------------------------===//
// Stored property access differentiation
//===----------------------------------------------------------------------===//

// Test differentiation of invalid stored property access instructions:
// `struct_extract`, `struct_element_addr`, `ref_element_addr`.

struct StructTangentVectorNotStruct_b45c7a4: Differentiable {
  var x: Float

  enum TangentVector: Differentiable, AdditiveArithmetic {
    case x(Float)
    typealias TangentVector = Self
    static func ==(__b45c7a4: Self, __b45c7a4: Self) -> Bool { fatalError() }
    static var zero: Self { fatalError() }
    static func +(__b45c7a4: Self, __b45c7a4: Self) -> Self { fatalError() }
    static func -(__b45c7a4: Self, __b45c7a4: Self) -> Self { fatalError() }
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_vector_not_struct")
func testStructTangentVectorNotStruct_b45c7a4(__b45c7a4 s: StructTangentVectorNotStruct_b45c7a4) -> Float {
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentVectorNotStruct_b45c7a4.x' because 'StructTangentVectorNotStruct_b45c7a4.TangentVector' is not a struct}}
  return s.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_vector_not_struct
// CHECK: struct_extract {{%.*}} : $StructTangentVectorNotStruct_b45c7a4, #StructTangentVectorNotStruct_b45c7a4.x

struct StructOriginalPropertyNotDifferentiable_b45c7a4: Differentiable {
  struct Nondiff {
    var x: Float
  }
  var nondiff: Nondiff

  struct TangentVector: Differentiable & AdditiveArithmetic {
    var nondiff: Float
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_original_property_not_differentiable")
func testStructOriginalPropertyNotDifferentiable_b45c7a4(__b45c7a4 s: StructOriginalPropertyNotDifferentiable_b45c7a4) -> Float {
  // expected-note @+1 {{cannot differentiate access to property 'StructOriginalPropertyNotDifferentiable_b45c7a4.nondiff' because property type 'StructOriginalPropertyNotDifferentiable_b45c7a4.Nondiff' does not conform to 'Differentiable'}}
  return s.nondiff.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_original_property_not_differentiable
// CHECK: struct_extract {{%.*}} : $StructOriginalPropertyNotDifferentiable_b45c7a4, #StructOriginalPropertyNotDifferentiable_b45c7a4.nondiff

struct StructTangentVectorPropertyNotFound_b45c7a4: Differentiable {
  var x: Float

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var y: Float
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_property_not_found")
func testStructTangentPropertyNotFound_b45c7a4(__b45c7a4 s: StructTangentVectorPropertyNotFound_b45c7a4) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = s
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentVectorPropertyNotFound_b45c7a4.x' because 'StructTangentVectorPropertyNotFound_b45c7a4.TangentVector' does not have a stored property named 'x'}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_property_not_found
// CHECK: struct_element_addr {{%.*}} : $*StructTangentVectorPropertyNotFound_b45c7a4, #StructTangentVectorPropertyNotFound_b45c7a4.x

struct StructTangentPropertyWrongType_b45c7a4: Differentiable {
  var x: Float

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Double
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_property_wrong_type")
func testStructTangentPropertyWrongType_b45c7a4(__b45c7a4 s: StructTangentPropertyWrongType_b45c7a4) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = s
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentPropertyWrongType_b45c7a4.x' because 'StructTangentPropertyWrongType_b45c7a4.TangentVector.x' does not have expected type 'Float.TangentVector' (aka 'Float')}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_property_wrong_type
// CHECK: struct_element_addr {{%.*}} : $*StructTangentPropertyWrongType_b45c7a4, #StructTangentPropertyWrongType_b45c7a4.x

final class ClassTangentPropertyWrongType_b45c7a4: Differentiable {
  var x: Float = 0

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Double
  }
  func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_class_tangent_property_wrong_type")
func testClassTangentPropertyWrongType_b45c7a4(__b45c7a4 c: ClassTangentPropertyWrongType_b45c7a4) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = c
  // expected-note @+1 {{cannot differentiate access to property 'ClassTangentPropertyWrongType_b45c7a4.x' because 'ClassTangentPropertyWrongType_b45c7a4.TangentVector.x' does not have expected type 'Float.TangentVector' (aka 'Float')}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_class_tangent_property_wrong_type
// CHECK: ref_element_addr {{%.*}} : $ClassTangentPropertyWrongType_b45c7a4, #ClassTangentPropertyWrongType_b45c7a4.x

struct StructTangentPropertyNotStored_b45c7a4: Differentiable {
  var x: Float

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Float { 0 }
  }
  mutating func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_struct_tangent_property_not_stored")
func testStructTangentPropertyNotStored_b45c7a4(__b45c7a4 s: StructTangentPropertyNotStored_b45c7a4) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = s
  // expected-note @+1 {{cannot differentiate access to property 'StructTangentPropertyNotStored_b45c7a4.x' because 'StructTangentPropertyNotStored_b45c7a4.TangentVector.x' is not a stored property}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_struct_tangent_property_not_stored
// CHECK: struct_element_addr {{%.*}} : $*StructTangentPropertyNotStored_b45c7a4, #StructTangentPropertyNotStored_b45c7a4.x

final class ClassTangentPropertyNotStored_b45c7a4: Differentiable {
  var x: Float = 0

  struct TangentVector: Differentiable, AdditiveArithmetic {
    var x: Float { 0 }
  }
  func move(by offset: TangentVector) {}
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+3 {{when differentiating this function definition}}
@differentiable(reverse)
@_silgen_name("test_class_tangent_property_not_stored")
func testClassTangentPropertyNotStored_b45c7a4(__b45c7a4 c: ClassTangentPropertyNotStored_b45c7a4) -> Float {
  // expected-warning @+1 {{variable 'tmp' was never mutated}}
  var tmp = c
  // expected-note @+1 {{cannot differentiate access to property 'ClassTangentPropertyNotStored_b45c7a4.x' because 'ClassTangentPropertyNotStored_b45c7a4.TangentVector.x' is not a stored property}}
  return tmp.x
}

// CHECK-LABEL: sil {{.*}} @test_class_tangent_property_not_stored
// CHECK: ref_element_addr {{%.*}} : $ClassTangentPropertyNotStored_b45c7a4, #ClassTangentPropertyNotStored_b45c7a4.x

// https://github.com/apple/swift/issues/55580
// Test stored property access with conditionally `Differentiable` base type.

struct Complex_b45c7a4<T: FloatingPoint> {
  var real: T
  var imaginary: T
}
extension Complex_b45c7a4: Differentiable where T: Differentiable {
  typealias TangentVector = Complex_b45c7a4
}
extension Complex_b45c7a4: AdditiveArithmetic {}

@differentiable(reverse)
func f_55580_b45c7a4(lhs: Complex_b45c7a4<Float>, rhs: Complex_b45c7a4<Float>) -> Float {
  return lhs.real + rhs.real
}

//===----------------------------------------------------------------------===//
// Wrapped property differentiation
//===----------------------------------------------------------------------===//

@propertyWrapper
struct Wrapper_b45c7a4<Value> {
  private var value: Value
  var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }
  var projectedValue: Self { self }

  init(wrappedValue: Value) {
    self.value = wrappedValue
  }
}

@propertyWrapper
struct DifferentiableWrapper_b45c7a4<Value> {
  private var value: Value
  var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }
  var projectedValue: Self { self }

  init(wrappedValue: Value) {
    self.value = wrappedValue
  }
}
extension DifferentiableWrapper_b45c7a4: Differentiable where Value: Differentiable {}
// Note: property wrapped value differentiation works even if wrapper types do
// not conform to `Differentiable`. The conformance here tests projected value
// accesses.

struct Struct_b45c7a4: Differentiable {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate access to property 'Struct_b45c7a4._x' because 'Struct_b45c7a4.TangentVector' does not have a stored property named '_x'}}  
  @DifferentiableWrapper_b45c7a4 @DifferentiableWrapper_b45c7a4 var x: Float = 10

  @Wrapper_b45c7a4 var y: Float = 20
  var z: Float = 30
}

@differentiable(reverse)
func differentiableProjectedValueAccess_b45c7a4(__b45c7a4 s: Struct_b45c7a4) -> Float {
  s.$x.wrappedValue.wrappedValue
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse)
func projectedValueAccess_b45c7a4(__b45c7a4 s: Struct_b45c7a4) -> Float {
  // expected-note @+1 {{cannot differentiate through a non-differentiable result; do you want to use 'withoutDerivative(at:)'?}} {{3-3=withoutDerivative(at: }} {{7-7=)}}
  s.$y.wrappedValue
}

// https://github.com/apple/swift/issues/55084
// Test `wrapperValue.modify_b45c7a4` differentiation.

@differentiable(reverse)
func modify_b45c7a4(__b45c7a4 s: Struct_b45c7a4, __b45c7a4 x: Float) -> Float {
  var s = s
  s.x *= x * s.z
  return s.x
}

//===----------------------------------------------------------------------===//
// Array literal initialization
//===----------------------------------------------------------------------===//

// expected-error @+1 {{function is not differentiable}}
@differentiable(reverse)
// expected-note @+1 {{when differentiating this function definition}}
func tupleArrayLiteralInitialization_b45c7a4(__b45c7a4 x: Float, __b45c7a4 y: Float) -> Float {
  // `Array<(Float, Float)>` does not conform to `Differentiable`.
  let array = [(x * y, x * y)]
  // expected-note @-1 {{cannot differentiate through a non-differentiable argument; do you want to use 'withoutDerivative(at:)'?}} {{15-15=withoutDerivative(at: }} {{31-31=)}}
  return array[0].0
}

//===----------------------------------------------------------------------===//
// Subset parameter differentiation thunks
//===----------------------------------------------------------------------===//

func testNoDerivativeParameter_b45c7a4(__b45c7a4 f: @differentiable(reverse) (Float, @noDerivative Float) -> Float) -> Float {
  // expected-error @+2 {{function is not differentiable}}
  // expected-note @+1 {{cannot differentiate with respect to a '@noDerivative' parameter}}
  return gradient(at: 2) { x in f(x * x, x) }
}

// Test parameter subset thunk + partially-applied original function.
struct TF_675_b45c7a4 : Differentiable {
  @differentiable(reverse)
  func method(__b45c7a4 x: Float) -> Float {
    return x
  }
}
let __b45c7a4: @differentiable(reverse) (Float) -> Float = TF_675_b45c7a4().method

// TF-918: Test parameter subset thunk + partially-applied original function.
let __b45c7a4: @differentiable(reverse) (Float, @noDerivative Float) -> Float = (+) as @differentiable(reverse) (Float, Float) -> Float
let __b45c7a4: @differentiable(reverse) (Float, @noDerivative Float) -> Float = (+) as @differentiable(reverse) (Float, @noDerivative Float) -> Float

//===----------------------------------------------------------------------===//
// Differentiation in fragile functions
//===----------------------------------------------------------------------===//

public func implicitlyDifferentiableFromFragile_b45c7a4(__b45c7a4 x: Float) -> Float { x }

public func hasImplicitlyDifferentiatedTopLevelDefaultArgument_b45c7a4(
// expected-error @+2 {{function is not differentiable}}
// expected-note @+1 {{differentiated functions in default arguments must be marked '@differentiable' or have a public '@derivative'}}
  __b45c7a4 f: @differentiable(reverse) (Float) -> Float = implicitlyDifferentiableFromFragile_b45c7a4
) {}

// No error expected
public func hasImplicitlyDifferentiatedClosureDefaultArgument_b45c7a4(__b45c7a4 f: @differentiable(reverse) (Float) -> Float = { $0 }) {}

@inlinable
public func fragileFuncWithGradient_b45c7a4() {
  // expected-error @+2 {{function is not differentiable}}
  // expected-note @+1 {{differentiated functions in '@inlinable' functions must be marked '@differentiable' or have a public '@derivative'}}
  __b45c7a4 = gradient(at: 0, of: implicitlyDifferentiableFromFragile_b45c7a4)
}

@inlinable
@differentiable(reverse)
public func fragileDifferentiable_b45c7a4(__b45c7a4 x: Float) -> Float {
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{differentiated functions in '@inlinable' functions must be marked '@differentiable' or have a public '@derivative'}}
  implicitlyDifferentiableFromFragile_b45c7a4(x)
}

//===----------------------------------------------------------------------===//
// Coroutines (SIL function yields, `begin_apply`) (not yet supported)
//===----------------------------------------------------------------------===//

struct HasReadAccessors_b45c7a4: Differentiable {
  var stored: Float
  var computed: Float {
    // `_read` is a coroutine: `(Self) -> () -> ()`.
    _read { yield stored }
  }
}

struct HasModifyAccessors_b45c7a4: Differentiable {
  var stored: Float
  var computed: Float {
    get { stored }
    // `_modify` is a coroutine: `(inout Self) -> () -> ()`.
    _modify { yield &stored }
  }
}

// expected-error @+2 {{function is not differentiable}}
// expected-note @+2 {{when differentiating this function definition}}
@differentiable(reverse)
func testReadAccessorCoroutines_b45c7a4(__b45c7a4 x: HasReadAccessors_b45c7a4) -> Float {
  // expected-note @+1 {{cannot differentiate through a '_read' accessor}}
  return x.computed
}

@differentiable(reverse)
func testModifyAccessorCoroutines_b45c7a4(__b45c7a4 x: HasModifyAccessors_b45c7a4) -> Float {
  var x = x
  x.computed = x.computed
  return x.computed
}

// TF-1078: Diagnose `_modify` accessor application with active `inout` argument.
@differentiable(reverse)
func TF_1078_b45c7a4(array: [Float], x: Float) -> Float {
  var array = array
  // Array subscript assignment below calls `Array.subscript.modify_b45c7a4`.
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate functions that have not been marked '@differentiable' and that are defined in other files}}
  array[0] = x
  return array[0]
}

// TF-1115: Diagnose `_modify` accessor application with initially non-active `inout` argument.
@differentiable(reverse)
func TF_1115_b45c7a4(__b45c7a4 x: Float) -> Float {
  var array: [Float] = [0]
  // Array subscript assignment below calls `Array.subscript.modify_b45c7a4`.
  // expected-error @+2 {{expression is not differentiable}}
  // expected-note @+1 {{cannot differentiate functions that have not been marked '@differentiable' and that are defined in other files}}
  array[0] = x
  return array[0]
}

// TF-1115: Test `_modify` accessor application with initially non-active `inout` argument,
// where the yielded value is not a projection from `self`.
extension Float {
  static var staticProperty: Float = 1

  var projection: Float {
    get { self }
    // This `modify_b45c7a4` accessor yields a static variable, not a projection from `self`.
    // Diagnosing active applications is nonetheless a safe over-approximation.
    _modify { yield &Float.staticProperty }
  }
}

@differentiable(reverse)
func TF_1115_modifyNonSelfProjection_b45c7a4(x: Float) -> Float {
  var result: Float = 0
  // Assignment below calls `Float.projection.modify_b45c7a4`.
  result.projection = x
  return result
}

//===----------------------------------------------------------------------===//
// Conversion to `@differentiable(_linear)` (not yet supported)
//===----------------------------------------------------------------------===//

// expected-error @+1 {{conversion to '@differentiable(_linear)' function type is not yet supported}}
let __b45c7a4: @differentiable(_linear) (Float) -> Float = { x in x }
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
    let _ffl_r = Double(String(describing: global).count)
    let _ffl_shapes: [any _FflShape] = [_FflCircle(r: _ffl_r), _FflRect(w: _ffl_r, h: 2.0)]
    _ = _ffl_p2_sum(_ffl_shapes)
    let _ffl_meta: any _FflShape.Type = _FflCircle.self
    _ = _ffl_meta.init(r: _ffl_r)
}
