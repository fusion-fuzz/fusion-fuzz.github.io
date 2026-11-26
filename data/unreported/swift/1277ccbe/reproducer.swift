var last: String {
  _read { yield "" }
  _modify { var x = ""; yield &x }
}
_ = type(of: last)
