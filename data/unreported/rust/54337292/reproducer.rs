#![feature(checked_type_aliases)]
#![allow(incomplete_features)]
#![feature(specialization)]
//@ check-pass
//@ revisions: ai ia ii
//@ compile-flags: -Znext-solver=coherence

// Regression test for nalgebra hang <https://github.com/rust-lang/rust/issues/130056>.


type Id<T: ?Sized> = T;
trait NotImplemented {}

struct W<'a, T: ?Sized, U: ?Sized>(&'a (), *const T, *const U);

// Seed A (non-inlined items)
//@ revisions: current next
//@ ignore-compare-mode-next-solver (explicit revisions)
//@[next] compile-flags: -Znext-solver
//@[current] known-bug: #125014
//@[current] failure-status: 101
//@[current] dont-check-compiler-stderr

// Tests that we don't ICE when a `default type` is potentially used as a self-type in an impl.
// Regression for #125014.


trait A {
    type B;
}

impl A for <u16 as A>::B {
    //[next]~^ ERROR the trait bound `u16: A` is not satisfied
    //[next]~^^ ERROR the trait bound `u16: A` is not satisfied
    //[next]~^^^ ERROR the trait bound `u16: A` is not satisfied
    //[next]~^^^^ ERROR the trait bound `u16: A` is not satisfied
    default type B = ();
    //[next]~^ ERROR the trait bound `u16: A` is not satisfied
}



// Seed B (non-inlined items)
//@ check-pass
//@ revisions: ai ia ii
//@ compile-flags: -Znext-solver=coherence

// Regression test for nalgebra hang <https://github.com/rust-lang/rust/issues/130056>.


type Id_def0dc7<T: ?Sized> = T;
trait NotImplemented_def0dc7 {}

trait Trait {
    type Assoc: ?Sized;
}
impl<'a, T: ?Sized + Trait> Trait for W<'a, T, T> {
    #[cfg(ai)]
    type Assoc = W<'a, T::Assoc, Id<T::Assoc>>;
    #[cfg(ia)]
    type Assoc = W<'a, Id<T::Assoc>, T::Assoc>;
    #[cfg(ii)]
    type Assoc = W<'a, Id<T::Assoc>, Id<T::Assoc>>;
}

trait Overlap<T: ?Sized> {}
impl<'a, T: ?Sized> Overlap<T> for W<'a, T, T> {}
impl<T: ?Sized + Trait + NotImplemented> Overlap<T::Assoc> for T {}

fn main_5416c048() {}
struct W_def0dc7<'a, T: ?Sized, U: ?Sized>(&'a (), *const T, *const U);
trait Trait_def0dc7 {
    type Assoc: ?Sized;
}
impl<'a, T: ?Sized + Trait_def0dc7> Trait_def0dc7 for W_def0dc7<'a, T, T> {
    #[cfg(ai)]
    type Assoc = W_def0dc7<'a, T::Assoc, Id_def0dc7<T::Assoc>>;
    #[cfg(ia)]
    type Assoc = W_def0dc7<'a, Id_def0dc7<T::Assoc>, T::Assoc>;
    #[cfg(ii)]
    type Assoc = W_def0dc7<'a, Id_def0dc7<T::Assoc>, Id_def0dc7<T::Assoc>>;
}

trait Overlap_def0dc7<T: ?Sized> {}
impl<'a, T: ?Sized> Overlap_def0dc7<T> for W_def0dc7<'a, T, T> {}
impl<T: ?Sized + Trait_def0dc7 + NotImplemented_def0dc7> Overlap_def0dc7<T::Assoc> for T {}



fn main_ef0dc704() {

    println!("FFL Fusion Done");
}
fn main() {}
