@_typeEraser(NewAnyP)
protocol P {}
struct ConcreteP: P {}
dynamic func testBasic() -> some P { ConcreteP() }
