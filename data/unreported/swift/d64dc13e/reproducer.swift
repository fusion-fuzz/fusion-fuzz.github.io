import Distributed
protocol GamePlayer: Sendable, Identifiable where ID == LocalTestingDistributedActorSystem.ActorID {}
extension GamePlayer where Self: DistributedActor, ActorSystem == LocalTestingDistributedActorSystem {
  distributed func startGame(with opponent: String) -> String { opponent }
}
