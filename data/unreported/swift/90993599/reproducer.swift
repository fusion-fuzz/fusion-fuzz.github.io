// RUN: %target-swift-frontend -emit-ir %s

public protocol P {}

public protocol Q {
  associatedtype A: P
}

public func f<T: P>(_: T) {}

public func foo1<each T: Q>(t: repeat each T, u: repeat (each T).A) {
  repeat f(each u)
}

public func foo2<each T: Q, each U>(t: repeat each T, u: repeat each U)
do {
    print("hello")
} catch MyErr.a(let code),
        MyErr.b(let code)

    where repeat (each U) == (each T).A, (repeat (each T, each U)): Any {
  repeat f(each u)
}
// RUN: %sourcekitd-test -req=format -line=5 -length=1 %s | %FileCheck --strict-whitespace %s
// CHECK: key.sourcetext: ""
