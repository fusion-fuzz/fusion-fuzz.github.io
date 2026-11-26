protocol Q { var i: Int { get set } }
struct C: Q {
  let m: some Equatable = 5
  var i = 0
}
