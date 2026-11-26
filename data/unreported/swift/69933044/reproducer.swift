var g: (() -> ())?
func outer<T>(w: T) {
  func local<U>(u: U, w: T = g) {}
  local(u: "hi")
}
