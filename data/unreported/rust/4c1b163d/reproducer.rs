//! Regression test for https://github.com/rust-lang/rust/issues/2074
#![allow(non_camel_case_types)]
#![feature(link_llvm_intrinsics)]

// Seed A (non-inlined items)

//@ run-pass




// Seed B (non-inlined items)
//@ build-fail
//@ ignore-backends: gcc


extern "llvm-intrinsic" {
    #[link_name = "llvm.assume"]
    fn foo();
    //~^ ERROR: intrinsic signature mismatch for `llvm.assume`: expected signature `void (i1)`, found `void ()`
}



fn main() {
let one = || {
        enum r {
            a,
        }
        r::a as usize
    };
let two = || {
        enum r {
            a,
        }
        r::a as usize
    };
one();
two();
unsafe { foo() }
    println!("FFL Fusion Done");
}
