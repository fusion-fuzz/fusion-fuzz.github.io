import Distributed

// RUN: %target-swift-frontend -O -Xllvm -sil-print-types -emit-sil -sil-verify-all -Xllvm -sil-disable-pass=function-signature-opts %s | %FileCheck %s
// RUN: %target-swift-frontend -O -Xllvm -sil-print-types -emit-sil -Xllvm -sil-verify-force-analysis-around-pass=devirtualizer -Xllvm -sil-disable-pass=function-signature-opts %s | %FileCheck %s

// REQUIRES: swift_in_compiler

//===----------------------------------------------------------------------===//
// testReturnSelf: Call to a protocol extension method with
// an existential self that can be type-propagated.
// sil-combine should bailout since it does not propagate
// type substitutions on the return value.
//
// rdar://40555427
// https://github.com/apple/swift/issues/50312
// 'SILCombiner::propagateConcreteTypeOfInitExistential' fails to fully
// propagate type substitutions.
//===----------------------------------------------------------------------===//
public protocol P: class {}

extension P {
  public func returnSelf() -> Self {
    return self
  }
}

final class C: P {}
// CHECK-LABEL: sil @$s32sil_combine_concrete_existential14testReturnSelfAA1P_pyF : $@convention(thin) () -> @owned any P {
// CHECK: [[EI:%.*]] = end_init_let_ref %0
// CHECK: [[E1:%.*]] = init_existential_ref [[EI]] : $C : $C, $any P
// CHECK: [[O1:%.*]] = open_existential_ref [[E1]] : $any P to $@opened("{{.*}}", any P) Self
// CHECK: [[F1:%.*]] = function_ref @$s32sil_combine_concrete_existential1PPAAE10returnSelfxyF : $@convention(method) <τ_0_0 where τ_0_0 : P> (@guaranteed τ_0_0) -> @owned τ_0_0
// CHECK: [[C1:%.*]] = apply [[F1]]<@opened("{{.*}}", any P) Self>([[O1]]) : $@convention(method) <τ_0_0 where τ_0_0 : P> (@guaranteed τ_0_0) -> @owned τ_0_0
// CHECK: [[E2:%.*]] = init_existential_ref [[C1]] : $@opened("{{.*}}", any P) Self : $@opened("{{.*}}", any P) Self, $any P
// CHECK: [[O2:%.*]] = open_existential_ref [[E2]] : $any P to $@opened("{{.*}}", any P) Self
// CHECK: apply [[F1]]<@opened("{{.*}}", any P) Self>([[O2]]) : $@convention(method) <τ_0_0 where τ_0_0 : P> (@guaranteed τ_0_0) -> @owned τ_0_0
// CHECK-LABEL: } // end sil function '$s32sil_combine_concrete_existential14testReturnSelfAA1P_pyF'
public func testReturnSelf() -> P {
  let p: P = C()
  return p.returnSelf().returnSelf()
}

//===----------------------------------------------------------------------===//
// testWitnessReturnOptionalSelf: Call to a witness method with an existential
// self that can be type-propagated. sil-combine should bailout since it does
// not propagate type substitutions on the return value, and it must walk the
// Optional type to find Self in the return type.
//
// Although sil-combine will not replace the self operand, it will still
// rewrite the witness_method. The devirtualizer then handles the first call.
//===----------------------------------------------------------------------===//
public protocol PP: class {
  func returnOptionalSelf() -> Self?
}

final class CC: PP {
  init() {}
  func returnOptionalSelf() -> Self? {
    return self
  }
}

// CHECK-LABEL: sil @$s32sil_combine_concrete_existential29testWitnessReturnOptionalSelfAA2PP_pSgyF : $@convention(thin) () -> @owned Optional<any PP> {
// CHECK: [[EI:%.*]] = end_init_let_ref %0
// CHECK: [[E1:%.*]] = init_existential_ref [[EI]] : $CC : $CC, $any PP
// CHECK: [[O1:%.*]] = open_existential_ref [[E1]] : $any PP to $@opened("{{.*}}", any PP) Self
// CHECK: [[E2:%.*]] = init_existential_ref %{{.*}} : $@opened("{{.*}}", any PP) Self : $@opened("{{.*}}", any PP) Self, $any PP
// CHECK: [[O2:%.*]] = open_existential_ref [[E2]] : $any PP to $@opened("{{.*}}", any PP) Self
// CHECK-NOT:     apply
// CHECK-LABEL: } // end sil function '$s32sil_combine_concrete_existential29testWitnessReturnOptionalSelfAA2PP_pSgyF'
public func testWitnessReturnOptionalSelf() -> PP? {
  let p: PP = CC()
  return p.returnOptionalSelf()?.returnOptionalSelf()
}

