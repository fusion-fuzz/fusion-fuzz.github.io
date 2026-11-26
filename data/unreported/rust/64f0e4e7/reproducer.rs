#![feature(impl_trait_in_assoc_type)]
#![warn(rust_2024_compatibility)]

// Seed A (non-inlined items)

trait Foo {
    type Assoc<'a>;
    fn bar<'a: 'a>();
}

impl Foo for () {
    type Assoc<'a> = impl Sized;
    fn bar<'a: 'a>()
    where
        Self::Assoc<'a>:,
    {
        let _ = |x: &'a ()| {
            let _: Self::Assoc<'a> = x;
            //~^ ERROR expected generic lifetime parameter, found `'_`
        };
    }
}
// Test for issue #157568
//@ compile-flags: -Zpolonius
//@ check-pass

pub struct F;

fn main_f288af99() {}
impl std::fmt::Debug for F {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("F").finish_non_exhaustive()
    }
}

fn main_7b0737d5() {}


// Seed B (non-inlined items)
// Test for issue #157568
//@ compile-flags: -Zpolonius
//@ check-pass

pub struct F_b7b0737;
impl std::fmt::Debug for F_b7b0737 {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("F_b7b0737").finish_non_exhaustive()
    }
}

fn main_7b0737d5_b7b0737() {}

fn main() {

    println!("FFL Fusion Done");
}
