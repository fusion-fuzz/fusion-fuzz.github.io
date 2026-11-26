

// --- Seed A ---


// RUN: %target-swift-emit-sil -sil-verify-all -verify %s


class CopyableKlass {}
protocol P {}
extension CopyableKlass : P {}

public struct NonTrivialStruct : ~Copyable {
    var k = CopyableKlass()
}

public struct AddressOnlyMoveOnlyContainingProtocol : ~Copyable {
    var copyable: any P = CopyableKlass()
    var moveOnly = NonTrivialStruct()

    func nonMutatingFunc() {}
    mutating func mutatingFunc() {}
}

// MARK: Getter Only

public struct LoadableSubscriptGetOnlyTester : ~Copyable {
    subscript(_ i: Int) -> AddressOnlyMoveOnlyContainingProtocol {
        get {
            fatalError()
        }
    }
}

public func testSubscriptGetOnly_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetOnlyTester()
    m = LoadableSubscriptGetOnlyTester()
    m[0].nonMutatingFunc()
}

public func testSubscriptGetOnly_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptGetOnlyTester()
    m[0].nonMutatingFunc()
}
// RUN: %target-swift-frontend -typecheck %s -debug-generic-signatures 2>&1 | %FileCheck %s

class A_d96ab61<T, U, V> {}

class B_d96ab61<X, Y, Z, W> : A_d96ab61<X, (Y) -> Z, Int> {}

class C_d96ab61<I, J : Sequence, K> : B_d96ab61<String, I, [J.Element], K> {}


// ---------------------------------------------- //
// Unifying two requirements in the same protocol //
// ---------------------------------------------- //

// CHECK-LABEL: .Pab_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pab_d96ab61]A1 == Self.[Pab_d96ab61]B1,
// CHECK-SAME: Self.[Pab_d96ab61]A2 == (Self.[Pab_d96ab61]B2) -> Self.[Pab_d96ab61]B3,
// CHECK-SAME: Self.[Pab_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pab_d96ab61]T : B_d96ab61<Self.[Pab_d96ab61]A1, Self.[Pab_d96ab61]B2, Self.[Pab_d96ab61]B3, Self.[Pab_d96ab61]B4>>

protocol Pab_d96ab61 {
  associatedtype T where T : A_d96ab61<A1, A2, A3>, T : B_d96ab61<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .Pba_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pba_d96ab61]A1 == Self.[Pba_d96ab61]B1,
// CHECK-SAME: Self.[Pba_d96ab61]A2 == (Self.[Pba_d96ab61]B2) -> Self.[Pba_d96ab61]B3,
// CHECK-SAME: Self.[Pba_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pba_d96ab61]T : B_d96ab61<Self.[Pba_d96ab61]A1, Self.[Pba_d96ab61]B2, Self.[Pba_d96ab61]B3, Self.[Pba_d96ab61]B4>>

