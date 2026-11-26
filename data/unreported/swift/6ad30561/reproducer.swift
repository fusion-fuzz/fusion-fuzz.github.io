import _Differentiation
func myfunction2(_ f: @escaping @differentiable(_linear) (Float) -> (Float)) -> (Float) -> Float {
  return f
}