//===----------------------------------------------------------------------===//
// testWitnessReturnOptionalIndirectSelf: Call to a witness method with an
// existential self that can be type-propagated. sil-combine should bailout
// since it does not propagate type substitutions on non-self arguments. It must
// walk the Optional type to find Self in the non-self argument.
//
// Although sil-combine will not replace the self operand, it will still
// rewrite the witness_method. The devirtualizer then handles the first call.
//===----------------------------------------------------------------------===//
protocol PPP {
  func returnsOptionalIndirect() -> Self?
}

struct S: PPP {
  func returnsOptionalIndirect() -> S? {
    return self
  }
}

struct SS: PPP {
  func returnsOptionalIndirect() -> SS? {
    return self
  }
}

// The first apply has been devirtualized and inlined. The second remains unspecialized.
// CHECK-LABEL: sil @$s32sil_combine_concrete_existential37testWitnessReturnOptionalIndirectSelfyyF : $@convention(thin) () -> () {
// CHECK: [[O1:%.*]] = open_existential_addr immutable_access %{{.*}} : $*any PPP to $*@opened("{{.*}}", any PPP) Self
// CHECK: switch_enum_addr %{{.*}} : $*Optional<@opened("{{.*}}", any PPP) Self>, case #Optional.some!enumelt: bb{{.*}}, case #Optional.none!enumelt: bb{{.*}}
// CHECK: [[O2:%.*]] = open_existential_addr immutable_access %{{.*}} : $*any PPP to $*@opened("{{.*}}", any PPP) Self
// CHECK: [[W:%.*]] = witness_method $@opened("{{.*}}", any PPP) Self, #PPP.returnsOptionalIndirect : <Self where Self : PPP> (Self) -> () -> Self?, [[O1]] : $*@opened("{{.*}}", any PPP) Self : $@convention(witness_method: PPP) <τ_0_0 where τ_0_0 : PPP> (@in_guaranteed τ_0_0) -> @out Optional<τ_0_0>
// CHECK: apply [[W]]<@opened("{{.*}}", any PPP) Self>(%{{.*}}, [[O2]]) : $@convention(witness_method: PPP) <τ_0_0 where τ_0_0 : PPP> (@in_guaranteed τ_0_0) -> @out Optional<τ_0_0>
// CHECK-LABEL: } // end sil function '$s32sil_combine_concrete_existential37testWitnessReturnOptionalIndirectSelfyyF'
public func testWitnessReturnOptionalIndirectSelf() {
  let p: PPP = S()
  _ = p.returnsOptionalIndirect()?.returnsOptionalIndirect()
}

//===----------------------------------------------------------------------===//
// testExtensionProtocolComposition: Call to a witness method with an
// existential self that can be type-propagated. Handle an existential with
// multiple conformances.
//
// Previously crashed with in SILCombiner::propagateConcreteTypeOfInitExistential
// with assertion failed: (proto == Conformance.getRequirement()).
// ===----------------------------------------------------------------------===//
public protocol Q {}

extension P where Self : Q {
  public func witnessComposition() {}
}
  
public class C_PQ: P & Q {}

// testExtensionProtocolComposition(c:)
// CHECK-LABEL: sil {{.*}}@$s32sil_combine_concrete_existential32testExtensionProtocolComposition1cyAA4C_PQC_tF : $@convention(thin) (@guaranteed C_PQ) -> () {
// CHECK-NOT: init_existential_ref
// CHECK-NOT: function_ref
// CHECK-NOT: apply
// CHECK: } // end sil function '$s32sil_combine_concrete_existential32testExtensionProtocolComposition1cyAA4C_PQC_tF'
public func testExtensionProtocolComposition(c: C_PQ) {
  let pp: P & Q = c
  pp.witnessComposition()
}
// RUN: %target-swift-frontend -O -Xllvm -sil-print-types -emit-sil -sil-verify-all -Xllvm -sil-disable-pass=function-signature-opts %s | %FileCheck %s
// RUN: %target-swift-frontend -O -Xllvm -sil-print-types -emit-sil -Xllvm -sil-verify-force-analysis-around-pass=devirtualizer -Xllvm -sil-disable-pass=function-signature-opts %s | %FileCheck %s

// REQUIRES: swift_in_compiler

