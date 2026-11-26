import Distributed
import _Concurrency

// --- Seed A ---
// RUN: %target-run-simple-swift(-target %target-swift-5.7-abi-triple -parse-as-library) | %FileCheck %s
// RUN: %target-run-simple-swift(-Xfrontend -enable-sil-opaque-values -target %target-swift-5.7-abi-triple -parse-as-library) | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: concurrency
// REQUIRES: distributed

// rdar://76038845
// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime


struct Boom: Error {
  let whoFailed: String
  init(_ whoFailed: String) {
    self.whoFailed = whoFailed
  }
}

distributed actor SomeSpecificDistributedActor {
  let state: String = "hi there"

  distributed func helloAsyncThrows() async throws -> String {
    "local(\(#function))"
  }

  distributed func helloAsync() async -> String {
   "local(\(#function))"
  }

  distributed func helloThrows() throws -> String {
   "local(\(#function))"
  }

  distributed func hello() -> String {
   "local(\(#function))"
  }

  distributed func callTaskSelf_inner() async throws -> String {
    "local(\(#function))"
  }
  distributed func callTaskSelf() async -> String {
    do {
      return try await Task {
        let called = try await callTaskSelf_inner() // shouldn't use the distributed thunk!
        return "local(\(#function)) -> \(called)"
      }.value
    } catch {
      return "WRONG local(\(#function)) thrown(\(error))"
    }
  }

  distributed func callDetachedSelf() async -> String {
    do {
      return try await Task.detached {
        let called = try await self.callTaskSelf_inner() // shouldn't use the distributed thunk!
        return "local(\(#function)) -> \(called)"
      }.value
    } catch {
      return "WRONG local(\(#function)) thrown(\(error))"
    }
  }

  // === errors

  distributed func helloThrowsImplBoom() throws -> String {
    throw Boom("impl")
  }

  distributed func helloThrowsTransportBoom() throws -> String {
    "local(\(#function))"
  }
}
// RUN: %batch-code-completion

func `func with spaces`() {}
typealias `Space Alias` = `Struct With Spaces`
struct `Struct With Spaces` {}

func test01() {
    #^GLOBAL_NAME^#
    // GLOBAL_NAME-DAG: Decl[FreeFunction]/CurrModule:      `func with spaces`()[#Void#]; name=`func with spaces`()
    // GLOBAL_NAME-DAG: Decl[TypeAlias]/CurrModule:         `Space Alias`[#`Struct With Spaces`#]; name=`Space Alias`
    // GLOBAL_NAME-DAG: Decl[Struct]/CurrModule:            `Struct With Spaces`[#`Struct With Spaces`#]; name=`Struct With Spaces`
}

struct S {
  var `name with spaces :)`: Int
  func `some.method`(`argument label!`: Int) {}
  func f(x: `Struct With Spaces`) {}
}

func test02(_ x: S) {
  x.#^MEMBER_NAME^#
  // MEMBER_NAME-DAG: Decl[InstanceVar]/CurrNominal:      `name with spaces :)`[#Int#]; name=`name with spaces :)`
  // MEMBER_NAME-DAG: Decl[InstanceMethod]/CurrNominal:   `some.method`({#`argument label!`: Int#})[#Void#]; name=`some.method`(`argument label!`:)
  // MEMBER_NAME-DAG: Decl[InstanceMethod]/CurrNominal:   f({#x: `Struct With Spaces`#})[#Void#]; name=f(x:)
}

struct S2<`Generic Param`> {
  var x: #^TYPE_NAME^#
  // TYPE_NAME-DAG: Decl[GenericTypeParam]/Local:       `Generic Param`[#Generic Param#]; name=`Generic Param`

// ==== Execute ----------------------------------------------------------------

@_silgen_name("swift_distributed_actor_is_remote")
func __isRemoteActor(_ actor: AnyObject) -> Bool

func __isLocalActor(_ actor: AnyObject) -> Bool {
  return !__isRemoteActor(actor)
}

// ==== Fake Transport ---------------------------------------------------------

struct ActorAddress: Sendable, Hashable, Codable {
  let address: String
}

struct FakeActorSystem: DistributedActorSystem {
  typealias ActorID = ActorAddress
  typealias InvocationDecoder = FakeInvocationDecoder
  typealias InvocationEncoder = FakeInvocationEncoder
  typealias SerializationRequirement = Codable
  typealias ResultHandler = FakeResultHandler

