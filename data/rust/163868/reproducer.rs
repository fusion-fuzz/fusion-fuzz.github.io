#![feature(fn_delegation)]
#![allow(incomplete_features)]

trait C {}

struct S<const C: usize>;

impl<const C: usize> S<C> {
    fn foo_self<T>(self) {}
}

trait Trait {
    reuse S::<1>::foo_self::<_> as foo_self_4;
}

fn main() {}
