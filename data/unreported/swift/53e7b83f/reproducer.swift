import DefaultArguments
import StdlibUnittest
import _Differentiation

// --- Seed A ---
// RUN: %empty-directory(%t)
// RUN: %target-clangxx -c %S/Inputs/default-arguments.cpp -I %S/Inputs -o %t/default-arguments.o
// RUN: %target-build-swift %s -I %S/Inputs -o %t/default-arguments %t/default-arguments.o -cxx-interoperability-mode=upcoming-swift
// RUN: %target-codesign %t/default-arguments
// RUN: %target-run %t/default-arguments

// REQUIRES: executable_test


var DefaultArgTestSuite = TestSuite("Functions with Default Arguments")

DefaultArgTestSuite.test("func with integer parameter") {
  let z0 = isZero()
  expectTrue(z0)

  let z1 = isZero(1)
  expectFalse(z1)

  let z2 = isNonZero()
  expectFalse(z2)

  let s0 = sum(1)
  expectEqual(2, s0)

  let s1 = sum(3, 4)
  expectEqual(7, s1)

  let s2 = subtract()
  expectEqual(122, s2)

  let s3 = subtract(55)
  expectEqual(54, s3)

  let s4 = subtract(55, 44)
  expectEqual(11, s4)
}

DefaultArgTestSuite.test("func with pointer parameter") {
  let z0 = isNil()
  expectTrue(z0)

  let z1 = isGlobalNonNil()
  expectFalse(z1)
}

DefaultArgTestSuite.test("func with cString parameter") {
  let z0 = isStrNil()
  expectFalse(z0)
}

DefaultArgTestSuite.test("func with mutating integer argument") {
  let z0 = isZeroCounter()
  expectTrue(z0)

  let z1 = isZeroCounter()
  expectFalse(z1)
}

DefaultArgTestSuite.test("func with non-trailing argument") {
  let t0 = nonTrailing()
  expectEqual(3, t0)
  
  let t1 = nonTrailing(5, 6)
  expectEqual(11, t1)
}

DefaultArgTestSuite.test("func with unnamed argument") {
  let t0 = takesUnnamedParam()
  expectEqual(456, t0)

  let t1 = takesUnnamedParam(321)
  expectEqual(456, t1)
}

DefaultArgTestSuite.test("method with integer parameter") {
  let s = HasMethodWithDefaultArg()
  let z0 = s.isZero()
  expectTrue(z0)

  let z1 = s.isNonZero()
  expectTrue(z1)
}

DefaultArgTestSuite.test("constructor with integer parameter") {
  let a = HasCtorWithDefaultArg(1, 2, 3)
  expectEqual(a.value, 6)

  let b = HasCtorWithDefaultArg(1, 2)
  expectEqual(b.value, 126)

  let c = HasCtorWithDefaultArg(1)
  expectEqual(c.value, 580)
}
// RUN: not %target-swift-frontend -emit-sil -verify %s

// The testcase from https://github.com/apple/swift/issues/63728 is not valid
// (the function is not differentiable), however, it should not cause verifier errors
// Here the root case is lack of activity analysis for `try_apply` terminators


func a() throws {
    let keyPaths = (readable: [String: KeyPath<T, Double>](), writable: [String: WritableKeyPath<T, Double>]())
    @differentiable(reverse)
    func f(p: PAndT) -> Double {
        var mutableP = p
        let s = p.p.e
        var sArray: [[Double]] = []
        sArray.append((s["a"]!.asArray()).map {$0.value})
        mutableP.s = w(mutableP.s, at: keyPaths.writable["a"]!, with: sArray[0][0])
        return mutableP.s[keyPath: keyPaths.writable["a"]!]
    }
}

DefaultArgTestSuite.test("method in a templated class") {
  let t = TemplatedHasMethodWithDefaultArgFloat()
  let z0 = t.isZero()
  expectTrue(z0)

  let z1 = t.isZero(0.0 as Float)
  expectTrue(z1)

  let z2 = t.isNonZero()
  expectFalse(z2)
}

