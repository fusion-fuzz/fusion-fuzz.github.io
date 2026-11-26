import Darwin
import Dispatch
import Distributed
import Glibc
import Swift
import WinSDK
import _Concurrency
// RUN: %empty-directory(%t)
// RUN: %target-build-swift -target %target-future-triple %import-libdispatch -parse-stdlib -parse-as-library -module-name=main %s -o %t/a.out
// RUN: %target-codesign %t/a.out
// RUN: env %env-SWIFT_IS_CURRENT_EXECUTOR_LEGACY_MODE_OVERRIDE=legacy %target-run %t/a.out | %FileCheck %s

// REQUIRES: libdispatch
// REQUIRES: executable_test
// REQUIRES: concurrency
// REQUIRES: distributed

// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime

// FIXME(distributed): Distributed actors currently have some issues on windows, isRemote always returns false. rdar://82593574
// UNSUPPORTED: OS=windows-msvc


#if canImport(Darwin)
typealias ThreadID = pthread_t
func getCurrentThreadID() -> ThreadID { pthread_self() }
func equalThreadIDs(_ a: ThreadID, _ b: ThreadID) -> Bool { pthread_equal(a, b) != 0 }
#elseif canImport(Glibc)
typealias ThreadID = pthread_t
func getCurrentThreadID() -> ThreadID { pthread_self() }
func equalThreadIDs(_ a: ThreadID, _ b: ThreadID) -> Bool { pthread_equal(a, b) != 0 }
#elseif os(Windows)
typealias ThreadID = UInt32
func getCurrentThreadID() -> ThreadID { GetCurrentThreadId() }
func equalThreadIDs(_ a: ThreadID, _ b: ThreadID) -> Bool { a == b }
#endif

var mainThread: ThreadID?
func isMainThread() -> Bool {
    return equalThreadIDs(getCurrentThreadID(), mainThread!)
}

@_silgen_name("swift_task_isCurrentExecutor")
private func isCurrentExecutor(_ executor: Builtin.Executor) -> Bool

func getExecutor(_ a: AnyActor) -> Builtin.Executor {
  let pack = (a, UnsafeRawPointer?.none)
  return unsafeBitCast(pack, to: Builtin.Executor.self)
}

func isCurrent(_ a: AnyActor) -> Bool {
  return isCurrentExecutor(getExecutor(a))
}

func isMainExecutor() -> Bool {
  isCurrentExecutor(Builtin.buildMainActorExecutorRef())
}

actor A {}

distributed actor DA {
  init(system: FakeActorSystem) {
    self.actorSystem = system
  }
}

distributed actor DA_userDefined {
  init(system: FakeActorSystem) {
    self.actorSystem = system
  }

  nonisolated deinit {}
}

distributed actor DA_userDefined_nonisolated {
  init(system: FakeActorSystem) {
    self.actorSystem = system
  }

  nonisolated deinit {
    print("Deinitializing \(self.id) remote:\(__isRemoteActor(self)) isolated:\(isCurrent(self)) mainThread:\(isMainThread())")
  }
}

distributed actor DA_userDefined_isolated {
  init(system: FakeActorSystem) {
    self.actorSystem = system
  }

  isolated deinit {
    print("Deinitializing \(self.id) remote:\(__isRemoteActor(self)) isolated:\(isCurrent(self)) mainThread:\(isMainThread())")
  }
}

distributed actor DA_state_nonisolated {
  var name: String
  var age: Int

  init(name: String, age: Int, system: FakeActorSystem) {
    self.name = name
    self.age = age
    self.actorSystem = system
  }

  nonisolated deinit {
    print("Deinitializing \(self.id) name=\(name) age=\(age) remote:\(__isRemoteActor(self)) isolated:\(isCurrent(self)) mainThread:\(isMainThread())")
    return
  }
}

