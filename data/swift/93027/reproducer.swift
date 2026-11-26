protocol Q { associatedtype T }
protocol P : C, Q {}
class C : P {}