DefaultArgTestSuite.test("derived method with integer parameter") {
  let s = DerivedFromHasMethodWithDefaultArg()
  let z0 = s.isZero()
  expectTrue(z0)

  let z1 = s.isZero(0)
  expectTrue(z1)

  let s1 = DerivedFromDerivedFromHasMethodWithDefaultArg()
  let z2 = s1.isZero()
  expectTrue(z2)

  let z3 = s1.isZero(0)
  expectTrue(z3)
}

DefaultArgTestSuite.test("derived method from a templated class") {
  let s = DerivedFromTemplatedHasMethodWithDefaultArgFloat()
  let z0 = s.isZero()
  expectTrue(z0)

  let z1 = s.isNonZero()
  expectFalse(z1)
}

DefaultArgTestSuite.test("func with record parameter") {
  let z0 = isArgZero()
  expectTrue(z0)

  let z1 = isArgZero(ArgTy(value: 0))
  expectTrue(z1)

  let z2 = isArgZero(ArgTy(value: 1))
  expectFalse(z2)

  let z3 = isArgNonZero()
  expectTrue(z3)

  let z4 = isArgZeroOutOfLine()
  expectTrue(z4)

  let z5 = isArgViewNull(ArgTyView(ptr: nil))
  expectTrue(z5)

  let z6 = isArgOwnedPtrNull()
  expectTrue(z6)
}

DefaultArgTestSuite.test("func with immortal FRT parameter") {
  createFRT()

  let z0 = isArgFRTNull()
  expectTrue(z0)

  let v0 = getArgFRTValue()
  expectEqual(123, v0)

  globalFRT.value = 567
  let v1 = getArgFRTValue()
  expectEqual(567, v1)

  deleteFRT()
}

DefaultArgTestSuite.test("func with ref-counted FRT parameter") {
  let v0 = getArgRefCountedValue()
  expectEqual(321, v0)
}

DefaultArgTestSuite.test("func with const reference parameter") {
  let z0 = isArgZeroConstRef(ArgTy(value: 0))
  expectTrue(z0)
}

DefaultArgTestSuite.test("static method with parameter referring to field") {
  HasStaticMethodWithDefaultArg.value = 0
  let z0 = HasStaticMethodWithDefaultArg.isNonZero()
  expectFalse(z0)

  HasStaticMethodWithDefaultArg.value = 123
  let z1 = HasStaticMethodWithDefaultArg.isNonZero()
  expectTrue(z1)

  HasStaticMethodWithDefaultArg.counter = 0
  let z2 = HasStaticMethodWithDefaultArg.isNonZeroCounter()
  expectFalse(z2)
  let z3 = HasStaticMethodWithDefaultArg.isNonZeroCounter()
  expectTrue(z3)
}

runAllTests()

public struct S<I: SProtocol, D> {
    public func asArray() -> [(index: I, value: D)] {
        return [(index: I, value: D)]()
    }
}
struct T: Differentiable {}
struct P: Differentiable {
    public var e: F<Double, Double>
}

struct PAndT: Differentiable{
    @differentiable(reverse) public var p: P
    @differentiable(reverse) public var s: T
}

public struct F<I: SProtocol, D>{
    public func asArray() -> [(index: I, value: D)] {return [(index: I, value: D)]()}
    public subscript(_ name: String) -> S<I, D>? {get { return self.sGet(name) }}
    func sGet(_ name: String) -> S<I, D>? { fatalError("") }
}

public protocol ZProtocol: Differentiable {var z: () -> TangentVector { get }}
public protocol SProtocol: Hashable {}

//extension S: Differentiable where D: ZProtocol, D.TangentVector == D {}

extension F: Differentiable where D: ZProtocol, D.TangentVector == D {}
public extension ZProtocol {var z: () -> TangentVector {{ Self.TangentVector.zero }}}

extension F: Equatable where I: Equatable, D: Equatable {}
//extension S: Equatable where I: Equatable, D: Equatable {}
extension Double: SProtocol, ZProtocol {}