distributed actor DA_state_isolated {
  var name: String
  var age: Int

  init(name: String, age: Int, system: FakeActorSystem) {
    self.name = name
    self.age = age
    self.actorSystem = system
  }

  isolated deinit {
    print("Deinitializing \(self.id) name=\(name) age=\(age) remote:\(__isRemoteActor(self)) isolated:\(isCurrent(self)) mainThread:\(isMainThread())")
    return
  }
}

@globalActor actor AnotherActor: GlobalActor {
  static let shared = AnotherActor()
}

distributed actor DA_state_isolated_on_another {
  let name: String
  let age: Int

  init(name: String, age: Int, system: FakeActorSystem) {
    self.name = name
    self.age = age
    self.actorSystem = system
  }

  @AnotherActor
  deinit {
    print("Deinitializing \(self.id) name=\(name) age=\(age) remote:\(__isRemoteActor(self)) isolated-self:\(isCurrent(self)) isolated-other:\(isCurrent(AnotherActor.shared)) mainThread:\(isMainThread())")
    return
  }
}

// ==== Fake Transport ---------------------------------------------------------

struct ActorAddress: Sendable, Hashable, Codable {
  let address: String
  init(parse address : String) {
    self.address = address
  }
}

final class FakeActorSystem: @unchecked Sendable, DistributedActorSystem {
  typealias ActorID = ActorAddress
  typealias SerializationRequirement = Codable
  typealias InvocationDecoder = FakeDistributedInvocationEncoder
  typealias InvocationEncoder = FakeDistributedInvocationEncoder
  typealias ResultHandler = FakeResultHandler

  var n = 0
  let group: DispatchGroup
  
  init(group: DispatchGroup) {
    self.group = group
  }
  
  deinit {
    print("Deinit ActorSystem: mainExecutor=\(isMainExecutor()) mainThread=\(isMainThread())")
    group.leave()
  }

  func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
      where Act: DistributedActor,
            Act.ID == ActorID {
    print("resolve type:\(actorType), address:\(id)")
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
      where Act: DistributedActor,
            Act.ID == ActorID {
    n += 1
    let address = ActorAddress(parse: "addr-\(n)")
    print("assign type:\(actorType), address:\(address)")
    return address
  }

  func actorReady<Act>(_ actor: Act)
      where Act: DistributedActor,
      Act.ID == ActorID {
    print("ready actor:\(actor), address:\(actor.id)")
  }

  func resignID(_ id: ActorID) {
    print("resign address:\(id)")
  }

  @inlinable func makeInvocationEncoder() -> InvocationEncoder {
    .init()
  }

  func remoteCall<Act, Err, Res>(
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
    fatalError("not implemented: \(#function)")
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

class FakeDistributedInvocationEncoder: DistributedTargetInvocationEncoder, DistributedTargetInvocationDecoder {
  typealias SerializationRequirement = Codable

  func recordGenericSubstitution<T>(_ type: T.Type) throws { }
  func recordArgument<Value: SerializationRequirement>(_ argument: RemoteCallArgument<Value>) throws { }
  func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws { }
  func recordErrorType<E: Error>(_ type: E.Type) throws { }
  func doneRecording() throws { }

  // === Receiving / decoding -------------------------------------------------

  func decodeGenericSubstitutions() throws -> [Any.Type] {
    []
  }
  func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument {
    fatalError()
  }
  func decodeReturnType() throws -> Any.Type? {
    nil
  }
  func decodeErrorType() throws -> Any.Type? {
    nil
  }
}

// --- Seed A_d76bc08 ---
// RUN: %target-typecheck-verify-swift

// Test redeclaration checking in local context.

func test1() {
  let x = 123 // expected-note{{'x' previously declared here}}
  func f() {} // expected-note{{'f()' previously declared here}}
  struct S {} // expected-note{{'S' previously declared here}}
  let x = 321 // expected-error{{invalid redeclaration of 'x'}}
  func f() {} // expected-error{{invalid redeclaration of 'f()'}}
  struct S {} // expected-error{{invalid redeclaration of 'S'}}
}

func test2() {
  let x = 123 // expected-warning {{never used}}
  func f() {}
  struct S {}
  do {
    let x = 321 // expected-warning {{never used}}
    func f() {}
    struct S {}
  }
}

func test3<T, T>(_: T, _: T) {}
// expected-note@-1 {{'T' previously declared here}}
// expected-error@-2 {{invalid redeclaration of 'T'}}
// expected-error@-3 {{generic parameter 'T' is not used in function signature}}

func test4(x: Int, x: Int) {}
// expected-note@-1 {{'x' previously declared here}}
// expected-error@-2 {{invalid redeclaration of 'x'}}

struct Test4<T, T> {}
// expected-note@-1 {{'T' previously declared here}}
// expected-error@-2 {{invalid redeclaration of 'T'}}

typealias Test5<T, T> = ()
// expected-note@-1 {{'T' previously declared here}}
// expected-error@-2 {{invalid redeclaration of 'T'}}

enum E {
  case test6(x: Int, x: Int)
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}

  subscript(x: Int, x: Int) -> Int { return 0 }
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}
}

_ = { (x: Int, x: Int) in }
// expected-note@-1 {{'x' previously declared here}}
// expected-error@-2 {{invalid redeclaration of 'x'}}

enum MyError : Error {
  case error(Int, Int)
}

func stmtTest() {
  let n: (Int, Int)? = nil

  if case (let x, let x)? = n {}
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}

