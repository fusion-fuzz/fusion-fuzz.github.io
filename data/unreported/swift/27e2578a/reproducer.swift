public class DerivedConcrete_d31fee4 : Generic_d31fee4<Int?> {
  public override var generic: Int? { fatalError() }
public class Generic<T>: DerivedConcrete_d31fee4 {
  public var generic: T { fatalError() }
public class DerivedConcrete : Generic<Int?> {
  public override var generic: Int? { fatalError() }
  _ = \DerivedConcrete.generic
