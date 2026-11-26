dynamic func f() {}
func h() {
  @_dynamicReplacement(for: f) func r() {}
}