  func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
      where Act: DistributedActor,
            Act.ID == ActorID {
    nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
      where Act: DistributedActor {
    ActorAddress(address: "")
  }

  func actorReady<Act>(_ actor: Act)
      where Act: DistributedActor,
      Act.ID == ActorID {
  }

  func resignID(_ id: ActorID) {
  }

  func makeInvocationEncoder() -> InvocationEncoder {
    .init()
  }

  public func remoteCall<Act, Err, Res>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation invocationEncoder: inout InvocationEncoder,
    throwing: Err.Type,
    returning: Res.Type
  ) async throws -> Res
    where Act: DistributedActor,
          Act.ID == ActorID,
          Err: Error,
          Res: SerializationRequirement {
    guard "\(target)" != "main.SomeSpecificDistributedActor.helloThrowsTransportBoom()" else {
      throw Boom("system")
    }

    return "remote(\(target))" as! Res
  }

  func remoteCallVoid<Act, Err>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation invocationEncoder: inout InvocationEncoder,
    throwing: Err.Type
  ) async throws
    where Act: DistributedActor,
          Act.ID == ActorID,
          Err: Error {
    fatalError("not implemented: \(#function)")
  }
}

// === Sending / encoding -------------------------------------------------
struct FakeInvocationEncoder: DistributedTargetInvocationEncoder {
  typealias SerializationRequirement = Codable

  mutating func recordGenericSubstitution<T>(_ type: T.Type) throws {}
  mutating func recordArgument<Value: SerializationRequirement>(_ argument: RemoteCallArgument<Value>) throws {}
  mutating func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws {}
  mutating func recordErrorType<E: Error>(_ type: E.Type) throws {}
  mutating func doneRecording() throws {}
}

// === Receiving / decoding -------------------------------------------------
class FakeInvocationDecoder : DistributedTargetInvocationDecoder {
  typealias SerializationRequirement = Codable

  func decodeGenericSubstitutions() throws -> [Any.Type] { [] }
  func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument { fatalError() }
  func decodeReturnType() throws -> Any.Type? { nil }
  func decodeErrorType() throws -> Any.Type? { nil }
}

public struct FakeResultHandler: DistributedTargetInvocationResultHandler {
  public typealias SerializationRequirement = Codable

  public func onReturn<Success: SerializationRequirement>(value: Success) async throws {
    fatalError("Not implemented: \(#function)")
  }

  public func onReturnVoid() async throws {
    fatalError("Not implemented: \(#function)")
  }

  public func onThrow<Err: Error>(error: Err) async throws {
    fatalError("Not implemented: \(#function)")
  }
}

@available(SwiftStdlib 5.5, *)
typealias DefaultDistributedActorSystem = FakeActorSystem

// ==== Execute ----------------------------------------------------------------

func test_remote_invoke(address: ActorAddress, system: FakeActorSystem) async {
  func check(actor: SomeSpecificDistributedActor) async {
    let personality = __isRemoteActor(actor) ? "remote" : "local"

    let h1 = try! await actor.helloAsyncThrows()
    print("\(personality) - helloAsyncThrows: \(h1)")

    let h2 = try! await actor.helloAsync()
    print("\(personality) - helloAsync: \(h2)")

    let h3 = try! await actor.helloThrows()
    print("\(personality) - helloThrows: \(h3)")

    let h4 = try! await actor.hello()
    print("\(personality) - hello: \(h4)")

    let h5 = try! await actor.callTaskSelf()
    print("\(personality) - callTaskSelf: \(h5)")

    let h6 = try! await actor.callDetachedSelf()
    print("\(personality) - callDetachedSelf: \(h6)")

    // error throws
    if __isRemoteActor(actor) {
      do {
        let h7 = try await actor.helloThrowsTransportBoom()
        print("WRONG: helloThrowsTransportBoom: should have thrown; got: \(h7)")
      } catch {
        print("\(personality) - helloThrowsTransportBoom: \(error)")
      }
    } else {
      do {
        let h8 = try await actor.helloThrowsImplBoom()
        print("WRONG: helloThrowsImplBoom: Should have thrown; got: \(h8)")
      } catch {
        print("\(personality) - helloThrowsImplBoom: \(error)")
      }
    }
  }

  let remote = try! SomeSpecificDistributedActor.resolve(id: address, using: system)
  assert(__isRemoteActor(remote) == true, "should be remote")

  let local = SomeSpecificDistributedActor(actorSystem: system)
  assert(__isRemoteActor(local) == false, "should be local")

  print("local isRemote: \(__isRemoteActor(local))")
  // CHECK: local isRemote: false
  await check(actor: local)
  // CHECK: local - helloAsyncThrows: local(helloAsyncThrows())
  // CHECK: local - helloAsync: local(helloAsync())
  // CHECK: local - helloThrows: local(helloThrows())
  // CHECK: local - hello: local(hello())
  // CHECK: local - callTaskSelf: local(callTaskSelf()) -> local(callTaskSelf_inner())
  // CHECK: local - callDetachedSelf: local(callDetachedSelf()) -> local(callTaskSelf_inner())
  // CHECK: local - helloThrowsImplBoom: Boom(whoFailed: "impl")

  print("remote isRemote: \(__isRemoteActor(remote))")
  // CHECK: remote isRemote: true
  await check(actor: remote)
  // CHECK: remote - helloAsyncThrows: remote(main.SomeSpecificDistributedActor.helloAsyncThrows())
  // CHECK: remote - helloAsync: remote(main.SomeSpecificDistributedActor.helloAsync())
  // CHECK: remote - helloThrows: remote(main.SomeSpecificDistributedActor.helloThrows())
  // CHECK: remote - hello: remote(main.SomeSpecificDistributedActor.hello())
  // CHECK: remote - callTaskSelf: remote(main.SomeSpecificDistributedActor.callTaskSelf())
  // CHECK: remote - callDetachedSelf: remote(main.SomeSpecificDistributedActor.callDetachedSelf())
  // CHECK: remote - helloThrowsTransportBoom: Boom(whoFailed: "system")

  print(local)
  print(remote)
}