  for case (let x, let x) in [(Int, Int)]() {}
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}

  switch n {
  case (let x, let x)?: _ = ()
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}
  case nil: _ = ()
  }

  while case (let x, let x)? = n {}
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}

  guard case (let x, let x)? = n else {}
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}

  do {} catch MyError.error(let x, let x) {}
  // expected-note@-1 {{'x' previously declared here}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}
  // expected-warning@-3 {{unreachable}}
}

func fullNameTest() {
  let x = 123 // expected-warning {{never used}}
  func x() {}
}

// For source compatibility, allow duplicate parameter labels on
// protocol requirements.
protocol SillyProtocol {
  init(x: Int, x: Int)
  init(a x: Int, b x: Int)

  func foo(x: Int, x: Int)
  func foo(a x: Int, b x: Int)

  subscript(x: Int, x: Int) -> Int { get }
  subscript(a x: Int, b x: Int) -> Int { get }
}

// https://github.com/apple/swift/issues/63750
let issue63750 = {
  for (x,x) in [(0,0)] {}
  // expected-error@-1 {{invalid redeclaration of 'x'}}
  // expected-note@-2 {{'x' previously declared here}}

  if case let (x,x) = (0,0) {}
  // expected-error@-1 {{invalid redeclaration of 'x'}}
  // expected-note@-2 {{'x' previously declared here}}

  switch (0,0) {
  case let (x,x):
    // expected-error@-1 {{invalid redeclaration of 'x'}}
    // expected-note@-2 {{'x' previously declared here}}
    ()
  }
  
  func bar(_ x: Int) -> Int { x }
  if case (bar(let x), let x) = (0,0) {}
  // expected-error@-1 {{'let' binding pattern cannot appear in an expression}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}
  // expected-note@-3 {{'x' previously declared here}}
}
func issue63750fn() {
  // Make sure the behavior is consistent with the multi-statement closure case.
  for (x,x) in [(0,0)] {}
  // expected-error@-1 {{invalid redeclaration of 'x'}}
  // expected-note@-2 {{'x' previously declared here}}

  if case let (x,x) = (0,0) {} // expected-warning {{'if' condition is always true}}
  // expected-error@-1 {{invalid redeclaration of 'x'}}
  // expected-note@-2 {{'x' previously declared here}}

  switch (0,0) {
  case let (x,x):
    // expected-error@-1 {{invalid redeclaration of 'x'}}
    // expected-note@-2 {{'x' previously declared here}}
    ()
  }
  func bar(_ x: Int) -> Int { x }
  if case (bar(let x), let x) = (0,0) {}
  // expected-error@-1 {{'let' binding pattern cannot appear in an expression}}
  // expected-error@-2 {{invalid redeclaration of 'x'}}
  // expected-note@-3 {{'x' previously declared here}}
}
// --- Seed B ---
// RUN: %empty-directory(%t)
// RUN: %target-build-swift -target %target-future-triple %import-libdispatch -parse-stdlib -parse-as-library -module-name=main %s -o %t/a.out
// RUN: %target-codesign %t/a.out
// RUN: env %env-SWIFT_IS_CURRENT_EXECUTOR_LEGACY_MODE_OVERRIDE=legacy %target-run %t/a.out | %FileCheck %s

