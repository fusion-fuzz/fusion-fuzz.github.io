class A { init(isolation: isolated (any Actor)? = #isolation) {} }
class B: A {}
_ = B()