//===----------------------------------------------------------------------===//
// testReturnSelf_d60031d: Call to a protocol extension method with
// an existential self that can be type-propagated.
// sil-combine should bailout since it does not propagate
// type substitutions on the return value.
//
// rdar://40555427
// https://github.com/apple/swift/issues/50312
// 'SILCombiner::propagateConcreteTypeOfInitExistential' fails to fully
// propagate type substitutions.
//===----------------------------------------------------------------------===//
public protocol P_d60031d: class {}

extension P_d60031d {
  public func returnSelf() -> Self {
    return self
  }
}

final class C_d60031d: P_d60031d {}
// CHECK-LABEL: sil @$s32sil_combine_concrete_existential14testReturnSelfAA1P_pyF : $@convention(thin) () -> @owned any P_d60031d {
// CHECK: [[EI:%.*]] = end_init_let_ref %0
// CHECK: [[E1:%.*]] = init_existential_ref [[EI]] : $C_d60031d : $C_d60031d, $any P_d60031d
// CHECK: [[O1:%.*]] = open_existential_ref [[E1]] : $any P_d60031d to $@opened("{{.*}}", any P_d60031d) Self
// CHECK: [[F1:%.*]] = function_ref @$s32sil_combine_concrete_existential1PPAAE10returnSelfxyF : $@convention(method) <τ_0_0 where τ_0_0 : P_d60031d> (@guaranteed τ_0_0) -> @owned τ_0_0
// CHECK: [[C1:%.*]] = apply [[F1]]<@opened("{{.*}}", any P_d60031d) Self>([[O1]]) : $@convention(method) <τ_0_0 where τ_0_0 : P_d60031d> (@guaranteed τ_0_0) -> @owned τ_0_0
// CHECK: [[E2:%.*]] = init_existential_ref [[C1]] : $@opened("{{.*}}", any P_d60031d) Self : $@opened("{{.*}}", any P_d60031d) Self, $any P_d60031d
// CHECK: [[O2:%.*]] = open_existential_ref [[E2]] : $any P_d60031d to $@opened("{{.*}}", any P_d60031d) Self
// CHECK: apply [[F1]]<@opened("{{.*}}", any P_d60031d) Self>([[O2]]) : $@convention(method) <τ_0_0 where τ_0_0 : P_d60031d> (@guaranteed τ_0_0) -> @owned τ_0_0
// CHECK-LABEL: } // end sil function '$s32sil_combine_concrete_existential14testReturnSelfAA1P_pyF'
public func testReturnSelf_d60031d() -> P_d60031d {
  let p: P_d60031d = C_d60031d()
  return p.returnSelf().returnSelf()
}

//===----------------------------------------------------------------------===//
// testWitnessReturnOptionalSelf_d60031d: Call to a witness method with an existential
// self that can be type-propagated. sil-combine should bailout since it does
// not propagate type substitutions on the return value, and it must walk the
// Optional type to find Self in the return type.
//
// Although sil-combine will not replace the self operand, it will still
// rewrite the witness_method. The devirtualizer then handles the first call.
//===----------------------------------------------------------------------===//
public protocol PP_d60031d: class {
  func returnOptionalSelf() -> Self?
}

final class CC_d60031d: PP_d60031d {
  init() {}
  func returnOptionalSelf() -> Self? {
    return self
  }
}

// CHECK-LABEL: sil @$s32sil_combine_concrete_existential29testWitnessReturnOptionalSelfAA2PP_pSgyF : $@convention(thin) () -> @owned Optional<any PP_d60031d> {
// CHECK: [[EI:%.*]] = end_init_let_ref %0
// CHECK: [[E1:%.*]] = init_existential_ref [[EI]] : $CC_d60031d : $CC_d60031d, $any PP_d60031d
// CHECK: [[O1:%.*]] = open_existential_ref [[E1]] : $any PP_d60031d to $@opened("{{.*}}", any PP_d60031d) Self
// CHECK: [[E2:%.*]] = init_existential_ref %{{.*}} : $@opened("{{.*}}", any PP_d60031d) Self : $@opened("{{.*}}", any PP_d60031d) Self, $any PP_d60031d
// CHECK: [[O2:%.*]] = open_existential_ref [[E2]] : $any PP_d60031d to $@opened("{{.*}}", any PP_d60031d) Self
// CHECK-NOT:     apply
// CHECK-LABEL: } // end sil function '$s32sil_combine_concrete_existential29testWitnessReturnOptionalSelfAA2PP_pSgyF'
public func testWitnessReturnOptionalSelf_d60031d() -> PP_d60031d? {
  let p: PP_d60031d = CC_d60031d()
  return p.returnOptionalSelf()?.returnOptionalSelf()
}

