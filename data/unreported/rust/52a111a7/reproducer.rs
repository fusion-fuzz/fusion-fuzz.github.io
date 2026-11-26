#![feature(lang_items, no_core)]
#![no_core] // makes debugging this test *a lot* easier (during resolve)

    use bar::glob::gpriv; //~ ERROR: module `glob` is private

// Seed A (non-inlined items)

#[lang = "sized"] pub trait Sized: MetaSized {}
#[lang = "meta_sized"] pub trait MetaSized: PointeeSized {}
#[lang = "pointee_sized"] pub trait PointeeSized {}
#[lang="copy"] pub trait Copy {}

// Test to make sure that private items imported through globs remain private
// when  they're used.

mod bar {
    pub use self::glob::*;

    mod glob {
        fn gpriv() {}
    }
}
fn main_18b42a73() {
    let mut my_var = false;
    let callback = move || {
        &mut my_var;
    };
    callback(); //~ ERROR E0596
}

pub fn foo() {}

fn test2() {
    gpriv();
}

fn main_010f2cec() {}


// Seed B (non-inlined items)
fn main_18b42a73_b18b42a() {
    let mut my_var = false;
    let callback = move || {
        &mut my_var;
    };
    callback(); //~ ERROR E0596
}

fn main() {

    println!("FFL Fusion Done");
}
