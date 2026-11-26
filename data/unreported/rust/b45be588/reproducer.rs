#![feature(custom_mir, core_intrinsics)]
extern crate core;
use core::intrinsics::mir::*;




// Seed A (non-inlined items)
//@ compile-flags: --crate-type=lib -Zlint-mir -Ztreat-err-as-bug
//@ build-fail
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "runtime", phase = "optimized")]


// Seed B (non-inlined items)
//@ check-pass
// Regression test for <https://github.com/rust-lang/rust/issues/101363>

const OPTIONAL_SLICE_V1: Option<&'static [u8]> = Some(&{
    let array = [1, 2, 3];
    array
});





fn main_edfe8310() {
let _ = OPTIONAL_SLICE_V1;
mir! {
        let a: [u8; 1024];
        {
            a = a; //~ ERROR broken MIR
                   //~^ ERROR encountered `_1 = copy _1` statement with overlapping memory
            Return()
        }
    }
    println!("FFL Fusion Done");
}
//@ check-pass
// Regression test for <https://github.com/rust-lang/rust/issues/101363>

const OPTIONAL_SLICE_V1_d976235: Option<&'static [u8]> = Some(&{
    let array = [1, 2, 3];
    array
});



fn main_976235b5() {
    let _ = OPTIONAL_SLICE_V1;
}

fn main_976235b5_d976235() {
    let _ = OPTIONAL_SLICE_V1_d976235;
}
fn main() {}
