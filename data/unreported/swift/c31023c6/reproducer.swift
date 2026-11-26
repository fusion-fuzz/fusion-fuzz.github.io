var bar: SubBar? = SubBar()
extension String: InitAny_d81a39e {
  init() {
  }
}
    _ffl_s.name   = String(describing: bar)
protocol InitAny: InitAny_d81a39e {
  init()
    init() { fatalError() }
}
extension String: InitAny {
  init() {
