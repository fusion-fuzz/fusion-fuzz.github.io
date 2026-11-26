#![warn(rust_2024_compatibility)]

// Seed A (non-inlined items)
// Test for issue #157568
//@ compile-flags: -Zpolonius
//@ check-pass

pub struct F;
impl std::fmt::Debug for F {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("F").finish_non_exhaustive()
    }
}
//@ check-pass
// issue: 116794

// Uncaptured lifetimes should not be required to be live.

struct Invariant<T>(*mut T);

fn opaque<'a: 'a>(_: &'a str) -> Invariant<impl Sized> {
    Invariant(&mut ())
}

fn main_37131459() {
    let x = opaque(&String::new());
    drop(x);
}

fn main_7b0737d5() {}


// Seed B (non-inlined items)
//@ check-pass
// issue: 116794

// Uncaptured lifetimes should not be required to be live.

struct Invariant_b371314<T>(*mut T);

fn opaque_b371314<'a: 'a>(_: &'a str) -> Invariant_b371314<impl Sized> {
    Invariant_b371314(&mut ())
}

fn main_37131459_b371314() {
    let x = opaque_b371314(&String::new());
    drop(x);
}

fn main() {

    println!("FFL Fusion Done");
}
