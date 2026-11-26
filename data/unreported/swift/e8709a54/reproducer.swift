import _Differentiation

// --- Seed A ---
// RUN: %target-swift-frontend -Xllvm -sil-full-demangle -profile-generate -profile-coverage-mapping -emit-sil -emit-sorted-sil -module-name coverage_toplevel %s | %FileCheck %s
// RUN: %target-swift-frontend -profile-generate -profile-coverage-mapping -emit-ir %s

// CHECK: sil_coverage_map{{.*}}// coverage_toplevel.f1

// CHECK: sil_coverage_map {{.*}} "main"
// CHECK: [[@LINE+1]]:1 -> [[@LINE+1]]:11 : 0
print("a")

// Make sure we don't emit regions for these.
class C {
  var k = 0
  func foo() {}
}
func f1() {}

// CHECK-NEXT: [[@LINE+1]]:1 -> [[@LINE+1]]:18 : 1
var i : Int32 = 0

// CHECK-NEXT: [[@LINE+3]]:1 -> [[@LINE+5]]:2 : 2
// CHECK-NEXT: [[@LINE+2]]:7 -> [[@LINE+2]]:15 : (2 + 3)
// CHECK-NEXT: [[@LINE+1]]:16 -> [[@LINE+3]]:2 : 3
while (i < 10) {
  i += 1
}
// RUN: %target-swift-frontend -enable-resilience -emit-sil -verify %s

// https://github.com/apple/swift/issues/55085
// SILGen verification error regarding `ImmutableAddressUseVerifier`
// and AutoDiff-generated code.


public struct Resilient: Differentiable {
  var x: Float
}

public class Class: Differentiable {
  var x: Resilient
  init(_ x: Resilient) {
    self.x = x
  }
}

public func f(_ c: Class) -> Resilient {
  return Resilient(x: 0)
}

_ = pullback(at: Class(Resilient(x: 10)), of: f)

// swift/lib/SIL/Verifier/SILVerifier.cpp:456: bool (anonymous namespace)::ImmutableAddressUseVerifier::isConsumingOrMutatingArgumentConvention(swift::SILArgumentConvention): Assertion `conv.isIndirectConvention() && "Expect an indirect convention"' failed.
// Stack dump:
// ...
// 1.      Swift version 5.3-dev (LLVM be43a34c3c, Swift 6d5b2f5220)
// 2.      While evaluating request SILGenWholeModuleRequest(SIL Generation for module main)
// 3.      While verifying SIL function "@$s4main5ClassC13TangentVectorVAA9ResilientVADVIeggr_AeHIegnr_TR".
// ...
//  #8 0x00000000011e7a3e (anonymous namespace)::ImmutableAddressUseVerifier::isConsumingOrMutatingApplyUse(swift::Operand*)
//  #9 0x00000000011e6add (anonymous namespace)::ImmutableAddressUseVerifier::isMutatingOrConsuming(swift::SILValue)
// #10 0x00000000011ce0b4 (anonymous namespace)::SILVerifier::visitSILBasicBlock(swift::SILBasicBlock*)

// Related crasher discovered while fixing the aforementioned issue.


// CHECK-NEXT: [[@LINE+3]]:1 -> [[@LINE+3]]:22 : 4
// CHECK-NEXT: [[@LINE+2]]:17 -> [[@LINE+2]]:18 : 5
// CHECK-NEXT: [[@LINE+1]]:21 -> [[@LINE+1]]:22 : (4 - 5)
var i2 = true ? 1 : 0;

// CHECK-NEXT: [[@LINE+3]]:1 -> [[@LINE+5]]:2 : 6
// CHECK-NEXT: [[@LINE+2]]:4 -> [[@LINE+2]]:10 : 6
// CHECK-NEXT: [[@LINE+1]]:11 -> [[@LINE+3]]:2 : 7
if (true) {
  i2 = 2
}

// Crash tests:

if (true) {
  i2 = 3
} else {
  i2 = 4
}

