import _Differentiation
class Wrapper<T> {
}
public struct Struct<Scalar> {
}
extension Struct: Differentiable where Scalar: Differentiable {
  public static func id(x: Self) -> Self {
  }
}
public func f<Scalar: Differentiable>(
  reduction: @differentiable(reverse) (Struct<Scalar>) -> Struct<Scalar> = Struct.id
) -> Struct<Scalar> {
}