// REQUIRES: libdispatch
// REQUIRES: executable_test
// REQUIRES: concurrency
// REQUIRES: distributed

// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime

// FIXME(distributed): Distributed actors currently have some issues on windows, isRemote always returns false. rdar://82593574
// UNSUPPORTED: OS=windows-msvc


#if canImport(Darwin)
typealias ThreadID_d76bc08 = pthread_t
func getCurrentThreadID_d76bc08() -> ThreadID_d76bc08 { pthread_self() }
func equalThreadIDs_d76bc08(_ a: ThreadID_d76bc08, _ b: ThreadID_d76bc08) -> Bool { pthread_equal(a, b) != 0 }
#elseif canImport(Glibc)
typealias ThreadID_d76bc08 = pthread_t
func getCurrentThreadID_d76bc08() -> ThreadID_d76bc08 { pthread_self() }
func equalThreadIDs_d76bc08(_ a: ThreadID_d76bc08, _ b: ThreadID_d76bc08) -> Bool { pthread_equal(a, b) != 0 }
#elseif os(Windows)
typealias ThreadID_d76bc08 = UInt32
func getCurrentThreadID_d76bc08() -> ThreadID_d76bc08 { GetCurrentThreadId() }
func equalThreadIDs_d76bc08(_ a: ThreadID_d76bc08, _ b: ThreadID_d76bc08) -> Bool { a == b }
#endif

var mainThread_d76bc08: ThreadID_d76bc08?
func isMainThread_d76bc08() -> Bool {
    return equalThreadIDs_d76bc08(getCurrentThreadID_d76bc08(), mainThread_d76bc08!)
}

@_silgen_name("swift_task_isCurrentExecutor")
private func isCurrentExecutor_d76bc08(_ executor: Builtin.Executor) -> Bool

func getExecutor_d76bc08(_ a: AnyActor) -> Builtin.Executor {
  let pack = (a, UnsafeRawPointer?.none)
  return unsafeBitCast(pack, to: Builtin.Executor.self)
}

func isCurrent_d76bc08(_ a: AnyActor) -> Bool {
  return isCurrentExecutor_d76bc08(getExecutor_d76bc08(a))
}

func isMainExecutor_d76bc08() -> Bool {
  isCurrentExecutor_d76bc08(Builtin.buildMainActorExecutorRef())
}

actor A_d76bc08 {}

distributed actor DA {
  init(system: FakeActorSystem_d76bc08) {
    self.actorSystem = system
  }
}

distributed actor DA_userDefined {
  init(system: FakeActorSystem_d76bc08) {
    self.actorSystem = system
  }

  nonisolated deinit {}
}

@available(SwiftStdlib 5.5, *)
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

typealias DefaultDistributedActorSystem = FakeActorSystem

// ==== Execute ----------------------------------------------------------------

