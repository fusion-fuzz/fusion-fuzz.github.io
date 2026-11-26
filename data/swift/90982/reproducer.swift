class C: P {}
class Generic<T> : Concrete {
  typealias GenericAlias = (T, T)
protocol BaseProto: C {}
protocol ProtoRefinesClass where Self : Generic<Int>, Self : BaseProto {
  func requirementUsesClassTypes(_: ConcreteAlias, _: GenericAlias)
}