@main struct Main {
  static func main() async {
    let address = ActorAddress(address: "")
    let system = DefaultDistributedActorSystem()

    await test_remote_invoke(address: address, system: system)
  }
}
  // TYPE_NAME-DAG: Keyword[Self]/CurrNominal:          Self[#S2<Generic Param>#]; name=Self
}

precedencegroup `Spacedence Group` {}
precedencegroup AnotherOne {
  higherThan: #^PREC_NAME^#
  // PREC_NAME: Decl[PrecedenceGroup]/CurrModule:   `Spacedence Group`; name=`Spacedence Group`
}
// --- Seed B ---
// RUN: %batch-code-completion

func `func with spaces`() {}
typealias `Space Alias` = `Struct With Spaces`
struct `Struct With Spaces` {}

func test01() {
    #^GLOBAL_NAME^#
    // GLOBAL_NAME-DAG: Decl[FreeFunction]/CurrModule:      `func with spaces`()[#Void#]; name=`func with spaces`()
    // GLOBAL_NAME-DAG: Decl[TypeAlias]/CurrModule:         `Space Alias`[#`Struct With Spaces`#]; name=`Space Alias`
    // GLOBAL_NAME-DAG: Decl[Struct]/CurrModule:            `Struct With Spaces`[#`Struct With Spaces`#]; name=`Struct With Spaces`
}

struct S {
  var `name with spaces :)`: Int
  func `some.method`(`argument label!`: Int) {}
  func f(x: `Struct With Spaces`) {}
}

func test02(called x: S) {
  x.#^MEMBER_NAME^#
  // MEMBER_NAME-DAG: Decl[InstanceVar]/CurrNominal:      `name with spaces :)`[#Int#]; name=`name with spaces :)`
  // MEMBER_NAME-DAG: Decl[InstanceMethod]/CurrNominal:   `some.method`({#`argument label!`: Int#})[#Void#]; name=`some.method`(`argument label!`:)
  // MEMBER_NAME-DAG: Decl[InstanceMethod]/CurrNominal:   f({#x: `Struct With Spaces`#})[#Void#]; name=f(x:)
}

struct S2<`Generic Param`> {
  var x: #^TYPE_NAME^#
  // TYPE_NAME-DAG: Decl[GenericTypeParam]/Local:       `Generic Param`[#Generic Param#]; name=`Generic Param`
  // TYPE_NAME-DAG: Keyword[Self]/CurrNominal:          Self[#S2<Generic Param>#]; name=Self
}

precedencegroup `Spacedence Group` {}
precedencegroup AnotherOne {
  higherThan: #^PREC_NAME^#
  // PREC_NAME: Decl[PrecedenceGroup]/CurrModule:   `Spacedence Group`; name=`Spacedence Group`
}
// --- Bug Primitive ---

// P6: Non-copyable (~Copyable) consume/borrow stress
struct _FflMoveOnly: ~Copyable {
    var payload: Int
    init(_ v: Int) { payload = v }
    consuming func consume() -> Int { payload }
    borrowing func inspect() -> Int { payload }
}
func _ffl_p6_transfer(_ v: consuming _FflMoveOnly) -> Int {
    v.consume()
}
do {
    var _ffl_mo = _FflMoveOnly(String(describing: called).count)
    _ = _ffl_mo.inspect()           // borrow — ownership retained
    let _ffl_result = _ffl_p6_transfer(_ffl_mo) // consume — ownership transferred
    _ = _ffl_result
    // Re-init after consume
    _ffl_mo = _FflMoveOnly(0)
    _ = _ffl_mo.inspect()
}
