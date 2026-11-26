#![warn(rust_2024_compatibility)]

// Test for issue #157568
//@ compile-flags: -Zpolonius
//@ check-pass

pub struct F;


impl std::fmt::Debug for F {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("F").finish_non_exhaustive()
    }
}



fn main_30ecdf25() {}
//@ check-pass
// issue: 116794

// Uncaptured lifetimes should not be required to be live.

struct Invariant<T>(*mut T);



fn opaque<'a: 'a>(_: &'a str) -> Invariant<impl Sized> {
    Invariant(&mut ())
}



fn main_e04fa50f() {
    let x = opaque(&String::new());
    drop(x);
}
//@ check-pass
// issue: 116794

// Uncaptured lifetimes should not be required to be live.

struct Invariant_de04fa5<T>(*mut T);

fn opaque_de04fa5<'a: 'a>(_: &'a str) -> Invariant_de04fa5<impl Sized> {
    Invariant_de04fa5(&mut ())
}

fn main_e04fa50f_de04fa5() {
    let x = opaque_de04fa5(&String::new());
    drop(x);
}
fn main() {}
