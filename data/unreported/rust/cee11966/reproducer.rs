//! Regression test for <https://github.com/rust-lang/rust/issues/155204>
#![feature(inherent_associated_types)]
#![feature(rustc_attrs)]
#![rustc_no_implicit_bounds]

// Seed A (non-inlined items)
//@compile-flags: -Znext-solver=globally
pub struct Windows<T> {}
//~^ ERROR type parameter `T` is never used

impl<T> Windows<fn(&())> {
    //~^ ERROR the type parameter `T` is not constrained by the impl trait, self type, or predicates
    type AssocType = impl Send;
    //~^ ERROR `impl Trait` in associated types is unstable
    //~| ERROR unconstrained opaque type
    fn ret(&self) -> Self::AssocType {
        //~^ ERROR type annotations needed
        ()
        //~^ ERROR mismatched types
    }
}
//@ revisions: normalize_param_env normalize_obligation hrtb
//@ check-pass
//@ compile-flags: -Znext-solver

trait Foo {
    #[cfg(normalize_param_env)]
    type Gat<'a> where <Self as Mirror>::Assoc: 'a;
    #[cfg(normalize_obligation)]
    type Gat<'a> where Self: 'a;
    #[cfg(hrtb)]
    type Gat<'b> where for<'a> <Self as MirrorRegion<'a>>::Assoc: 'b;
}
//~^ ERROR `main` function not found

trait Mirror { type Assoc; }
impl<T> Mirror for T { type Assoc = T; }

trait MirrorRegion<'a> { type Assoc; }
impl<'a, T> MirrorRegion<'a> for T { type Assoc = T; }

impl<T> Foo for T {
    #[cfg(normalize_param_env)]
    type Gat<'a> = i32 where T: 'a;
    #[cfg(normalize_obligation)]
    type Gat<'a> = i32 where <T as Mirror>::Assoc: 'a;
    #[cfg(hrtb)]
    type Gat<'b> = i32 where Self: 'b;
}

fn main_4494961d() {}


// Seed B (non-inlined items)
//@ revisions: normalize_param_env normalize_obligation hrtb
//@ check-pass
//@ compile-flags: -Znext-solver

trait Foo_b449496 {
    #[cfg(normalize_param_env)]
    type Gat<'a> where <Self as Mirror_b449496>::Assoc: 'a;
    #[cfg(normalize_obligation)]
    type Gat<'a> where Self: 'a;
    #[cfg(hrtb)]
    type Gat<'b> where for<'a> <Self as MirrorRegion_b449496<'a>>::Assoc: 'b;
}

trait Mirror_b449496 { type Assoc; }
impl<T> Mirror_b449496 for T { type Assoc = T; }

trait MirrorRegion_b449496<'a> { type Assoc; }
impl<'a, T> MirrorRegion_b449496<'a> for T { type Assoc = T; }

impl<T> Foo_b449496 for T {
    #[cfg(normalize_param_env)]
    type Gat<'a> = i32 where T: 'a;
    #[cfg(normalize_obligation)]
    type Gat<'a> = i32 where <T as Mirror_b449496>::Assoc: 'a;
    #[cfg(hrtb)]
    type Gat<'b> = i32 where Self: 'b;
}

fn main_4494961d_b449496() {}

fn main() {

    println!("FFL Fusion Done");
}