@differentiable(reverse where O: Differentiable, M: ZProtocol)
func w<O, M>(_ o: O, at m: WritableKeyPath<O, M>, with v: M) -> O {return o}

@derivative(of: w)
func vjpw<O, M>(_ o: O, at m: WritableKeyPath<O, M>, with v: M) -> (value: O, pullback: (O.TangentVector) -> (O.TangentVector, M.TangentVector)) where O: Differentiable, M: ZProtocol{fatalError("")}
// --- Seed B ---
// RUN: not %target-swift-frontend -emit-sil -verify %s

// The testcase from https://github.com/apple/swift/issues/63728 is not valid
// (the function is not differentiable), however, it should not cause verifier errors
// Here the root case is lack of activity analysis for `try_apply` terminators


func a_b5cda78() throws {
    let keyPaths = (readable: [String: KeyPath<T_b5cda78, Double>](), writable: [String: WritableKeyPath<T_b5cda78, Double>]())
    @differentiable(reverse)
    func f(p: PAndT_b5cda78) -> Double {
        var mutableP = p
        let s = p.p.e
        var sArray: [[Double]] = []
        sArray.append((s["a_b5cda78"]!.asArray()).map {$0.value})
        mutableP.s = w_b5cda78(mutableP.s, at: keyPaths.writable["a_b5cda78"]!, with: sArray[0][0])
        return mutableP.s[keyPath: keyPaths.writable["a_b5cda78"]!]
    }
}

public struct S_b5cda78<I: SProtocol_b5cda78, D> {
    public func asArray() -> [(index: I, value: D)] {
        return [(index: I, value: D)]()
    }
}
struct T_b5cda78: Differentiable {}
struct P_b5cda78: Differentiable {
    public var e: F_b5cda78<Double, Double>
}

struct PAndT_b5cda78: Differentiable{
    @differentiable(reverse) public var p: P_b5cda78
    @differentiable(reverse) public var s: T_b5cda78
}

public struct F_b5cda78<I: SProtocol_b5cda78, D>{
    public func asArray() -> [(index: I, value: D)] {return [(index: I, value: D)]()}
    public subscript(_ name: String) -> S_b5cda78<I, D>? {get { return self.sGet(name) }}
    func sGet(_ name: String) -> S_b5cda78<I, D>? { fatalError("") }
}

public protocol ZProtocol_b5cda78: Differentiable {var z: () -> TangentVector { get }}
public protocol SProtocol_b5cda78: Hashable {}

//extension S_b5cda78: Differentiable where D: ZProtocol_b5cda78, D.TangentVector == D {}

extension F_b5cda78: Differentiable where D: ZProtocol_b5cda78, D.TangentVector == z0 {}
public extension ZProtocol_b5cda78 {var z: () -> TangentVector {{ Self.TangentVector.zero }}}

extension F_b5cda78: Equatable where I: Equatable, D: Equatable {}
//extension S_b5cda78: Equatable where I: Equatable, D: Equatable {}
extension Double: SProtocol_b5cda78, ZProtocol_b5cda78 {}

@differentiable(reverse where O: Differentiable, M: ZProtocol_b5cda78)
func w_b5cda78<O, M>(_ o: O, at m: WritableKeyPath<O, M>, with v: M) -> O {return o}

@derivative(of: w_b5cda78)
func vjpw_b5cda78<O, M>(_ o: O, at m: WritableKeyPath<O, M>, with v: M) -> (value: O, pullback: (O.TangentVector) -> (O.TangentVector, M.TangentVector)) where O: Differentiable, M: ZProtocol_b5cda78{fatalError("")}
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
    let _ffl_r = Double(String(describing: z0).count)
    let _ffl_shapes: [any _FflShape] = [_FflCircle(r: _ffl_r), _FflRect(w: _ffl_r, h: 2.0)]
    _ = _ffl_p2_sum(_ffl_shapes)
    let _ffl_meta: any _FflShape.Type = _FflCircle.self
    _ = _ffl_meta.init(r: _ffl_r)
}