protocol Pba_d96ab61 {
  associatedtype T where T : B_d96ab61<B1, B2, B3, B4>, T : A_d96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .Pac_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pac_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pac_d96ab61]A2 == (Self.[Pac_d96ab61]C1) -> [Self.[Pac_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pac_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pac_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pac_d96ab61]T : C_d96ab61<Self.[Pac_d96ab61]C1, Self.[Pac_d96ab61]C2, Self.[Pac_d96ab61]C3>>

protocol Pac_d96ab61 {
  associatedtype T where T : A_d96ab61<A1, A2, A3>, T : C_d96ab61<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pca_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pca_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pca_d96ab61]A2 == (Self.[Pca_d96ab61]C1) -> [Self.[Pca_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pca_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pca_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pca_d96ab61]T : C_d96ab61<Self.[Pca_d96ab61]C1, Self.[Pca_d96ab61]C2, Self.[Pca_d96ab61]C3>>

protocol Pca_d96ab61 {
  associatedtype T where T : C_d96ab61<C1, C2, C3>, T : A_d96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbc_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbc_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pbc_d96ab61]B2 == Self.[Pbc_d96ab61]C1,
// CHECK-SAME: Self.[Pbc_d96ab61]B3 == [Self.[Pbc_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbc_d96ab61]B4 == Self.[Pbc_d96ab61]C3,

// CHECK-SAME: Self.[Pbc_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pbc_d96ab61]T : C_d96ab61<Self.[Pbc_d96ab61]B2, Self.[Pbc_d96ab61]C2, Self.[Pbc_d96ab61]B4>>

protocol Pbc_d96ab61 {
  associatedtype T where T : B_d96ab61<B1, B2, B3, B4>, T : C_d96ab61<C1, C2, C3>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcb_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcb_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pcb_d96ab61]B2 == Self.[Pcb_d96ab61]C1,
// CHECK-SAME: Self.[Pcb_d96ab61]B3 == [Self.[Pcb_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcb_d96ab61]B4 == Self.[Pcb_d96ab61]C3,

// CHECK-SAME: Self.[Pcb_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pcb_d96ab61]T : C_d96ab61<Self.[Pcb_d96ab61]B2, Self.[Pcb_d96ab61]C2, Self.[Pcb_d96ab61]B4>>

protocol Pcb_d96ab61 {
  associatedtype T where T : C_d96ab61<C1, C2, C3>, T : B_d96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}


// ------------------------------------------------ //
// Unifying three requirements in the same protocol //
// ------------------------------------------------ //

// CHECK-LABEL: .Pabc_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pabc_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pabc_d96ab61]A2 == (Self.[Pabc_d96ab61]B2) -> [Self.[Pabc_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pabc_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pabc_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pabc_d96ab61]B2 == Self.[Pabc_d96ab61]C1,
// CHECK-SAME: Self.[Pabc_d96ab61]B3 == [Self.[Pabc_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pabc_d96ab61]B4 == Self.[Pabc_d96ab61]C3,

// CHECK-SAME: Self.[Pabc_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pabc_d96ab61]T : C_d96ab61<Self.[Pabc_d96ab61]B2, Self.[Pabc_d96ab61]C2, Self.[Pabc_d96ab61]B4>>

protocol Pabc_d96ab61 {
  associatedtype T where T : A_d96ab61<A1, A2, A3>, T : B_d96ab61<B1, B2, B3, B4>, T : C_d96ab61<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pacb_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pacb_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pacb_d96ab61]A2 == (Self.[Pacb_d96ab61]B2) -> [Self.[Pacb_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pacb_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pacb_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pacb_d96ab61]B2 == Self.[Pacb_d96ab61]C1,
// CHECK-SAME: Self.[Pacb_d96ab61]B3 == [Self.[Pacb_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pacb_d96ab61]B4 == Self.[Pacb_d96ab61]C3,

// CHECK-SAME: Self.[Pacb_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pacb_d96ab61]T : C_d96ab61<Self.[Pacb_d96ab61]B2, Self.[Pacb_d96ab61]C2, Self.[Pacb_d96ab61]B4>>

protocol Pacb_d96ab61 {
  associatedtype T where T : A_d96ab61<A1, A2, A3>, T : C_d96ab61<C1, C2, C3>, T : B_d96ab61<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbac_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbac_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pbac_d96ab61]A2 == (Self.[Pbac_d96ab61]B2) -> [Self.[Pbac_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbac_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pbac_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pbac_d96ab61]B2 == Self.[Pbac_d96ab61]C1,
// CHECK-SAME: Self.[Pbac_d96ab61]B3 == [Self.[Pbac_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbac_d96ab61]B4 == Self.[Pbac_d96ab61]C3,

// CHECK-SAME: Self.[Pbac_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pbac_d96ab61]T : C_d96ab61<Self.[Pbac_d96ab61]B2, Self.[Pbac_d96ab61]C2, Self.[Pbac_d96ab61]B4>>

protocol Pbac_d96ab61 {
  associatedtype T where T : B_d96ab61<B1, B2, B3, B4>, T : A_d96ab61<A1, A2, A3>, T : C_d96ab61<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbca_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbca_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pbca_d96ab61]A2 == (Self.[Pbca_d96ab61]B2) -> [Self.[Pbca_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbca_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pbca_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pbca_d96ab61]B2 == Self.[Pbca_d96ab61]C1,
// CHECK-SAME: Self.[Pbca_d96ab61]B3 == [Self.[Pbca_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbca_d96ab61]B4 == Self.[Pbca_d96ab61]C3,

// CHECK-SAME: Self.[Pbca_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pbca_d96ab61]T : C_d96ab61<Self.[Pbca_d96ab61]B2, Self.[Pbca_d96ab61]C2, Self.[Pbca_d96ab61]B4>>

protocol Pbca_d96ab61 {
  associatedtype T where T : B_d96ab61<B1, B2, B3, B4>, T : C_d96ab61<C1, C2, C3>, T : A_d96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcab_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcab_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pcab_d96ab61]A2 == (Self.[Pcab_d96ab61]B2) -> [Self.[Pcab_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcab_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pcab_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pcab_d96ab61]B2 == Self.[Pcab_d96ab61]C1,
// CHECK-SAME: Self.[Pcab_d96ab61]B3 == [Self.[Pcab_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcab_d96ab61]B4 == Self.[Pcab_d96ab61]C3,

// CHECK-SAME: Self.[Pcab_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pcab_d96ab61]T : C_d96ab61<Self.[Pcab_d96ab61]B2, Self.[Pcab_d96ab61]C2, Self.[Pcab_d96ab61]B4>>

protocol Pcab_d96ab61 {
  associatedtype T where T : C_d96ab61<C1, C2, C3>, T : A_d96ab61<A1, A2, A3>, T : B_d96ab61<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcba_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcba_d96ab61]A1 == String,
// CHECK-SAME: Self.[Pcba_d96ab61]A2 == (Self.[Pcba_d96ab61]B2) -> [Self.[Pcba_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcba_d96ab61]A3 == Int,

// CHECK-SAME: Self.[Pcba_d96ab61]B1 == String,
// CHECK-SAME: Self.[Pcba_d96ab61]B2 == Self.[Pcba_d96ab61]C1,
// CHECK-SAME: Self.[Pcba_d96ab61]B3 == [Self.[Pcba_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcba_d96ab61]B4 == Self.[Pcba_d96ab61]C3,

// CHECK-SAME: Self.[Pcba_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pcba_d96ab61]T : C_d96ab61<Self.[Pcba_d96ab61]B2, Self.[Pcba_d96ab61]C2, Self.[Pcba_d96ab61]B4>>

protocol Pcba_d96ab61 {
  associatedtype T where T : C_d96ab61<C1, C2, C3>, T : B_d96ab61<B1, B2, B3, B4>, T : A_d96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}


// --------------------------------------------------------- //
// Unifying two requirements in another and current protocol //
// --------------------------------------------------------- //

protocol Pa_d96ab61 {
  associatedtype T where T : A_d96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

protocol Pb_d96ab61 {
  associatedtype T where T : B_d96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

protocol Pc_d96ab61 {
  associatedtype T where T : C_d96ab61<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PaQb_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PaQb_d96ab61]T : Pa_d96ab61,

// CHECK-SAME: Self.[PaQb_d96ab61]T.[Pa_d96ab61]T : B_d96ab61<Self.[PaQb_d96ab61]B1, Self.[PaQb_d96ab61]B2, Self.[PaQb_d96ab61]B3, Self.[PaQb_d96ab61]B4>>

protocol PaQb_d96ab61 {
  associatedtype T : Pa_d96ab61 where T.T : B_d96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .PbQa_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PbQa_d96ab61]A1 == Self.[PbQa_d96ab61]T.[Pb_d96ab61]B1,
// CHECK-SAME: Self.[PbQa_d96ab61]A2 == (Self.[PbQa_d96ab61]T.[Pb_d96ab61]B2) -> Self.[PbQa_d96ab61]T.[Pb_d96ab61]B3,
// CHECK-SAME: Self.[PbQa_d96ab61]A3 == Int,

// CHECK-SAME: Self.[PbQa_d96ab61]T : Pb_d96ab61>

protocol PbQa_d96ab61 {
  associatedtype T : Pb_d96ab61 where T.T : A_d96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

// CHECK-LABEL: .PaQc_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PaQc_d96ab61]C2 : Sequence,

// CHECK-SAME: Self.[PaQc_d96ab61]T : Pa_d96ab61,

// CHECK-SAME: Self.[PaQc_d96ab61]T.[Pa_d96ab61]T : C_d96ab61<Self.[PaQc_d96ab61]C1, Self.[PaQc_d96ab61]C2, Self.[PaQc_d96ab61]C3>>

protocol PaQc_d96ab61 {
  associatedtype T : Pa_d96ab61 where T.T : C_d96ab61<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PcQa_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PcQa_d96ab61]A1 == String,
// CHECK-SAME: Self.[PcQa_d96ab61]A2 == (Self.[PcQa_d96ab61]T.[Pc_d96ab61]C1) -> [Self.[PcQa_d96ab61]T.[Pc_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[PcQa_d96ab61]A3 == Int,

// CHECK-SAME: Self.[PcQa_d96ab61]T : Pc_d96ab61>

protocol PcQa_d96ab61 {
  associatedtype T : Pc_d96ab61 where T.T : A_d96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

// CHECK-LABEL: .PbQc_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PbQc_d96ab61]C2 : Sequence,


public func testSubscriptGetOnly_BaseLoadable_ResultAddressOnly_InOut(m: inout LoadableSubscriptGetOnlyTester) {
    m[0].nonMutatingFunc()
}

var globalLoadableSubscriptGetOnlyTester = LoadableSubscriptGetOnlyTester()
public func testSubscriptGetOnly_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptGetOnlyTester[0].nonMutatingFunc()
}

// Make sure that we get the same behavior when we access through another noncopyable struct.
public struct LoadableSubscriptGetOnlyTesterNonCopyableStructParent : ~Copyable {
    var tester = LoadableSubscriptGetOnlyTester()
    var computedTester: LoadableSubscriptGetOnlyTester { fatalError() }
}

public func testSubscriptGetOnlyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetOnlyTesterNonCopyableStructParent()
    m = LoadableSubscriptGetOnlyTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
    m.computedTester[0].nonMutatingFunc()
}

public func testSubscriptGetOnlyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptGetOnlyTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
}

public func testSubscriptGetOnlyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_InOut(m: inout LoadableSubscriptGetOnlyTesterNonCopyableStructParent) {
    m.tester[0].nonMutatingFunc()
}

var globalLoadableSubscriptGetOnlyTesterNonCopyableStructParent = LoadableSubscriptGetOnlyTesterNonCopyableStructParent()
public func testSubscriptGetOnlyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptGetOnlyTesterNonCopyableStructParent.tester[0].nonMutatingFunc()
}

public class LoadableSubscriptGetOnlyTesterClassParent {
    var tester = LoadableSubscriptGetOnlyTester()
    var computedTester: LoadableSubscriptGetOnlyTester { fatalError() }
    var testerParent = LoadableSubscriptGetOnlyTesterNonCopyableStructParent()
}

public func testSubscriptGetOnlyThroughParentClass_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetOnlyTesterClassParent()
    m = LoadableSubscriptGetOnlyTesterClassParent()
    m.tester[0].nonMutatingFunc()
    m.testerParent.tester[0].nonMutatingFunc()
    m.computedTester[0].nonMutatingFunc()
}

// MARK: Getter + Setter.
// This is different since adding a setter changes how we codegen.

public struct LoadableSubscriptGetSetTester : ~Copyable {
    subscript(_ i: Int) -> AddressOnlyMoveOnlyContainingProtocol {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}

public func testSubscriptGetSet_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetSetTester()
    m = LoadableSubscriptGetSetTester()
    m[0].nonMutatingFunc()
    m[0] = AddressOnlyMoveOnlyContainingProtocol()
    m[0].mutatingFunc()
}

public func testSubscriptGetSet_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptGetSetTester()
    m[0].nonMutatingFunc()
}

public func testSubscriptGetSet_BaseLoadable_ResultAddressOnly_InOut(m: inout LoadableSubscriptGetSetTester) {
    m[0].nonMutatingFunc()
    m[0] = AddressOnlyMoveOnlyContainingProtocol()
    m[0].mutatingFunc()
}

var globalLoadableSubscriptGetSetTester = LoadableSubscriptGetSetTester()
public func testSubscriptGetSet_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptGetSetTester[0].nonMutatingFunc()
    globalLoadableSubscriptGetSetTester[0] = AddressOnlyMoveOnlyContainingProtocol()
    globalLoadableSubscriptGetSetTester[0].mutatingFunc()
}

// Make sure that we get the same behavior when we access through another noncopyable struct.
public struct LoadableSubscriptGetSetTesterNonCopyableStructParent : ~Copyable {
    var tester = LoadableSubscriptGetSetTester()
    var computedTester: LoadableSubscriptGetSetTester { fatalError() }
}

public func testSubscriptGetSetThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetSetTesterNonCopyableStructParent()
    m = LoadableSubscriptGetSetTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
    m.computedTester[0].nonMutatingFunc()
}

public func testSubscriptGetSetThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptGetSetTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
}

public func testSubscriptGetSetThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_InOut(m: inout LoadableSubscriptGetSetTesterNonCopyableStructParent) {
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
}

var globalLoadableSubscriptGetSetTesterNonCopyableStructParent = LoadableSubscriptGetSetTesterNonCopyableStructParent()
public func testSubscriptGetSetThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptGetSetTesterNonCopyableStructParent.tester[0].nonMutatingFunc()
    globalLoadableSubscriptGetSetTesterNonCopyableStructParent.tester[0].mutatingFunc()
}

