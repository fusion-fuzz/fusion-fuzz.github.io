protocol P { }
extension P where Self == P2 {
    dynamic func p2() -> some P {