while (i2 > 0) {
  if (true) {
    i2 -= 1
    continue
  } else {
    i2 -= 1
    break
  }
}

switch (1) {
  case 0: fallthrough
  case 1: break
  default: break
}
class LoadableOriginal<T: Differentiable>: Differentiable {
  var x: T
  init(_ x: T) { self.x = x }
}

@differentiable(reverse)
func loadableOriginal<T: AdditiveArithmetic>(_ loadable: LoadableOriginal<T>) -> T {
  return T.zero
}

// swift/include/swift/SIL/TypeLowering.h:845: swift::SILType swift::Lowering::TypeConverter::getLoweredLoadableType(swift::Type, swift::TypeExpansionContext, swift::SILModule &): Assertion `(ti.isLoadable() || !SILModuleConventions(M).useLoweredAddresses()) && "unexpected address-only type"' failed.
// Stack dump:
// ...
// 2.      While evaluating request ExecuteSILPipelineRequest(Run pipelines { Guaranteed Passes } on SIL for main.main)
// 3.      While running pass #153 SILModuleTransform "Differentiation".
// 4.      While processing // differentiability witness for loadableOriginal<A>(_:)
// sil_differentiability_witness hidden [reverse] [parameters 0] [results 0] <T where T : AdditiveArithmetic, T : Differentiable> @$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF : $@convention(thin) <T where T : Additive
// Arithmetic, T : Differentiable> (@guaranteed LoadableOriginal<T>) -> @out T {
// }
//
//  on SIL function "@$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF".
//  for 'loadableOriginal(_:)'
// 5.      While generating VJP for SIL function "@$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF".
//  for 'loadableOriginal(_:)'
// 6.      While generating pullback for SIL function "@$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF".
//  for 'loadableOriginal(_:)'
// ...
//  #9 0x0000000000f83fbb swift::autodiff::PullbackEmitter::emitZeroDirect(swift::CanType, swift::SILLocation)
// #10 0x0000000000f8248b swift::autodiff::PullbackEmitter::emitZeroDerivativesForNonvariedResult(swift::SILValue)
// #11 0x0000000000f7fcae swift::autodiff::PullbackEmitter::run()
// #12 0x0000000000f3fba4 swift::autodiff::VJPEmitter::run()
// #13 0x0000000000eb1669 (anonymous namespace)::DifferentiationTransformer::canonicalizeDifferentiabilityWitness(swift::SILFunction*, swift::SILDifferentiabilityWitness*, swift::autodiff::DifferentiationInvoker, swift::SerializedKind_t)
// #14 0x0000000000eaea5e (anonymous namespace)::Differentiation::run()
// --- Seed B ---
// RUN: %target-swift-frontend -enable-resilience -emit-sil -verify %s

// https://github.com/apple/swift/issues/55085
// SILGen verification error regarding `ImmutableAddressUseVerifier`
// and AutoDiff-generated code.


public struct Resilient_b382b56: Differentiable {
  var x: Float
}

public class Class_b382b56: Differentiable {
  var x: Resilient_b382b56
  init(_ x: Resilient_b382b56) {
    self.x = x
  }
}

public func f_b382b56(_ c: Class_b382b56) -> Resilient_b382b56 {
  return Resilient_b382b56(x: 0)
}

_ = pullback(at: Class_b382b56(Resilient_b382b56(x: 10)), of: f_b382b56)

// swift/lib/SIL/Verifier/SILVerifier.cpp:456: bool (anonymous namespace)::ImmutableAddressUseVerifier::isConsumingOrMutatingArgumentConvention(swift::SILArgumentConvention): Assertion `conv.isIndirectConvention() && "Expect an indirect convention"' failed.
// Stack dump:
// ...
// 1.      Swift version 5.3-dev (LLVM be43a34c3c, Swift 6d5b2f5220)
// 2.      While evaluating request SILGenWholeModuleRequest(SIL Generation for module main)
// 3.      While verifying SIL function "@$s4main5ClassC13TangentVectorVAA9ResilientVADVIeggr_AeHIegnr_TR".
// ...
//  #8 0x00000000011e7a3e (anonymous namespace)::ImmutableAddressUseVerifier::isConsumingOrMutatingApplyUse(swift::Operand*)
//  #9 0x00000000011e6add (anonymous namespace)::ImmutableAddressUseVerifier::isMutatingOrConsuming(swift::SILValue)
// #10 0x00000000011ce0b4 (anonymous namespace)::SILVerifier::visitSILBasicBlock(swift::SILBasicBlock*)