public class LoadableSubscriptGetSetTesterClassParent {
    var tester = LoadableSubscriptGetSetTester()
    var computedTester: LoadableSubscriptGetSetTester { fatalError() }
    var computedTester2: LoadableSubscriptGetSetTester {
        get { fatalError() }
        set { fatalError() }
    }
    var testerParent = LoadableSubscriptGetSetTesterNonCopyableStructParent()
}

public func testSubscriptGetSetThroughParentClass_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetSetTesterClassParent()
    m = LoadableSubscriptGetSetTesterClassParent()
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
    m.testerParent.tester[0].nonMutatingFunc()
    m.testerParent.tester[0].mutatingFunc()
    m.computedTester[0].nonMutatingFunc()
    m.computedTester2[0].nonMutatingFunc()
    m.computedTester2[0].mutatingFunc()
}

// MARK: _read and _modify

public struct LoadableSubscriptReadModifyTester : ~Copyable {
    subscript(_ i: Int) -> AddressOnlyMoveOnlyContainingProtocol {
        _read {
            fatalError()
        }
        _modify {
            fatalError()
        }
    }
}

public func testSubscriptReadModify_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptReadModifyTester()
    m = LoadableSubscriptReadModifyTester()
    m[0].nonMutatingFunc()
    m[0] = AddressOnlyMoveOnlyContainingProtocol()
    m[0].mutatingFunc()
}

public func testSubscriptReadModify_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptReadModifyTester()
    m[0].nonMutatingFunc()
}

public func testSubscriptReadModify_BaseLoadable_ResultAddressOnly_InOut(m: inout LoadableSubscriptReadModifyTester) {
    m[0].nonMutatingFunc()
    m[0] = AddressOnlyMoveOnlyContainingProtocol()
    m[0].mutatingFunc()
}