func test() {
  let group = DispatchGroup()
  var dummy: AnyObject?

  func check(factory: () -> AnyObject) {
    dummy = factory()
    // Test requires actor system to be released before the actor,
    // so that release of the actor system from actor deinit is the last one
    group.enter()
    dummy = nil
    group.wait()
  }

  // no lifecycle things make sense for a normal actor, double check we didn't emit them
  print("before A")
  _ = A()
  print("after A")
  // CHECK: before A
  // CHECK: after A

  check {
    DA(system: DefaultDistributedActorSystem(group: group))
  }
  // CHECK: assign type:DA, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA, address:ActorAddress(address: "[[ADDR1:addr-[0-9]]]")
  // CHECK: resign address:ActorAddress(address: "[[ADDR1]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread=true

  check {
    DA_userDefined(system: DefaultDistributedActorSystem(group: group))
  }
  // CHECK: assign type:DA_userDefined, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_userDefined, address:ActorAddress(address: "[[ADDR2:addr-[0-9]]]")
  // CHECK: resign address:ActorAddress(address: "[[ADDR2]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread=true

  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_userDefined_nonisolated(system: DefaultDistributedActorSystem(group: group))
  }
  // CHECK: assign type:DA_userDefined_nonisolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_userDefined_nonisolated, address:ActorAddress(address: "[[ADDR3:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress(address: "[[ADDR3]]") remote:false isolated:false mainThread:true
  // CHECK-NEXT: resign address:ActorAddress(address: "[[ADDR3]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread=true
  
  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_userDefined_isolated(system: DefaultDistributedActorSystem(group: group))
  }
  // CHECK: assign type:DA_userDefined_isolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_userDefined_isolated, address:ActorAddress(address: "[[ADDR4:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress(address: "[[ADDR4]]") remote:false isolated:true mainThread:true
  // CHECK-NEXT: resign address:ActorAddress(address: "[[ADDR4]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=false mainThread=true

  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_state_nonisolated(name: "Foo", age:37, system: DefaultDistributedActorSystem(group: group))
  }
  // CHECK: assign type:DA_state_nonisolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_state_nonisolated, address:ActorAddress(address: "[[ADDR5:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress(address: "[[ADDR5]]") name=Foo age=37 remote:false isolated:false mainThread:true
  // CHECK-NEXT: resign address:ActorAddress(address: "[[ADDR5]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread=true
  
  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_state_isolated(name: "Bar", age:42, system: DefaultDistributedActorSystem(group: group))
  }
  // CHECK: assign type:DA_state_isolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_state_isolated, address:ActorAddress(address: "[[ADDR6:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress(address: "[[ADDR6]]") name=Bar age=42 remote:false isolated:true mainThread:true
  // CHECK-NEXT: resign address:ActorAddress(address: "[[ADDR6]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=false mainThread=true
  
  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_state_isolated_on_another(name: "Baz", age:57, system: DefaultDistributedActorSystem(group: group))
  }
  // CHECK: assign type:DA_state_isolated_on_another, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_state_isolated_on_another, address:ActorAddress(address: "[[ADDR6:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress(address: "[[ADDR6]]") name=Baz age=57 remote:false isolated-self:false isolated-other:true mainThread:false
  // CHECK-NEXT: resign address:ActorAddress(address: "[[ADDR6]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=false mainThread=false

  // a remote actor should not resign it's address, it was never "assigned" it
  check {
    let address = ActorAddress(parse: "remote-1")
    return try! DA_userDefined_nonisolated.resolve(id: address, using: DefaultDistributedActorSystem(group: group))
  }
  // CHECK-NEXT: resolve type:DA_userDefined_nonisolated, address:ActorAddress(address: "remote-1")
  // MUST NOT run deinit body for a remote distributed actor
  // CHECK-NOT: Deinitializing ActorAddress(address: "remote-1")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread=true
  
  // a remote actor should not resign it's address, it was never "assigned" it
  check {
    let address = ActorAddress(parse: "remote-2")
    return try! DA_userDefined_isolated.resolve(id: address, using: DefaultDistributedActorSystem(group: group))
  }
  // CHECK-NEXT: resolve type:DA_userDefined_isolated, address:ActorAddress(address: "remote-2")
  // MUST NOT run deinit body for a remote distributed actor
  // CHECK-NOT: Deinitializing ActorAddress(address: "remote-2")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread=true
  
  // a remote actor should not resign it's address, it was never "assigned" it
  check {
    let address = ActorAddress(parse: "remote-3")
    return try! DA_state_isolated_on_another.resolve(id: address, using: DefaultDistributedActorSystem(group: group))
  }
  // CHECK-NEXT: resolve type:DA_state_isolated_on_another, address:ActorAddress(address: "remote-3")
  // MUST NOT run deinit body for a remote distributed actor
  // CHECK-NOT: Deinitializing ActorAddress(address: "remote-3")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread=true

  print("DONE")
  // CHECK-NEXT: DONE
}

 struct Main {
  static func main() async {
    mainThread = getCurrentThreadID()
    test()
  }
}
Main.main()  // entry point, was @main

