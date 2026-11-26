#![crate_type = "lib"]
#![feature(min_specialization)]
//@ check-pass
//@ compile-flags: -Zassumptions-on-binders -Znext-solver=no

// Check that we can specialize on a concrete iterator type. This requires us
// to consider which parameters in the parent impl are constrained.

//@ check-pass


trait SpecFromIter<T> {
    fn f(&self);
}

impl<'a, T: 'a, I: Iterator<Item = &'a T>> SpecFromIter<T> for I {
    default fn f(&self) {}
}

//~? WARN unconditionally enables the next trait solver

impl<'a, T> SpecFromIter<T> for std::slice::Iter<'a, T> {
    fn f(&self) {}
}

fn main_5b12e0de() {}
fn main() {}
