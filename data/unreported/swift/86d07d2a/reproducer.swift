protocol TheProtocol {}
struct TheType1: TheProtocol {}
enum TheEnum: RawRepresentable {
  case case1
  case case2
  init?(rawValue: TheProtocol) {
    self = .case1
  }
  var rawValue: TheProtocol {
    return TheType1()
  }
}
func aTransformer(input: Int) -> TheEnum {
  if input % 2 == 0 {
    return .case1
  } else {
    return .case2
  }
}