distributed actor DA_userDefined_nonisolated {
  init(system: FakeActorSystem_d76bc08) {
    self.actorSystem = system
  }

  nonisolated deinit {
    print("Deinitializing \(self.id) remote:\(__isRemoteActor(self)) isolated:\(isCurrent_d76bc08(self)) mainThread_d76bc08:\(isMainThread_d76bc08())")
  }
}

distributed actor DA_userDefined_isolated {
  init(system: FakeActorSystem_d76bc08) {
    self.actorSystem = system
  }

  isolated deinit {
    print("Deinitializing \(self.id) remote:\(__isRemoteActor(self)) isolated:\(isCurrent_d76bc08(self)) mainThread_d76bc08:\(isMainThread_d76bc08())")
  }
}

distributed actor DA_state_nonisolated {
  var name: String
  var age: Int

  init(name: String, age: Int, system: FakeActorSystem_d76bc08) {
    self.name = name
    self.age = age
    self.actorSystem = system
  }

  nonisolated deinit {
    print("Deinitializing \(self.id) name=\(name) age=\(age) remote:\(__isRemoteActor(self)) isolated:\(isCurrent_d76bc08(self)) mainThread_d76bc08:\(isMainThread_d76bc08())")
    return
  }
}

distributed actor DA_state_isolated {
  var name: String
  var age: Int

  init(name: String, age: Int, system: FakeActorSystem_d76bc08) {
    self.name = name
    self.age = age
    self.actorSystem = system
  }

  isolated deinit {
    print("Deinitializing \(self.id) name=\(name) age=\(age) remote:\(__isRemoteActor(self)) isolated:\(isCurrent_d76bc08(self)) mainThread_d76bc08:\(isMainThread_d76bc08())")
    return
  }
}

@globalActor actor AnotherActor_d76bc08: GlobalActor {
  static let shared = AnotherActor_d76bc08()
}

distributed actor DA_state_isolated_on_another {
  let name: String
  let age: Int

  init(name: String, age: Int, system: FakeActorSystem_d76bc08) {
    self.name = name
    self.age = age
    self.actorSystem = system
  }

  @AnotherActor_d76bc08
  deinit {
    print("Deinitializing \(self.id) name=\(name) age=\(age) remote:\(__isRemoteActor(self)) isolated-self:\(isCurrent_d76bc08(self)) isolated-other:\(isCurrent_d76bc08(AnotherActor_d76bc08.shared)) mainThread_d76bc08:\(isMainThread_d76bc08())")
    return
  }
}

// ==== Fake Transport ---------------------------------------------------------

struct ActorAddress_d76bc08: Sendable, Hashable, Codable {
  let address: String
  init(parse address : String) {
    self.address = address
  }
}

final class FakeActorSystem_d76bc08: @unchecked Sendable, DistributedActorSystem {
  typealias ActorID = ActorAddress_d76bc08
  typealias SerializationRequirement = x
  typealias InvocationDecoder = FakeDistributedInvocationEncoder_d76bc08
  typealias InvocationEncoder = FakeDistributedInvocationEncoder_d76bc08
  typealias ResultHandler = FakeResultHandler_d76bc08

  var n = 0
  let group: DispatchGroup
  
  init(group: DispatchGroup) {
    self.group = group
  }
  
  deinit {
    print("Deinit ActorSystem: mainExecutor=\(isMainExecutor_d76bc08()) mainThread_d76bc08=\(isMainThread_d76bc08())")
    group.leave()
  }