var globalLoadableSubscriptReadModifyTester = LoadableSubscriptReadModifyTester()
public func testSubscriptReadModify_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptReadModifyTester[0].nonMutatingFunc()
    globalLoadableSubscriptReadModifyTester[0] = AddressOnlyMoveOnlyContainingProtocol()
    globalLoadableSubscriptReadModifyTester[0].mutatingFunc()
}

// Make sure that we get the same behavior when we access through another noncopyable struct.
public struct LoadableSubscriptReadModifyTesterNonCopyableStructParent : ~Copyable {
    var tester = LoadableSubscriptReadModifyTester()
    var computedTester: LoadableSubscriptReadModifyTester { fatalError() }
}

public func testSubscriptReadModifyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptReadModifyTesterNonCopyableStructParent()
    m = LoadableSubscriptReadModifyTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
    m.computedTester[0].nonMutatingFunc()
}


public func testSubscriptReadModifyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptReadModifyTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
}

public func testSubscriptReadModifyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_InOut(m: inout LoadableSubscriptReadModifyTesterNonCopyableStructParent) {
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
}

var globalLoadableSubscriptReadModifyTesterNonCopyableStructParent = LoadableSubscriptReadModifyTesterNonCopyableStructParent()
public func testSubscriptReadModifyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptReadModifyTesterNonCopyableStructParent.tester[0].nonMutatingFunc()
    globalLoadableSubscriptReadModifyTesterNonCopyableStructParent.tester[0].mutatingFunc()
}

public class LoadableSubscriptReadModifyTesterClassParent {
    var tester = LoadableSubscriptReadModifyTester()
    var computedTester: LoadableSubscriptReadModifyTester { fatalError() }
    var computedTester2: LoadableSubscriptReadModifyTester {
        get { fatalError() }
        set { fatalError() }
    }
    var testerParent = LoadableSubscriptReadModifyTesterNonCopyableStructParent()
}

public func testSubscriptReadModifyThroughParentClass_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptReadModifyTesterClassParent()
    m = LoadableSubscriptReadModifyTesterClassParent()
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
    m.testerParent.tester[0].nonMutatingFunc()
    m.testerParent.tester[0].mutatingFunc()
    m.computedTester[0].nonMutatingFunc()
    m.computedTester2[0].nonMutatingFunc()
    m.computedTester2[0].mutatingFunc()
}

// MARK: get and _modify

public struct LoadableSubscriptGetModifyTester : ~Copyable {
    subscript(_ i: Int) -> AddressOnlyMoveOnlyContainingProtocol {
        get {
            fatalError()
        }
        _modify {
            fatalError()
        }
    }
}

public func testSubscriptGetModify_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetModifyTester()
    m = LoadableSubscriptGetModifyTester()
    m[0].nonMutatingFunc()
    m[0] = AddressOnlyMoveOnlyContainingProtocol()
    m[0].mutatingFunc()
}

public func testSubscriptGetModify_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptGetModifyTester()
    m[0].nonMutatingFunc()
}

public func testSubscriptGetModify_BaseLoadable_ResultAddressOnly_InOut(m: inout LoadableSubscriptGetModifyTester) {
    m[0].nonMutatingFunc()
    m[0] = AddressOnlyMoveOnlyContainingProtocol()
    m[0].mutatingFunc()
}

var globalLoadableSubscriptGetModifyTester = LoadableSubscriptGetModifyTester()
public func testSubscriptGetModify_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptGetModifyTester[0].nonMutatingFunc()
    globalLoadableSubscriptGetModifyTester[0] = AddressOnlyMoveOnlyContainingProtocol()
    globalLoadableSubscriptGetModifyTester[0].mutatingFunc()
}

// Make sure that we get the same behavior when we access through another noncopyable struct.
public struct LoadableSubscriptGetModifyTesterNonCopyableStructParent : ~Copyable {
    var tester = LoadableSubscriptGetModifyTester()
    var computedTester: LoadableSubscriptGetModifyTester { fatalError() }
}

public func testSubscriptGetModifyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetModifyTesterNonCopyableStructParent()
    m = LoadableSubscriptGetModifyTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
    m.computedTester[0].nonMutatingFunc()
}

public func testSubscriptGetModifyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Let() {
    let m = LoadableSubscriptGetModifyTesterNonCopyableStructParent()
    m.tester[0].nonMutatingFunc()
}

var globalLoadableSubscriptGetModifyTesterNonCopyableStructParent = LoadableSubscriptGetModifyTesterNonCopyableStructParent()
public func testSubscriptGetModifyThroughNonCopyableParentStruct_BaseLoadable_ResultAddressOnly_Global() {
    globalLoadableSubscriptGetModifyTesterNonCopyableStructParent.tester[0].nonMutatingFunc()
    globalLoadableSubscriptGetModifyTesterNonCopyableStructParent.tester[0].mutatingFunc()
}

public class LoadableSubscriptGetModifyTesterClassParent {
    var tester = LoadableSubscriptGetModifyTester()
    var computedTester: LoadableSubscriptGetModifyTester { fatalError() }
    var computedTester2: LoadableSubscriptGetModifyTester {
        get { fatalError() }
        set { fatalError() }
    }
    var testerParent = LoadableSubscriptGetModifyTesterNonCopyableStructParent()
}

public func testSubscriptGetModifyThroughParentClass_BaseLoadable_ResultAddressOnly_Var() {
    var m = LoadableSubscriptGetModifyTesterClassParent()
    m = LoadableSubscriptGetModifyTesterClassParent()
    m.tester[0].nonMutatingFunc()
    m.tester[0].mutatingFunc()
    m.testerParent.tester[0].nonMutatingFunc()
    m.testerParent.tester[0].mutatingFunc()
    m.computedTester[0].nonMutatingFunc()
    m.computedTester2[0].nonMutatingFunc()
    m.computedTester2[0].mutatingFunc()
}
// RUN: %target-swift-frontend -typecheck %s -debug-generic-signatures 2>&1 | %FileCheck %s

class A<T, U, V> {}

class B<X, Y, Z, W>: LoadableSubscriptGetModifyTesterClassParent, A<X, (Y) -> Z, Int> {}

class C<I, J : Sequence, K> : B<String, I, [J.Element], K> {}


// ---------------------------------------------- //
// Unifying two requirements in the same protocol //
// ---------------------------------------------- //

// CHECK-LABEL: .Pab@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pab]A1 == Self.[Pab]B1,
// CHECK-SAME: Self.[Pab]A2 == (Self.[Pab]B2) -> Self.[Pab]B3,
// CHECK-SAME: Self.[Pab]A3 == Int,

// CHECK-SAME: Self.[Pab]T : B<Self.[Pab]A1, Self.[Pab]B2, Self.[Pab]B3, Self.[Pab]B4>>