//===----------------------------------------------------------------------===//
// testWitnessReturnOptionalIndirectSelf_d60031d: Call to a witness method with an
// existential self that can be type-propagated. sil-combine should bailout
// since it does not propagate type substitutions on non-self arguments. It must
// walk the Optional type to find Self in the non-self argument.
//
// Although sil-combine will not replace the self operand, it will still
// rewrite the witness_method. The devirtualizer then handles the first call.
//===----------------------------------------------------------------------===//
protocol PPP_d60031d {
  func returnsOptionalIndirect() -> Self?
}

struct S_d60031d: PPP_d60031d {
  func returnsOptionalIndirect() -> S_d60031d? {
    return self
  }
}

struct SS_d60031d: PPP_d60031d {
  func returnsOptionalIndirect() -> SS_d60031d? {
    return self
  }
}

// The first apply has been devirtualized and inlined. The second remains unspecialized.
// CHECK-LABEL: sil @$s32sil_combine_concrete_existential37testWitnessReturnOptionalIndirectSelfyyF : $@convention(thin) () -> () {
// CHECK: [[O1:%.*]] = open_existential_addr immutable_access %{{.*}} : $*any PPP_d60031d to $*@opened("{{.*}}", any PPP_d60031d) Self
// CHECK: switch_enum_addr %{{.*}} : $*Optional<@opened("{{.*}}", any PPP_d60031d) Self>, case #Optional.some!enumelt: bb{{.*}}, case #Optional.none!enumelt: bb{{.*}}
// CHECK: [[O2:%.*]] = open_existential_addr immutable_access %{{.*}} : $*any PPP_d60031d to $*@opened("{{.*}}", any PPP_d60031d) Self
// CHECK: [[W:%.*]] = witness_method $@opened("{{.*}}", any PPP_d60031d) Self, #PPP_d60031d.returnsOptionalIndirect : <Self where Self : PPP_d60031d> (Self) -> () -> Self?, [[O1]] : $*@opened("{{.*}}", any PPP_d60031d) Self : $@convention(witness_method: PPP_d60031d) <τ_0_0 where τ_0_0 : PPP_d60031d> (@in_guaranteed τ_0_0) -> @out Optional<τ_0_0>
// CHECK: apply [[W]]<@opened("{{.*}}", any PPP_d60031d) Self>(%{{.*}}, [[O2]]) : $@convention(witness_method: PPP_d60031d) <τ_0_0 where τ_0_0 : PPP_d60031d> (@in_guaranteed τ_0_0) -> @out Optional<τ_0_0>
// CHECK-LABEL: } // end sil function '$s32sil_combine_concrete_existential37testWitnessReturnOptionalIndirectSelfyyF'
public func testWitnessReturnOptionalIndirectSelf_d60031d() {
  let p: PPP_d60031d = S_d60031d()
  _ = p.returnsOptionalIndirect()?.returnsOptionalIndirect()
}

//===----------------------------------------------------------------------===//
// testExtensionProtocolComposition_d60031d: Call to a witness method with an
// existential self that can be type-propagated. Handle an existential with
// multiple conformances.
//
// Previously crashed with in SILCombiner::propagateConcreteTypeOfInitExistential
// with assertion failed: (proto == Conformance.getRequirement()).
// ===----------------------------------------------------------------------===//
public protocol Q_d60031d {}

extension P_d60031d where Self : Q_d60031d {
  public func witnessComposition() {}
}
  
public class C_PQ_d60031d: P_d60031d & Q_d60031d {}

// testExtensionProtocolComposition_d60031d(c:)
// CHECK-LABEL: sil {{.*}}@$s32sil_combine_concrete_existential32testExtensionProtocolComposition1cyAA4C_PQC_tF : $@convention(thin) (@guaranteed C_PQ_d60031d) -> () {
// CHECK-NOT: init_existential_ref
// CHECK-NOT: function_ref
// CHECK-NOT: apply
// CHECK: } // end sil function '$s32sil_combine_concrete_existential32testExtensionProtocolComposition1cyAA4C_PQC_tF'
public func testExtensionProtocolComposition_d60031d(c: C_PQ_d60031d) {
  let pp: P_d60031d & Q_d60031d = c
  pp.witnessComposition()
}
// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -target %target-swift-6.0-abi-triple -emit-ir -swift-version 6 -O -I %t %s
// RUN: %target-swift-frontend -target %target-swift-6.0-abi-triple -emit-sil -swift-version 6 -O -I %t %s | %FileCheck %s

// REQUIRES: concurrency
// REQUIRES: distributed


public protocol Transferable: Sendable, P {}

