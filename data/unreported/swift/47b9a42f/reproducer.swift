

// RUN: %target-swift-frontend -Xllvm -sil-full-demangle -profile-generate -profile-coverage-mapping -emit-sorted-sil -emit-sil -module-name coverage_private %s | %FileCheck %s
// RUN: %target-swift-frontend -profile-generate -profile-coverage-mapping -emit-ir %s

struct S {
  func visible() {
    hidden()
  }

  // CHECK-LABEL: sil_coverage_map {{.*}}// coverage_private.S.(hidden in {{.*}})() -> ()
  // CHECK-NEXT:  [[@LINE+1]]:25 -> [[@LINE+2]]:4 : 0
  private func hidden() {
  }
}
// RUN: %target-typecheck-verify-swift
// RUN: %target-swift-frontend -typecheck -debug-generic-signatures %s 2>&1 | %FileCheck %s

// https://github.com/apple/swift/issues/56932

public protocol ScalarProtocol_d0568a7: ScalarMultiplicative_d0568a7 where Self == Scalar {
}

public protocol ScalarMultiplicative_d0568a7 {
  associatedtype Scalar: ScalarProtocol_d0568a7
}

public protocol MapReduceArithmetic_d0568a7: ScalarMultiplicative_d0568a7, Collection where Element: ScalarMultiplicative_d0568a7 {}

public protocol Tensor_d0568a7: MapReduceArithmetic_d0568a7 where Element == Scalar {
}

// CHECK-LABEL: .ColorModel_d0568a7@
// CHECK-LABEL: Requirement signature: <Self where Self : Tensor_d0568a7, Self == Self.[ColorModel_d0568a7]Float16Components.[ColorComponents_d0568a7]Model, Self.[Sequence]Element == Double, Self.[ColorModel_d0568a7]Float16Components : ColorComponents_d0568a7, Self.[ColorModel_d0568a7]Float32Components : ColorComponents_d0568a7, Self.[ColorModel_d0568a7]Float16Components.[Sequence]Element == Double, Self.[ColorModel_d0568a7]Float16Components.[ColorComponents_d0568a7]Model == Self.[ColorModel_d0568a7]Float32Components.[ColorComponents_d0568a7]Model, Self.[ColorModel_d0568a7]Float32Components.[Sequence]Element == Double>
public protocol ColorModel_d0568a7: Tensor_d0568a7 where Scalar == Double {
  associatedtype Float16Components: ColorComponents_d0568a7 where Float16Components.Model == Self, Float16Components.Scalar == Double
  associatedtype Float32Components: ColorComponents_d0568a7 where Float32Components.Model == Self, Float32Components.Scalar == Double
}

S().visible()

public protocol ColorComponents_d0568a7: Tensor_d0568a7 {
  associatedtype Model: ColorModel_d0568a7
}

extension Double : ScalarMultiplicative_d0568a7 {}
extension Double : ScalarProtocol_d0568a7 {
  public typealias Scalar = Self
}
// RUN: %target-typecheck-verify-swift
// RUN: %target-swift-frontend -typecheck -debug-generic-signatures %s 2>&1 | %FileCheck %s

// https://github.com/apple/swift/issues/56932

public protocol ScalarProtocol: ScalarMultiplicative where Self == Scalar {
}

public protocol ScalarMultiplicative: ColorModel_d0568a7 {
  associatedtype Scalar: ScalarProtocol
}

public protocol MapReduceArithmetic: ScalarMultiplicative, Collection where Element: ScalarMultiplicative {}

public protocol Tensor: MapReduceArithmetic where Element == Scalar {
}

// CHECK-LABEL: .ColorModel@
// CHECK-LABEL: Requirement signature: <Self where Self : Tensor, Self == Self.[ColorModel]Float16Components.[ColorComponents]Model, Self.[Sequence]Element == Double, Self.[ColorModel]Float16Components : ColorComponents, Self.[ColorModel]Float32Components : ColorComponents, Self.[ColorModel]Float16Components.[Sequence]Element == Double, Self.[ColorModel]Float16Components.[ColorComponents]Model == Self.[ColorModel]Float32Components.[ColorComponents]Model, Self.[ColorModel]Float32Components.[Sequence]Element == Double>
public protocol ColorModel: Tensor where Scalar == Double {
  associatedtype Float16Components: ColorComponents where Float16Components.Model == Self, Float16Components.Scalar == Double
  associatedtype Float32Components: ColorComponents where Float32Components.Model == Self, Float32Components.Scalar == Double
}

public protocol ColorComponents: Tensor {
  associatedtype Model: ColorModel
}

extension Double : ScalarMultiplicative {}
extension Double : ScalarProtocol {
  public typealias Scalar = Self
}