protocol Pab {
  associatedtype T where T : A<A1, A2, A3>, T : B<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .Pba@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pba]A1 == Self.[Pba]B1,
// CHECK-SAME: Self.[Pba]A2 == (Self.[Pba]B2) -> Self.[Pba]B3,
// CHECK-SAME: Self.[Pba]A3 == Int,

// CHECK-SAME: Self.[Pba]T : B<Self.[Pba]A1, Self.[Pba]B2, Self.[Pba]B3, Self.[Pba]B4>>

protocol Pba {
  associatedtype T where T : B<B1, B2, B3, B4>, T : A<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .Pac@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pac]A1 == String,
// CHECK-SAME: Self.[Pac]A2 == (Self.[Pac]C1) -> [Self.[Pac]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pac]A3 == Int,

// CHECK-SAME: Self.[Pac]C2 : Sequence,

// CHECK-SAME: Self.[Pac]T : C<Self.[Pac]C1, Self.[Pac]C2, Self.[Pac]C3>>

protocol Pac {
  associatedtype T where T : A<A1, A2, A3>, T : C<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pca@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pca]A1 == String,
// CHECK-SAME: Self.[Pca]A2 == (Self.[Pca]C1) -> [Self.[Pca]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pca]A3 == Int,

// CHECK-SAME: Self.[Pca]C2 : Sequence,

// CHECK-SAME: Self.[Pca]T : C<Self.[Pca]C1, Self.[Pca]C2, Self.[Pca]C3>>

protocol Pca {
  associatedtype T where T : C<C1, C2, C3>, T : A<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbc@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbc]B1 == String,
// CHECK-SAME: Self.[Pbc]B2 == Self.[Pbc]C1,
// CHECK-SAME: Self.[Pbc]B3 == [Self.[Pbc]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbc]B4 == Self.[Pbc]C3,

// CHECK-SAME: Self.[Pbc]C2 : Sequence,

// CHECK-SAME: Self.[Pbc]T : C<Self.[Pbc]B2, Self.[Pbc]C2, Self.[Pbc]B4>>

protocol Pbc {
  associatedtype T where T : B<B1, B2, B3, B4>, T : C<C1, C2, C3>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcb@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcb]B1 == String,
// CHECK-SAME: Self.[Pcb]B2 == Self.[Pcb]C1,
// CHECK-SAME: Self.[Pcb]B3 == [Self.[Pcb]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcb]B4 == Self.[Pcb]C3,

// CHECK-SAME: Self.[Pcb]C2 : Sequence,

// CHECK-SAME: Self.[Pcb]T : C<Self.[Pcb]B2, Self.[Pcb]C2, Self.[Pcb]B4>>

protocol Pcb {
  associatedtype T where T : C<C1, C2, C3>, T : B<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}


// ------------------------------------------------ //
// Unifying three requirements in the same protocol //
// ------------------------------------------------ //

// CHECK-LABEL: .Pabc@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pabc]A1 == String,
// CHECK-SAME: Self.[Pabc]A2 == (Self.[Pabc]B2) -> [Self.[Pabc]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pabc]A3 == Int,

// CHECK-SAME: Self.[Pabc]B1 == String,
// CHECK-SAME: Self.[Pabc]B2 == Self.[Pabc]C1,
// CHECK-SAME: Self.[Pabc]B3 == [Self.[Pabc]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pabc]B4 == Self.[Pabc]C3,

// CHECK-SAME: Self.[Pabc]C2 : Sequence,

// CHECK-SAME: Self.[Pabc]T : C<Self.[Pabc]B2, Self.[Pabc]C2, Self.[Pabc]B4>>

protocol Pabc {
  associatedtype T where T : A<A1, A2, A3>, T : B<B1, B2, B3, B4>, T : C<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pacb@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pacb]A1 == String,
// CHECK-SAME: Self.[Pacb]A2 == (Self.[Pacb]B2) -> [Self.[Pacb]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pacb]A3 == Int,

// CHECK-SAME: Self.[Pacb]B1 == String,
// CHECK-SAME: Self.[Pacb]B2 == Self.[Pacb]C1,
// CHECK-SAME: Self.[Pacb]B3 == [Self.[Pacb]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pacb]B4 == Self.[Pacb]C3,

// CHECK-SAME: Self.[Pacb]C2 : Sequence,

// CHECK-SAME: Self.[Pacb]T : C<Self.[Pacb]B2, Self.[Pacb]C2, Self.[Pacb]B4>>

protocol Pacb {
  associatedtype T where T : A<A1, A2, A3>, T : C<C1, C2, C3>, T : B<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbac@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbac]A1 == String,
// CHECK-SAME: Self.[Pbac]A2 == (Self.[Pbac]B2) -> [Self.[Pbac]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbac]A3 == Int,

// CHECK-SAME: Self.[Pbac]B1 == String,
// CHECK-SAME: Self.[Pbac]B2 == Self.[Pbac]C1,
// CHECK-SAME: Self.[Pbac]B3 == [Self.[Pbac]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbac]B4 == Self.[Pbac]C3,

// CHECK-SAME: Self.[Pbac]C2 : Sequence,

// CHECK-SAME: Self.[Pbac]T : C<Self.[Pbac]B2, Self.[Pbac]C2, Self.[Pbac]B4>>

protocol Pbac {
  associatedtype T where T : B<B1, B2, B3, B4>, T : A<A1, A2, A3>, T : C<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbca@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbca]A1 == String,
// CHECK-SAME: Self.[Pbca]A2 == (Self.[Pbca]B2) -> [Self.[Pbca]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbca]A3 == Int,

// CHECK-SAME: Self.[Pbca]B1 == String,
// CHECK-SAME: Self.[Pbca]B2 == Self.[Pbca]C1,
// CHECK-SAME: Self.[Pbca]B3 == [Self.[Pbca]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbca]B4 == Self.[Pbca]C3,

// CHECK-SAME: Self.[Pbca]C2 : Sequence,

// CHECK-SAME: Self.[Pbca]T : C<Self.[Pbca]B2, Self.[Pbca]C2, Self.[Pbca]B4>>

protocol Pbca {
  associatedtype T where T : B<B1, B2, B3, B4>, T : C<C1, C2, C3>, T : A<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcab@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcab]A1 == String,
// CHECK-SAME: Self.[Pcab]A2 == (Self.[Pcab]B2) -> [Self.[Pcab]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcab]A3 == Int,

