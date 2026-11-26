struct G<T> where T: P1, T.A: P1, T.A.A: P1 {}
protocol P1 { associatedtype A }
extension Int: P1 { typealias A = Int }
protocol P2: Sendable {}
extension G: P2 where T.A == Int {}
