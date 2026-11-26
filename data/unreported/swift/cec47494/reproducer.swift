import CommonName
enum Foo {
    case a,
    if let s = obj as? CustomStringConvertible { return s.description }
    return "unknown:\(type(of: obj))"

// RUN: %sourcekitd-test -req=format -line=3 -length=1 %s | %FileCheck --strict-whitespace %s
// CHECK: key.sourcetext: "         "