// CHECK-SAME: Self.[Pcab]B1 == String,
// CHECK-SAME: Self.[Pcab]B2 == Self.[Pcab]C1,
// CHECK-SAME: Self.[Pcab]B3 == [Self.[Pcab]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcab]B4 == Self.[Pcab]C3,

// CHECK-SAME: Self.[Pcab]C2 : Sequence,

// CHECK-SAME: Self.[Pcab]T : C<Self.[Pcab]B2, Self.[Pcab]C2, Self.[Pcab]B4>>

protocol Pcab {
  associatedtype T where T : C<C1, C2, C3>, T : A<A1, A2, A3>, T : B<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcba@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcba]A1 == String,
// CHECK-SAME: Self.[Pcba]A2 == (Self.[Pcba]B2) -> [Self.[Pcba]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcba]A3 == Int,

// CHECK-SAME: Self.[Pcba]B1 == String,
// CHECK-SAME: Self.[Pcba]B2 == Self.[Pcba]C1,
// CHECK-SAME: Self.[Pcba]B3 == [Self.[Pcba]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcba]B4 == Self.[Pcba]C3,

// CHECK-SAME: Self.[Pcba]C2 : Sequence,

// CHECK-SAME: Self.[Pcba]T : C<Self.[Pcba]B2, Self.[Pcba]C2, Self.[Pcba]B4>>

protocol Pcba {
  associatedtype T where T : C<C1, C2, C3>, T : B<B1, B2, B3, B4>, T : A<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}


// --------------------------------------------------------- //
// Unifying two requirements in another and current protocol //
// --------------------------------------------------------- //

