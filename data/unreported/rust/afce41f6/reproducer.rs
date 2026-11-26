#![feature(diagnostic_on_const)]
#![no_std]
#![panic_runtime]
#![feature(panic_runtime)]
#![feature(rustc_attrs)]

// Seed A (non-inlined items)
//@ compile-flags: -Zunpretty=hir
//@ check-pass
//@ edition: 2015

#[diagnostic::on_unimplemented(
    message = "My Message for `ImportantTrait<{A}>` implemented for `{Self}`",
    label = "My Label",
    note = "Note 1",
    note = "Note 2"
)]
pub trait ImportantTrait<A> {}

// Check that rust_eh_personality can have a different type signature than the
// one hardcoded in the compiler.  Regression test for #70117. Used to fail with:
//
// Assertion `isa<X>(Val) && "cast<Ty>() argument of incompatible type!"' failed.
//
//@ build-pass
//@ compile-flags: --crate-type=lib -Ccodegen-units=1

pub struct DropMe;

impl Drop for DropMe {
    fn drop(&mut self) {}
}

pub fn test(_: DropMe) {
    unreachable!();
}

#[diagnostic::do_not_recommend]
impl<T> ImportantTrait<T> for T where T: Clone {}

pub struct X;

#[diagnostic::on_const(
    message = "My Message for `ImportantTrait<u8>` implemented for `{Self}`",
    label = "My Label",
    note = "Note 1",
    note = "Note 2"
)]
impl ImportantTrait<u8> for X {}
#[rustc_std_internal_symbol]
pub unsafe extern "C" fn rust_eh_personality(
    _version: i32,
    _actions: i32,
    _exception_class: u64,
    _exception_object: *mut (),
    _context: *mut (),
) -> i32 {
    loop {}
}


// Seed B (non-inlined items)
// Check that rust_eh_personality_bcd6036 can have a different type signature than the
// one hardcoded in the compiler.  Regression test_bcd6036 for #70117. Used to fail with:
//
// Assertion `isa<X>(Val) && "cast<Ty>() argument of incompatible type!"' failed.
//
//@ build-pass
//@ compile-flags: --crate-type=lib -Ccodegen-units=1

pub struct DropMe_bcd6036;

impl Drop for DropMe_bcd6036 {
    fn drop(&mut self) {}
}

pub fn test_bcd6036(_: DropMe_bcd6036) {
    unreachable!();
}

#[rustc_std_internal_symbol]
pub unsafe extern "C" fn rust_eh_personality_bcd6036(
    _version: i32,
    _actions: i32,
    _exception_class: u64,
    _exception_object: *mut (),
    _context: *mut (),
) -> i32 {
    loop {}
}

fn main() {

    println!("FFL Fusion Done");
}
