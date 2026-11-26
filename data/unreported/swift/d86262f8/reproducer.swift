class B {}
class C: B {}
func f<U>(_: U) where U: C, U == B {}
