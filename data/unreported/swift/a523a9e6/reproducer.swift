import Distributed
import Foundation

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//



// ==== Fake Transport ---------------------------------------------------------

struct ActorAddress: Hashable, Sendable, Codable {
  let address: String
  init(parse address : String) {
    self.address = address
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.address = try container.decode(String.self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.address)
  }
}

final class FakeActorSystem: DistributedActorSystem {
  typealias ActorID = ActorAddress
  typealias InvocationDecoder = FakeInvocationDecoder
  typealias InvocationEncoder = FakeInvocationEncoder
  typealias SerializationRequirement = Codable

  func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
      where Act: DistributedActor,
      Act.ID == ActorID  {
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
      where Act: DistributedActor,
      Act.ID == ActorID {
    ActorAddress(parse: "fake://\(actorType)")
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

  func remoteCall<Act, Err, Res>(
      on actor: Act,
      target: RemoteCallTarget,
      invocation: InvocationDecoder,
      throwing: Err.Type,
      returning: Res.Type
  ) async throws -> Res
      where Act: DistributedActor,
            Act.ID == ActorID,
            Res: SerializationRequirement {
    throw FakeDistributedSystemError(message: "mock impl")
  }
}

struct FakeDistributedSystemError: DistributedActorSystemError {
  let message: String
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

@available(SwiftStdlib 5.5, *)
typealias DefaultDistributedActorSystem = FakeActorSystem

// ==== ------------------------------------------------------------------------

distributed actor DA {
  typealias ActorSystem = FakeActorSystem

  distributed func hello(other: DA) {}
}


// --- Seed A ---

let text = "Hello World"
let decorations: [(Int, String)] = [
    (1, "\u{001B}[1mHello World\u{001B}[0m"),
    (2, "\u{001B}[2mHello World\u{001B}[0m"),
    (3, "\u{001B}[3mHello World\u{001B}[0m"),
    (4, "\u{001B}[4mHello World\u{001B}[0m"),
    (7, "\u{001B}[7mHello World\u{001B}[0m"),
    (8, "\u{001B}[8mHello World\u{001B}[0m"),
    (5, "\u{001B}[5mHello World\u{001B}[0m"),
    (6, "\u{001B}[6mHello World\u{001B}[0m"),
    (9, "\u{001B}[9mHello World\u{001B}[0m"),
    (1 | 4, "\u{001B}[1;4mHello World\u{001B}[0m"),
    (1 | 4 | 8, "\u{001B}[1;4;8mHello World\u{001B}[0m")
]

for (mask, expected) in decorations {
    var codes: [String] = []
    if mask & 1 != 0 { codes.append("1") }
    if mask & 2 != 0 { codes.append("2") }
    if mask & 4 != 0 { codes.append("4") }
    if mask & 8 != 0 { codes.append("8") }
    if mask & 16 != 0 { codes.append("5") }
    if mask & 32 != 0 { codes.append("6") }
    if mask & 64 != 0 { codes.append("7") }
    if mask & 128 != 0 { codes.append("9") }
    let actual = "\u{001B}[" + codes.joined(separator: ";") + "m" + text + "\u{001B}[0m"
    _ = actual == expected
}

var fusion_dd44 = actual

// --- Seed B ---
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//



// ==== Fake Transport ---------------------------------------------------------

struct ActorAddress: Hashable, Sendable, Codable {
  let address: String
  init(parse address : String) {
    self.address = address
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.address = try container.decode(String.self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.address)
  }
}

final class FakeActorSystem: DistributedActorSystem {
  typealias ActorID = ActorAddress
  typealias InvocationDecoder = FakeInvocationDecoder
  typealias InvocationEncoder = FakeInvocationEncoder
  typealias SerializationRequirement = Codable

  func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
      where Act: DistributedActor,
      Act.ID == ActorID  {
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
      where Act: DistributedActor,
      Act.ID == ActorID {
    ActorAddress(parse: "fake://\(actorType)")
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

  func remoteCall<Act, Err, Res>(
      on actor: Act,
      target: RemoteCallTarget,
      invocation: InvocationDecoder,
      throwing: Err.Type,
      returning: Res.Type
  ) async throws -> Res
      where Act: DistributedActor,
            Act.ID == ActorID,
            Res: SerializationRequirement {
    throw FakeDistributedSystemError(message: fusion_dd44)
  }
}

struct FakeDistributedSystemError: DistributedActorSystemError, FakeInvocationDecoder {
  let message: String
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

@available(SwiftStdlib 5.5, *)
typealias DefaultDistributedActorSystem = FakeActorSystem

// ==== ------------------------------------------------------------------------

distributed actor DA {
  typealias ActorSystem = FakeActorSystem

  distributed func hello(other: DA) {}
}
// --- Bug Primitive ---

// P8: Property wrapper composition stress
@propertyWrapper
struct _FflClamped<T: Comparable> {
    private var _v: T
    let lo: T, hi: T
    init(wrappedValue: T, lo: T, hi: T) {
        _v = min(max(wrappedValue, lo), hi)
        self.lo = lo; self.hi = hi
    }
    var wrappedValue: T {
        get { _v }
        set { _v = min(max(newValue, lo), hi) }
    }
    var projectedValue: (T, T) { (lo, hi) }

    final class FakeActorSystem: DistributedActorSystem {
    typealias ActorID = ActorAddress
    typealias InvocationDecoder = FakeInvocationDecoder
    typealias InvocationEncoder = FakeInvocationEncoder
    typealias SerializationRequirement = Codable

    func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
    where Act: DistributedActor,
    Act.ID == ActorID  {
    return nil
    }

    func assignID<Act>(_ actorType: Act.Type) -> ActorID
    where Act: DistributedActor,
    Act.ID == ActorID {
    ActorAddress(parse: "fake://\(actorType)")
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

    func remoteCall<Act, Err, Res>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation: InvocationDecoder,
    throwing: Err.Type,
    returning: Res.Type
    ) async throws -> Res
    where Act: DistributedActor,
    Act.ID == ActorID,
    Res: SerializationRequirement {
    throw FakeDistributedSystemError(message: "mock impl")
    }
    }

    struct FakeDistributedSystemError: DistributedActorSystemError {
    let message: String
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

    @available(SwiftStdlib 5.5, *)
    typealias DefaultDistributedActorSystem = FakeActorSystem

    // ==== ------------------------------------------------------------------------

    distributed actor DA {
    typealias ActorSystem = FakeActorSystem

    distributed func hello(other: DA) {}
    }
}
@propertyWrapper
struct _FflLogged<T: CustomStringConvertible> {
    var wrappedValue: T
    init(wrappedValue: T) { self.wrappedValue = wrappedValue }
    var projectedValue: String { "logged:\(wrappedValue)" }
}
struct _FflSettings {
    @_FflClamped(lo: 0, hi: 100) var volume: Int = 50
    @_FflLogged var name: String = "default"
}
do {
    var _ffl_s = _FflSettings()
    _ffl_s.volume = String(describing: fusion_dd44).count % 200  // may exceed hi → clamped
    _ffl_s.name   = String(describing: fusion_dd44)
    _ = _ffl_s.$name
    _ = _ffl_s.$volume
}
