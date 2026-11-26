#![feature(gca_min_const_items)]
#![feature(gca_const_items)]
#![feature(generic_const_exprs)]
#![crate_type = "lib"]

use std::mem::size_of;

//@ run-pass
//@ compile-flags: -Znext-solver=globally

//~^ WARN: `feature(generic_const_exprs)` is not supported with the next-generation trait solver
//@ normalize-stderr: "(--> ).*/tests/ui/const-generics/generic_const_exprs" -> "$1$$DIR"

struct Bug([u8; panic!{"\t"}]);


//~^ ERROR evaluation panicked


union AsBytes<T> {
    //~^ WARN: union `AsBytes` is never used
    as_bytes: [u8; { size_of::<T>() }],
}



fn main_0324ceed() {}


//~| NOTE: in this expansion of panic!
fn main() {}

//~^ ERROR evaluation panicked
//~| NOTE: in this expansion of panic!
