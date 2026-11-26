#![feature(custom_mir, core_intrinsics)]
//! Test that we require an equal TypeId to have an integer part that properly
//! reflects the type id hash.
#![feature(const_trait_impl, const_cmp)]

extern crate core;
use core::intrinsics::mir::*;
use std::any::TypeId;

// Seed A (non-inlined items)
// Check that validation rejects resume terminator in a non-cleanup block.
//
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "built")]


// Seed B (non-inlined items)



const _: () = {
    let mut b = TypeId::of::<()>();
    unsafe {
        let ptr = &mut b as *mut TypeId as *mut *const ();
        // Copy the ptr at index 0 to index 1
        let val = std::ptr::read(ptr);
        std::ptr::write(ptr.offset(1), val);
    }
    assert!(b == b);
    //~^ ERROR: invalid `TypeId` value
};



fn main() {
mir! {
        {
            UnwindResume() //~ ERROR resume on non-cleanup block
        }
    }
    println!("FFL Fusion Done");
}
