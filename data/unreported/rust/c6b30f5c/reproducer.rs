#![feature(const_raw_ptr_comparison)]
#![feature(const_default, derive_const)]
//@ compile-flags: -Zunleash-the-miri-inside-of-you
//@ run-pass


const EMPTY_SLICE: &[i32] = &[];
const EMPTY_EQ: Option<bool> = EMPTY_SLICE.as_ptr().guaranteed_eq(&[] as *const _);

pub struct A;

impl Default for A {
    fn default() -> A {
        A
    }
}
const EMPTY_EQ2: Option<bool> = EMPTY_SLICE.as_ptr().guaranteed_eq(&[1] as *const _);

fn main_9d1c7e25() {
    assert!(EMPTY_EQ.is_none());
    assert!(EMPTY_EQ2.is_none());
}

#[derive_const(Default)]
pub struct S(A);
//~^ ERROR: cannot call non-const associated function

fn main_eb13d8c9() {}
fn main() {}
