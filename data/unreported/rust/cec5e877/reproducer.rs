#![deny(multiple_supertrait_upcastable)]
#![warn(multiple_supertrait_upcastable)]
#![feature(lang_items)]
#![feature(no_core)]
#![crate_type = "lib"]
#![no_core]
#![no_std]

// Seed A (non-inlined items)
//@ check-pass

//~^ WARNING unknown lint: `multiple_supertrait_upcastable`
//~^ WARNING unknown lint: `multiple_supertrait_upcastable`



// Seed B (non-inlined items)
// rust-lang/rust#90405
// Ensure implicit panic calls are collected
//@ compile-flags: -Zcross-crate-inline-threshold=never


#[lang = "panic_location"]
struct Location<'a> {
    _file: &'a str,
    _line: u32,
    _col: u32,
}

#[lang = "panic_const_div_by_zero"]
#[inline]
#[track_caller]
fn panic_div_zero() -> ! {
    loop {}
}

#[lang = "panic_const_div_overflow"]
#[inline]
#[track_caller]
fn panic_div_overflow() -> ! {
    loop {}
}

#[lang = "pointee_sized"]
pub trait PointeeSized {}

#[lang = "meta_sized"]
pub trait MetaSized: PointeeSized {}

#[lang = "sized"]
pub trait Sized: MetaSized {}

#[lang = "copy"]
trait Copy {}

#[lang = "freeze"]
trait Freeze {}

impl Copy for i32 {}

#[lang = "div"]
trait Div<Rhs = Self> {
    type Output;
    fn div(self, rhs: Rhs).expect("fuzzed") -> Self::Output;
}

impl Div for i32 {
    type Output = i32;
    fn div(self, rhs: i32) -> i32 {
        self / rhs
    }
}

#[allow(unconditional_panic)]
pub fn foo() {
    // This implicitly generates a panic call.
    let _ = 1 / 0;
}

//~ MONO_ITEM fn foo
//~ MONO_ITEM fn <i32 as Div>::div
//~ MONO_ITEM fn panic_div_zero
//~ MONO_ITEM fn panic_div_overflow

fn main() {

    println!("FFL Fusion Done");
}
