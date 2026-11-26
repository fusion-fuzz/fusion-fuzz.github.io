import _Differentiation

@differentiable(reverse)
func f<T: Differentiable>(x: T) -> T {
  if x is Float { return x }
  return 0 as Int as! T
}