// NOT final on purpose
@available(SwiftStdlib 5.7, *)
public class TheSpecificResultHandlerWhichIsANonFinalClass: DistributedTargetInvocationResultHandler {
  public typealias SerializationRequirement = Transferable

  public func onReturn<Success>(value: Success) async throws where Success: Transferable {
  }

  public func onReturnVoid() async throws {
    fatalError()
  }

  public func onThrow<Err>(error: Err) async throws where Err : Error {
    fatalError()
  }
}

// NOT final on purpose
@available(SwiftStdlib 5.7, *)
public class FakeInvocationDecoder: DistributedTargetInvocationDecoder {
  public typealias SerializationRequirement = Transferable

  public func decodeGenericSubstitutions() throws -> [Any.Type] {
    []
  }

  public func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument {
    fatalError()
  }

  public func decodeErrorType() throws -> Any.Type? {
    nil
  }

  public func decodeReturnType() throws -> Any.Type? {
    nil
  }
}

// NOT final on purpose
@available(SwiftStdlib 5.7, *)
public class FakeInvocationEncoder : DistributedTargetInvocationEncoder {
  public typealias SerializationRequirement = Transferable

  public func recordArgument<Value: SerializationRequirement>(
    _ argument: RemoteCallArgument<Value>) throws {
  }

  public func recordGenericSubstitution<T>(_ type: T.Type) throws {
  }

  public func recordErrorType<E: Error>(_ type: E.Type) throws {
  }

  public func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws {
  }

  public func doneRecording() throws {
  }
}

// NOT final on purpose
@available(SwiftStdlib 5.7, *)
public class NotFinalActorSystemForAdHocRequirementTest: DistributedActorSystem, @unchecked Sendable {
  public typealias ActorID = String
  public typealias InvocationEncoder = FakeInvocationEncoder
  public typealias InvocationDecoder = FakeInvocationDecoder
  public typealias SerializationRequirement = Transferable
  public typealias ResultHandler = TheSpecificResultHandlerWhichIsANonFinalClass

  public init() {}

  public func resolve<Act>(id: ActorID, as actorType: Act.Type)
    throws -> Act? where Act: DistributedActor {
    fatalError()
  }

  public func assignID<Act>(_ actorType: Act.Type) -> ActorID
    where Act: DistributedActor {
    fatalError()
  }

  public func actorReady<Act>(_ actor: Act) where Act: DistributedActor, Act.ID == ActorID {
    fatalError()
  }

  public func resignID(_ id: ActorID) {
    fatalError()
  }

  public func makeInvocationEncoder() -> InvocationEncoder {
    fatalError()
  }

  public func remoteCall<Act, Err, Res>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation: inout InvocationEncoder,
    throwing errorType: Err.Type,
    returning returnType: Res.Type
  ) async throws -> Res
    where Act: DistributedActor,
          Act.ID == ActorID,
          Err: Error,
          Res: SerializationRequirement {
    fatalError()
  }

  public func remoteCallVoid<Act, Err>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation: inout InvocationEncoder,
    throwing errorType: Err.Type
  ) async throws
    where Act: DistributedActor,
          Act.ID == ActorID,
          Err: Error {
    fatalError()
  }
}

// FIXME: This call should be devirtualized but it cannot be done at the moment due to issues with ad-hoc serialization requirement.

// CHECK-LABEL: sil shared [transparent] [thunk] @$s52distributed_actor_adhoc_requirements_optimized_build42NotFinalActorSystemForAdHocRequirementTestC11Distributed0piJ0AadEP10remoteCall2on6target10invocation8throwing9returningqd_1_qd___AD06RemoteR6TargetV17InvocationEncoderQzzqd_0_mqd_1_mtYaKAD0pI0Rd__s5ErrorRd_0_2IDQyd__0I2IDRtzr1_lFTW
// CHECK: bb0(%0 : $*τ_0_2, %1 : $τ_0_0, %2 : $*RemoteCallTarget, %3 : $*FakeInvocationEncoder, %4 : $@thick τ_0_1.Type, %5 : $@thick τ_0_2.Type, %6 : $*NotFinalActorSystemForAdHocRequirementTest):
// CHECK-NEXT:  [[DIST_IMPL:%.*]] = load %6
// CHECK-NEXT:  [[REMOTE_CALL_WITNESS:%.*]] = class_method [[DIST_IMPL]], #NotFinalActorSystemForAdHocRequirementTest.remoteCall
// CHECK-NEXT: try_apply [[REMOTE_CALL_WITNESS]]<τ_0_0, τ_0_1, τ_0_2>(%0, %1, %2, %3, %4, %5, [[DIST_IMPL]])
