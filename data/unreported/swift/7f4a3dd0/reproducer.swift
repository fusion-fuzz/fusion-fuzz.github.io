import _Differentiation
public protocol Layer: Differentiable {
  associatedtype Input: Differentiable
  associatedtype Output: Differentiable
  @differentiable(reverse, wrt: input)
  func callAsFunction(_ input: Input) -> Output
}
public class Function1<Input: Differentiable, Output: Differentiable>: Layer {
  public func callAsFunction(_ input: Input) -> Output { fatalError() }
}
