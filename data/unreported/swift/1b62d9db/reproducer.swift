import Distributed
// RUN: %target-typecheck-verify-swift -target %target-swift-5.7-abi-triple
// REQUIRES: concurrency
// REQUIRES: distributed


/// This adds test coverage for rdar://91857262 in which the extension below would cause a crash.
protocol GamePlayer: Sendable, Identifiable where ID == LocalTestingDistributedActorSystem.ActorID {}
// RUN: not %swift -Xcc -fake-argument -typecheck %s 2>&1 | %FileCheck %s -check-prefix=CHECK-UNKNOWN-ARG
// CHECK-UNKNOWN-ARG: unknown argument: '-fake-argument'

// RUN: not %swift -Xcc -ivfsoverlay -Xcc %t.nonexistent -typecheck %s 2>&1 | %FileCheck %s -check-prefix=CHECK-VFS-NONEXISTENT
// CHECK-VFS-NONEXISTENT: virtual filesystem overlay file '{{.*}}' not found

// RUN: not %swift -Xcc --version -typecheck %s 2>&1 | %FileCheck %s -check-prefix=CHECK-DRIVER-OPTION

extension GamePlayer where Self: DistributedActor, ActorSystem == LocalTestingDistributedActorSystem {
  distributed func startGame(with opponent: String) -> String { opponent }
}

distributed actor FishPlayer: GamePlayer {
  typealias ActorSystem = LocalTestingDistributedActorSystem
}
// CHECK-DRIVER-OPTION-DAG: {{clang|LLVM}} version {{[0-9]+\.[0-9]+}}
// CHECK-DRIVER-OPTION-DAG: error: unable to handle compilation, expected exactly one compiler job
// CHECK-DRIVER-OPTION-DAG: error: clang importer creation failed