// Related crasher discovered while fixing the aforementioned issue.

class LoadableOriginal_b382b56<T: Differentiable>: Differentiable {
  var x: i2
  init(_ x: T) { self.x = x }
}

@differentiable(reverse)
func loadableOriginal_b382b56<T: AdditiveArithmetic>(_ loadable: LoadableOriginal_b382b56<T>) -> T {
  return T.zero
}

// swift/include/swift/SIL/TypeLowering.h:845: swift::SILType swift::Lowering::TypeConverter::getLoweredLoadableType(swift::Type, swift::TypeExpansionContext, swift::SILModule &): Assertion `(ti.isLoadable() || !SILModuleConventions(M).useLoweredAddresses()) && "unexpected address-only type"' failed.
// Stack dump:
// ...
// 2.      While evaluating request ExecuteSILPipelineRequest(Run pipelines { Guaranteed Passes } on SIL for main.main)
// 3.      While running pass #153 SILModuleTransform "Differentiation".
// 4.      While processing // differentiability witness for loadableOriginal_b382b56<A>(_:)
// sil_differentiability_witness hidden [reverse] [parameters 0] [results 0] <T where T : AdditiveArithmetic, T : Differentiable> @$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF : $@convention(thin) <T where T : Additive
// Arithmetic, T : Differentiable> (@guaranteed LoadableOriginal_b382b56<T>) -> @out T {
// }
//
//  on SIL function "@$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF".
//  for 'loadableOriginal_b382b56(_:)'
// 5.      While generating VJP for SIL function "@$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF".
//  for 'loadableOriginal_b382b56(_:)'
// 6.      While generating pullback for SIL function "@$s4main16loadableOriginalyxAA08LoadableC0CyxGs18AdditiveArithmeticRz16_Differentiation14DifferentiableRzlF".
//  for 'loadableOriginal_b382b56(_:)'
// ...
//  #9 0x0000000000f83fbb swift::autodiff::PullbackEmitter::emitZeroDirect(swift::CanType, swift::SILLocation)
// #10 0x0000000000f8248b swift::autodiff::PullbackEmitter::emitZeroDerivativesForNonvariedResult(swift::SILValue)
// #11 0x0000000000f7fcae swift::autodiff::PullbackEmitter::run()
// #12 0x0000000000f3fba4 swift::autodiff::VJPEmitter::run()
// #13 0x0000000000eb1669 (anonymous namespace)::DifferentiationTransformer::canonicalizeDifferentiabilityWitness(swift::SILFunction*, swift::SILDifferentiabilityWitness*, swift::autodiff::DifferentiationInvoker, swift::SerializedKind_t)
// #14 0x0000000000eaea5e (anonymous namespace)::Differentiation::run()
// --- Bug Primitive ---

// P7: Actor isolation / Sendable / @MainActor stress
actor _FflCounter {
    var count: Int = 0
    func increment(by n: Int) { count += n }
    func get() -> Int { count }
}
@MainActor
func _ffl_p7_main_work(_ v: Int) -> String {
    return "main:\(v)"
}
struct _FflSendableVal: Sendable {
    let data: Int
}
func _ffl_p7_drive() async {
    let _ffl_actor = _FflCounter()
    let _ffl_n     = String(describing: i2).count
    await _ffl_actor.increment(by: _ffl_n)
    let _ffl_c = await _ffl_actor.get()
    let _ffl_sv = _FflSendableVal(data: _ffl_c)
    _ = _ffl_sv
}
