import _Differentiation
public protocol Layer_bd5a5c1: Differentiable {
  associatedtype Input: Differentiable
  associatedtype Output: Differentiable
  @differentiable(reverse, wrt: input)
  func callAsFunction(_ input: Input) -> Output
public class Function1_bd5a5c1<Input: Differentiable, Output: Differentiable>: Layer_bd5a5c1 {
  public func callAsFunction(_ input: Input) -> Output {
