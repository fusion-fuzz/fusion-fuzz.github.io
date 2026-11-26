

// --- Seed A ---
// RUN: %target-swift-frontend -target %target-swift-5.1-abi-triple -typecheck -verify %s

// rdar://75978086 - static member lookup doesn't work with opaque types

protocol Intent {}

extension Intent where Self == Intents.List {
    bar
        .fooooooooooo(first: 3,
                      second)[x: 10] {

// RUN: %sourcekitd-test -req=format -line=5 -length=1 %s | %FileCheck --strict-whitespace %s
// CHECK: key.sourcetext: "            "
  static func orderedList() -> Self {
    return Intents.List.orderedList(nestedIn: nil)
  }
}

enum Intents {
  enum List: Intent {
  case orderedList(nestedIn: Any?)
  }
}

let rdar75978086: some Intent = .orderedList() // Ok
// --- Seed B ---
func foo() {
    bar
        .fooooooooooo(first: 3,
                      second)[x: 10] {

// RUN: %sourcekitd-test -req=format -line=5 -length=1 %s | %FileCheck --strict-whitespace %s
// CHECK: key.sourcetext: "            "
var _ffl_sentinel: Int = 0
// --- Bug Primitive ---

// P6: Non-copyable (~Copyable) consume/borrow stress
struct _FflMoveOnly: ~Copyable {
    var payload: Int
    init(_ v: Int) { payload = v }
    consuming func consume() -> Int { payload }
    borrowing func inspect() -> Int { payload }
}
func _ffl_p6_transfer(_ v: consuming _FflMoveOnly) -> Int {
    v.consume()
}
do {
    var _ffl_mo = _FflMoveOnly(String(describing: _ffl_sentinel).count)
    _ = _ffl_mo.inspect()           // borrow — ownership retained
    let _ffl_result = _ffl_p6_transfer(_ffl_mo) // consume — ownership transferred
    _ = _ffl_result
    // Re-init after consume
    _ffl_mo = _FflMoveOnly(0)
    _ = _ffl_mo.inspect()
}