  func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
      where Act: DistributedActor,
            Act.ID == ActorID {
    print("resolve type:\(actorType), address:\(id)")
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
      where Act: DistributedActor,
            Act.ID == ActorID {
    n += 1
    let address = ActorAddress_d76bc08(parse: "addr-\(n)")
    print("assign type:\(actorType), address:\(address)")
    return address
  }

  func actorReady<Act>(_ actor: Act)
      where Act: DistributedActor,
      Act.ID == ActorID {
    print("ready actor:\(actor), address:\(actor.id)")
  }

  func resignID(_ id: ActorID) {
    print("resign address:\(id)")
  }

  @inlinable func makeInvocationEncoder() -> InvocationEncoder {
    .init()
  }

  func remoteCall<Act, Err, Res>(
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
    fatalError("not implemented: \(#function)")
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

class FakeDistributedInvocationEncoder_d76bc08: DistributedTargetInvocationEncoder, DistributedTargetInvocationDecoder {
  typealias SerializationRequirement = Codable

  func recordGenericSubstitution<T>(_ type: T.Type) throws { }
  func recordArgument<Value: SerializationRequirement>(_ argument: RemoteCallArgument<Value>) throws { }
  func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws { }
  func recordErrorType<E: Error>(_ type: E.Type) throws { }
  func doneRecording() throws { }

  // === Receiving / decoding -------------------------------------------------

  func decodeGenericSubstitutions() throws -> [Any.Type] {
    []
  }
  func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument {
    fatalError()
  }
  func decodeReturnType() throws -> Any.Type? {
    nil
  }
  func decodeErrorType() throws -> Any.Type? {
    nil
  }
}

@available(SwiftStdlib 5.5, *)
public struct FakeResultHandler_d76bc08: DistributedTargetInvocationResultHandler {
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

typealias DefaultDistributedActorSystem_d76bc08 = FakeActorSystem_d76bc08

// ==== Execute ----------------------------------------------------------------

func test_d76bc08() {
  let group = DispatchGroup()
  var dummy: AnyObject?

  func check(factory: () -> AnyObject) {
    dummy = factory()
    // Test requires actor system to be released before the actor,
    // so that release of the actor system from actor deinit is the last one
    group.enter()
    dummy = nil
    group.wait()
  }

  // no lifecycle things make sense for a normal actor, double check we didn't emit them
  print("before A_d76bc08")
  _ = A_d76bc08()
  print("after A_d76bc08")
  // CHECK: before A_d76bc08
  // CHECK: after A_d76bc08

  check {
    DA(system: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK: assign type:DA, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA, address:ActorAddress_d76bc08(address: "[[ADDR1:addr-[0-9]]]")
  // CHECK: resign address:ActorAddress_d76bc08(address: "[[ADDR1]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread_d76bc08=true

  check {
    DA_userDefined(system: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK: assign type:DA_userDefined, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_userDefined, address:ActorAddress_d76bc08(address: "[[ADDR2:addr-[0-9]]]")
  // CHECK: resign address:ActorAddress_d76bc08(address: "[[ADDR2]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread_d76bc08=true

  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_userDefined_nonisolated(system: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK: assign type:DA_userDefined_nonisolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_userDefined_nonisolated, address:ActorAddress_d76bc08(address: "[[ADDR3:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress_d76bc08(address: "[[ADDR3]]") remote:false isolated:false mainThread_d76bc08:true
  // CHECK-NEXT: resign address:ActorAddress_d76bc08(address: "[[ADDR3]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread_d76bc08=true
  
  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_userDefined_isolated(system: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK: assign type:DA_userDefined_isolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_userDefined_isolated, address:ActorAddress_d76bc08(address: "[[ADDR4:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress_d76bc08(address: "[[ADDR4]]") remote:false isolated:true mainThread_d76bc08:true
  // CHECK-NEXT: resign address:ActorAddress_d76bc08(address: "[[ADDR4]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=false mainThread_d76bc08=true

  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_state_nonisolated(name: "Foo", age:37, system: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK: assign type:DA_state_nonisolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_state_nonisolated, address:ActorAddress_d76bc08(address: "[[ADDR5:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress_d76bc08(address: "[[ADDR5]]") name=Foo age=37 remote:false isolated:false mainThread_d76bc08:true
  // CHECK-NEXT: resign address:ActorAddress_d76bc08(address: "[[ADDR5]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread_d76bc08=true
  
  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_state_isolated(name: "Bar", age:42, system: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK: assign type:DA_state_isolated, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_state_isolated, address:ActorAddress_d76bc08(address: "[[ADDR6:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress_d76bc08(address: "[[ADDR6]]") name=Bar age=42 remote:false isolated:true mainThread_d76bc08:true
  // CHECK-NEXT: resign address:ActorAddress_d76bc08(address: "[[ADDR6]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=false mainThread_d76bc08=true
  
  // resign must happen as the _last thing_ after user-deinit completed
  check {
    DA_state_isolated_on_another(name: "Baz", age:57, system: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK: assign type:DA_state_isolated_on_another, address:[[ADDRESS:.*]]
  // CHECK: ready actor:main.DA_state_isolated_on_another, address:ActorAddress_d76bc08(address: "[[ADDR6:addr-[0-9]]]")
  // CHECK: Deinitializing ActorAddress_d76bc08(address: "[[ADDR6]]") name=Baz age=57 remote:false isolated-self:false isolated-other:true mainThread_d76bc08:false
  // CHECK-NEXT: resign address:ActorAddress_d76bc08(address: "[[ADDR6]]")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=false mainThread_d76bc08=false

  // a remote actor should not resign it's address, it was never "assigned" it
  check {
    let address = ActorAddress_d76bc08(parse: "remote-1")
    return try! DA_userDefined_nonisolated.resolve(id: address, using: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK-NEXT: resolve type:DA_userDefined_nonisolated, address:ActorAddress_d76bc08(address: "remote-1")
  // MUST NOT run deinit body for a remote distributed actor
  // CHECK-NOT: Deinitializing ActorAddress_d76bc08(address: "remote-1")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread_d76bc08=true
  
  // a remote actor should not resign it's address, it was never "assigned" it
  check {
    let address = ActorAddress_d76bc08(parse: "remote-2")
    return try! DA_userDefined_isolated.resolve(id: address, using: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK-NEXT: resolve type:DA_userDefined_isolated, address:ActorAddress_d76bc08(address: "remote-2")
  // MUST NOT run deinit body for a remote distributed actor
  // CHECK-NOT: Deinitializing ActorAddress_d76bc08(address: "remote-2")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread_d76bc08=true
  
  // a remote actor should not resign it's address, it was never "assigned" it
  check {
    let address = ActorAddress_d76bc08(parse: "remote-3")
    return try! DA_state_isolated_on_another.resolve(id: address, using: DefaultDistributedActorSystem_d76bc08(group: group))
  }
  // CHECK-NEXT: resolve type:DA_state_isolated_on_another, address:ActorAddress_d76bc08(address: "remote-3")
  // MUST NOT run deinit body for a remote distributed actor
  // CHECK-NOT: Deinitializing ActorAddress_d76bc08(address: "remote-3")
  // CHECK-NEXT: Deinit ActorSystem: mainExecutor=true mainThread_d76bc08=true

  print("DONE")
  // CHECK-NEXT: DONE
}

 struct Main {
  static func main() async {
    mainThread_d76bc08 = getCurrentThreadID_d76bc08()
    test_d76bc08()
  }
}
Main.main()  // entry point, was @main

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
    let _ffl_r = Double(String(describing: x).count)
    let _ffl_shapes: [any _FflShape] = [_FflCircle(r: _ffl_r), _FflRect(w: _ffl_r, h: 2.0)]
    _ = _ffl_p2_sum(_ffl_shapes)
    let _ffl_meta: any _FflShape.Type = _FflCircle.self
    _ = _ffl_meta.init(r: _ffl_r)
}
