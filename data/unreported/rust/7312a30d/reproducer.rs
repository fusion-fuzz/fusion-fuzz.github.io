#![feature(custom_mir, core_intrinsics)]
extern crate core;
use core::intrinsics::mir::*;


// Seed A (non-inlined items)


// Regression test for issue #149910.
// The compiler previously incorrectly claimed that the local param-env bound
// shadowed the global impl, but they are actually the same.

trait Trait {
    type Assoc;
}



impl<T> Trait for T {
    type Assoc = T;
}



fn foo<T: Trait>(x: T::Assoc) -> u32 {
    x //~ ERROR mismatched types
}




//@ compile-flags: -Zlint-mir -Ztreat-err-as-bug -Zeagerly-emit-delayed-bugs
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "built")]
fn main_b99987c30() {
    mir! {
        let a: ();
        {
            StorageLive(a);
            RET = a;
            Return() //~ ERROR broken MIR
                     //~^ ERROR has storage when returning
        }
    }
}

// Seed B (non-inlined items)
//@ compile-flags: -Zlint-mir -Ztreat-err-as-bug -Zeagerly-emit-delayed-bugs
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "built")]


fn main_7cf1d07e() {
mir! {
        let a: ();
        {
            StorageLive(a);
            RET = a;
            Return() //~ ERROR broken MIR
                     //~^ ERROR has storage when returning
        }
    }
    println!("FFL Fusion Done");
}
//@ compile-flags: -Zlint-mir -Ztreat-err-as-bug -Zeagerly-emit-delayed-bugs
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "built")]
fn main_99987c30() {
    mir! {
        let a: ();
        {
            StorageLive(a);
            RET = a;
            Return() //~ ERROR broken MIR
                     //~^ ERROR has storage when returning
        }
    }
}
fn main() {}