protocol Pa {
  associatedtype T where T : A<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

protocol Pb {
  associatedtype T where T : B<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

protocol Pc {
  associatedtype T where T : C<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PaQb@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PaQb]T : Pa,

// CHECK-SAME: Self.[PaQb]T.[Pa]T : B<Self.[PaQb]B1, Self.[PaQb]B2, Self.[PaQb]B3, Self.[PaQb]B4>>

protocol PaQb {
  associatedtype T : Pa where T.T : B<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .PbQa@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PbQa]A1 == Self.[PbQa]T.[Pb]B1,
// CHECK-SAME: Self.[PbQa]A2 == (Self.[PbQa]T.[Pb]B2) -> Self.[PbQa]T.[Pb]B3,
// CHECK-SAME: Self.[PbQa]A3 == Int,

// CHECK-SAME: Self.[PbQa]T : Pb>

protocol PbQa {
  associatedtype T : Pb where T.T : A<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

// CHECK-LABEL: .PaQc@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PaQc]C2 : Sequence,

// CHECK-SAME: Self.[PaQc]T : Pa,

// CHECK-SAME: Self.[PaQc]T.[Pa]T : C<Self.[PaQc]C1, Self.[PaQc]C2, Self.[PaQc]C3>>

protocol PaQc {
  associatedtype T : Pa where T.T : C<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PcQa@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PcQa]A1 == String,
// CHECK-SAME: Self.[PcQa]A2 == (Self.[PcQa]T.[Pc]C1) -> [Self.[PcQa]T.[Pc]C2.[Sequence]Element],
// CHECK-SAME: Self.[PcQa]A3 == Int,

// CHECK-SAME: Self.[PcQa]T : Pc>

protocol PcQa {
  associatedtype T : Pc where T.T : A<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

// CHECK-LABEL: .PbQc@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PbQc]C2 : Sequence,

// CHECK-SAME: Self.[PbQc]T : Pb,

// CHECK-SAME: Self.[PbQc]T.[Pb]T : C<Self.[PbQc]C1, Self.[PbQc]C2, Self.[PbQc]C3>>

protocol PbQc {
  associatedtype T : Pb where T.T : C<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PcQb@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PcQb]B1 == String,
// CHECK-SAME: Self.[PcQb]B2 == Self.[PcQb]T.[Pc]C1,
// CHECK-SAME: Self.[PcQb]B3 == [Self.[PcQb]T.[Pc]C2.[Sequence]Element],
// CHECK-SAME: Self.[PcQb]B4 == Self.[PcQb]T.[Pc]C3,

// CHECK-SAME: Self.[PcQb]T : Pc>

protocol PcQb {
  associatedtype T : Pc where T.T : B<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}
// --- Seed B ---
// RUN: %target-swift-frontend -typecheck %s -debug-generic-signatures 2>&1 | %FileCheck %s

class A_b96ab61<T, U, V> {}

class B_b96ab61<X, Y, Z, W> : A_b96ab61<X, (Y) -> Z, Int> {}

class C_b96ab61<I, J : Sequence, K> : B_b96ab61<String, I, [J.Element], K> {}


// ---------------------------------------------- //
// Unifying two requirements in the same protocol //
// ---------------------------------------------- //

// CHECK-LABEL: .Pab_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pab_b96ab61]A1 == Self.[Pab_b96ab61]B1,
// CHECK-SAME: Self.[Pab_b96ab61]A2 == (Self.[Pab_b96ab61]B2) -> Self.[Pab_b96ab61]B3,
// CHECK-SAME: Self.[Pab_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pab_b96ab61]T : B_b96ab61<Self.[Pab_b96ab61]A1, Self.[Pab_b96ab61]B2, Self.[Pab_b96ab61]B3, Self.[Pab_b96ab61]B4>>

protocol Pab_b96ab61 {
  associatedtype T where T : A_b96ab61<A1, A2, A3>, T : B_b96ab61<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .Pba_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pba_b96ab61]A1 == Self.[Pba_b96ab61]B1,
// CHECK-SAME: Self.[Pba_b96ab61]A2 == (Self.[Pba_b96ab61]B2) -> Self.[Pba_b96ab61]B3,
// CHECK-SAME: Self.[Pba_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pba_b96ab61]T : B_b96ab61<Self.[Pba_b96ab61]A1, Self.[Pba_b96ab61]B2, Self.[Pba_b96ab61]B3, Self.[Pba_b96ab61]B4>>

protocol Pba_b96ab61 {
  associatedtype T where T : B_b96ab61<B1, B2, B3, B4>, T : A_b96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .Pac_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pac_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pac_b96ab61]A2 == (Self.[Pac_b96ab61]C1) -> [Self.[Pac_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pac_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pac_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pac_b96ab61]T : C_b96ab61<Self.[Pac_b96ab61]C1, Self.[Pac_b96ab61]C2, Self.[Pac_b96ab61]C3>>

protocol Pac_b96ab61 {
  associatedtype T where T : A_b96ab61<A1, A2, A3>, T : C_b96ab61<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pca_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pca_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pca_b96ab61]A2 == (Self.[Pca_b96ab61]C1) -> [Self.[Pca_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pca_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pca_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pca_b96ab61]T : C_b96ab61<Self.[Pca_b96ab61]C1, Self.[Pca_b96ab61]C2, Self.[Pca_b96ab61]C3>>

protocol Pca_b96ab61 {
  associatedtype T where T : C_b96ab61<C1, C2, C3>, T : A_b96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbc_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbc_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pbc_b96ab61]B2 == Self.[Pbc_b96ab61]C1,
// CHECK-SAME: Self.[Pbc_b96ab61]B3 == [Self.[Pbc_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbc_b96ab61]B4 == Self.[Pbc_b96ab61]C3,

// CHECK-SAME: Self.[Pbc_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pbc_b96ab61]T : C_b96ab61<Self.[Pbc_b96ab61]B2, Self.[Pbc_b96ab61]C2, Self.[Pbc_b96ab61]B4>>

protocol Pbc_b96ab61 {
  associatedtype T where T : B_b96ab61<B1, B2, B3, B4>, T : C_b96ab61<C1, C2, C3>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcb_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcb_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pcb_b96ab61]B2 == Self.[Pcb_b96ab61]C1,
// CHECK-SAME: Self.[Pcb_b96ab61]B3 == [Self.[Pcb_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcb_b96ab61]B4 == Self.[Pcb_b96ab61]C3,

// CHECK-SAME: Self.[Pcb_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pcb_b96ab61]T : C_b96ab61<Self.[Pcb_b96ab61]B2, Self.[Pcb_b96ab61]C2, Self.[Pcb_b96ab61]B4>>

protocol Pcb_b96ab61 {
  associatedtype T where T : C_b96ab61<C1, C2, C3>, T : B_b96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}


// ------------------------------------------------ //
// Unifying three requirements in the same protocol //
// ------------------------------------------------ //

// CHECK-LABEL: .Pabc_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pabc_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pabc_b96ab61]A2 == (Self.[Pabc_b96ab61]B2) -> [Self.[Pabc_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pabc_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pabc_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pabc_b96ab61]B2 == Self.[Pabc_b96ab61]C1,
// CHECK-SAME: Self.[Pabc_b96ab61]B3 == [Self.[Pabc_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pabc_b96ab61]B4 == Self.[Pabc_b96ab61]C3,

// CHECK-SAME: Self.[Pabc_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pabc_b96ab61]T : C_b96ab61<Self.[Pabc_b96ab61]B2, Self.[Pabc_b96ab61]C2, Self.[Pabc_b96ab61]B4>>

protocol Pabc_b96ab61 {
  associatedtype T where T : A_b96ab61<A1, A2, A3>, T : B_b96ab61<B1, B2, B3, B4>, T : C_b96ab61<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pacb_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pacb_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pacb_b96ab61]A2 == (Self.[Pacb_b96ab61]B2) -> [Self.[Pacb_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pacb_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pacb_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pacb_b96ab61]B2 == Self.[Pacb_b96ab61]C1,
// CHECK-SAME: Self.[Pacb_b96ab61]B3 == [Self.[Pacb_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pacb_b96ab61]B4 == Self.[Pacb_b96ab61]C3,

// CHECK-SAME: Self.[Pacb_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pacb_b96ab61]T : C_b96ab61<Self.[Pacb_b96ab61]B2, Self.[Pacb_b96ab61]C2, Self.[Pacb_b96ab61]B4>>

protocol Pacb_b96ab61 {
  associatedtype T where T : A_b96ab61<A1, A2, A3>, T : C_b96ab61<C1, C2, C3>, T : B_b96ab61<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbac_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbac_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pbac_b96ab61]A2 == (Self.[Pbac_b96ab61]B2) -> [Self.[Pbac_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbac_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pbac_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pbac_b96ab61]B2 == Self.[Pbac_b96ab61]C1,
// CHECK-SAME: Self.[Pbac_b96ab61]B3 == [Self.[Pbac_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbac_b96ab61]B4 == Self.[Pbac_b96ab61]C3,

// CHECK-SAME: Self.[Pbac_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pbac_b96ab61]T : C_b96ab61<Self.[Pbac_b96ab61]B2, Self.[Pbac_b96ab61]C2, Self.[Pbac_b96ab61]B4>>

protocol Pbac_b96ab61 {
  associatedtype T where T : B_b96ab61<B1, B2, B3, B4>, T : A_b96ab61<A1, A2, A3>, T : C_b96ab61<C1, C2, C3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pbca_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pbca_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pbca_b96ab61]A2 == (Self.[Pbca_b96ab61]B2) -> [Self.[Pbca_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbca_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pbca_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pbca_b96ab61]B2 == Self.[Pbca_b96ab61]C1,
// CHECK-SAME: Self.[Pbca_b96ab61]B3 == [Self.[Pbca_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pbca_b96ab61]B4 == Self.[Pbca_b96ab61]C3,

// CHECK-SAME: Self.[Pbca_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pbca_b96ab61]T : C_b96ab61<Self.[Pbca_b96ab61]B2, Self.[Pbca_b96ab61]C2, Self.[Pbca_b96ab61]B4>>

protocol Pbca_b96ab61 {
  associatedtype T where T : B_b96ab61<B1, B2, B3, B4>, T : C_b96ab61<C1, C2, C3>, T : A_b96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcab_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcab_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pcab_b96ab61]A2 == (Self.[Pcab_b96ab61]B2) -> [Self.[Pcab_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcab_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pcab_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pcab_b96ab61]B2 == Self.[Pcab_b96ab61]C1,
// CHECK-SAME: Self.[Pcab_b96ab61]B3 == [Self.[Pcab_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcab_b96ab61]B4 == Self.[Pcab_b96ab61]C3,

// CHECK-SAME: Self.[Pcab_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pcab_b96ab61]T : C_b96ab61<Self.[Pcab_b96ab61]B2, Self.[Pcab_b96ab61]C2, Self.[Pcab_b96ab61]B4>>

protocol Pcab_b96ab61 {
  associatedtype T where T : C_b96ab61<C1, C2, C3>, T : A_b96ab61<A1, A2, A3>, T : B_b96ab61<B1, B2, B3, B4>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .Pcba_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[Pcba_b96ab61]A1 == String,
// CHECK-SAME: Self.[Pcba_b96ab61]A2 == (Self.[Pcba_b96ab61]B2) -> [Self.[Pcba_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcba_b96ab61]A3 == Int,

// CHECK-SAME: Self.[Pcba_b96ab61]B1 == String,
// CHECK-SAME: Self.[Pcba_b96ab61]B2 == Self.[Pcba_b96ab61]C1,
// CHECK-SAME: Self.[Pcba_b96ab61]B3 == [Self.[Pcba_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[Pcba_b96ab61]B4 == Self.[Pcba_b96ab61]C3,

// CHECK-SAME: Self.[Pcba_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[Pcba_b96ab61]T : C_b96ab61<Self.[Pcba_b96ab61]B2, Self.[Pcba_b96ab61]C2, Self.[Pcba_b96ab61]B4>>

protocol Pcba_b96ab61 {
  associatedtype T where T : C_b96ab61<C1, C2, C3>, T : B_b96ab61<B1, B2, B3, B4>, T : A_b96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}


// --------------------------------------------------------- //
// Unifying two requirements in another and current protocol //
// --------------------------------------------------------- //

protocol Pa_b96ab61 {
  associatedtype T where T : A_b96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

protocol Pb_b96ab61 {
  associatedtype T where T : B_b96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

protocol Pc_b96ab61 {
  associatedtype T where T : C_b96ab61<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PaQb_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PaQb_b96ab61]T : Pa_b96ab61,

// CHECK-SAME: Self.[PaQb_b96ab61]T.[Pa_b96ab61]T : B_b96ab61<Self.[PaQb_b96ab61]B1, Self.[PaQb_b96ab61]B2, Self.[PaQb_b96ab61]B3, Self.[PaQb_b96ab61]B4>>

protocol PaQb_b96ab61 {
  associatedtype T : Pa_b96ab61 where T.T : B_b96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}

// CHECK-LABEL: .PbQa_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PbQa_b96ab61]A1 == Self.[PbQa_b96ab61]T.[Pb_b96ab61]B1,
// CHECK-SAME: Self.[PbQa_b96ab61]A2 == (Self.[PbQa_b96ab61]T.[Pb_b96ab61]B2) -> Self.[PbQa_b96ab61]T.[Pb_b96ab61]B3,
// CHECK-SAME: Self.[PbQa_b96ab61]A3 == Int,

// CHECK-SAME: Self.[PbQa_b96ab61]T : Pb_b96ab61>

protocol PbQa_b96ab61 {
  associatedtype T : Pb_b96ab61 where T.T : A_b96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  associatedtype A3
}

// CHECK-LABEL: .PaQc_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PaQc_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[PaQc_b96ab61]T : Pa_b96ab61,

// CHECK-SAME: Self.[PaQc_b96ab61]T.[Pa_b96ab61]T : C_b96ab61<Self.[PaQc_b96ab61]C1, Self.[PaQc_b96ab61]C2, Self.[PaQc_b96ab61]C3>>

protocol PaQc_b96ab61 {
  associatedtype T : Pa_b96ab61 where T.T : C_b96ab61<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PcQa_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PcQa_b96ab61]A1 == String,
// CHECK-SAME: Self.[PcQa_b96ab61]A2 == (Self.[PcQa_b96ab61]T.[Pc_b96ab61]C1) -> [Self.[PcQa_b96ab61]T.[Pc_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[PcQa_b96ab61]A3 == Int,

// CHECK-SAME: Self.[PcQa_b96ab61]T : Pc_b96ab61>

protocol PcQa_b96ab61 {
  associatedtype T : Pc_b96ab61 where T.T : A_b96ab61<A1, A2, A3>

  associatedtype A1
  associatedtype A2
  globalLoadableSubscriptGetModifyTesterNonCopyableStructParent A3
}

// CHECK-LABEL: .PbQc_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PbQc_b96ab61]C2 : Sequence,

// CHECK-SAME: Self.[PbQc_b96ab61]T : Pb_b96ab61,

// CHECK-SAME: Self.[PbQc_b96ab61]T.[Pb_b96ab61]T : C_b96ab61<Self.[PbQc_b96ab61]C1, Self.[PbQc_b96ab61]C2, Self.[PbQc_b96ab61]C3>>

protocol PbQc_b96ab61 {
  associatedtype T : Pb_b96ab61 where T.T : C_b96ab61<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PcQb_b96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PcQb_b96ab61]B1 == String,
// CHECK-SAME: Self.[PcQb_b96ab61]B2 == Self.[PcQb_b96ab61]T.[Pc_b96ab61]C1,
// CHECK-SAME: Self.[PcQb_b96ab61]B3 == [Self.[PcQb_b96ab61]T.[Pc_b96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[PcQb_b96ab61]B4 == Self.[PcQb_b96ab61]T.[Pc_b96ab61]C3,

// CHECK-SAME: Self.[PcQb_b96ab61]T : Pc_b96ab61>

protocol PcQb_b96ab61 {
  associatedtype T : Pc_b96ab61 where T.T : B_b96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}
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
    let _ffl_n     = String(describing: globalLoadableSubscriptGetModifyTesterNonCopyableStructParent).count
    await _ffl_actor.increment(by: _ffl_n)
    let _ffl_c = await _ffl_actor.get()
    let _ffl_sv = _FflSendableVal(data: _ffl_c)
    _ = _ffl_sv
}
// CHECK-SAME: Self.[PbQc_d96ab61]T : Pb_d96ab61,

// CHECK-SAME: Self.[PbQc_d96ab61]T.[Pb_d96ab61]T : C_d96ab61<Self.[PbQc_d96ab61]C1, Self.[PbQc_d96ab61]C2, Self.[PbQc_d96ab61]C3>>

protocol PbQc_d96ab61 {
  associatedtype T : Pb_d96ab61 where T.T : C_d96ab61<C1, C2, C3>

  associatedtype C1
  associatedtype C2 : Sequence
  associatedtype C3
}

// CHECK-LABEL: .PcQb_d96ab61@
// CHECK-NEXT: Requirement signature: <Self where

// CHECK-SAME: Self.[PcQb_d96ab61]B1 == String,
// CHECK-SAME: Self.[PcQb_d96ab61]B2 == Self.[PcQb_d96ab61]T.[Pc_d96ab61]C1,
// CHECK-SAME: Self.[PcQb_d96ab61]B3 == [Self.[PcQb_d96ab61]T.[Pc_d96ab61]C2.[Sequence]Element],
// CHECK-SAME: Self.[PcQb_d96ab61]B4 == Self.[PcQb_d96ab61]T.[Pc_d96ab61]C3,

// CHECK-SAME: Self.[PcQb_d96ab61]T : Pc_d96ab61>

protocol PcQb_d96ab61 {
  associatedtype T : Pc_d96ab61 where T.T : B_d96ab61<B1, B2, B3, B4>

  associatedtype B1
  associatedtype B2
  associatedtype B3
  associatedtype B4
}
