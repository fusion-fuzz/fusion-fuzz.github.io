#![feature(custom_mir, core_intrinsics)]
extern crate core;
use core::intrinsics::mir::*;
use std::env;
use std::fs;
// Check that validation rejects resume terminator in a non-cleanup block.
//
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "built")]
pub fn main_0a1de758() {
    mir! {
        {
            UnwindResume() //~ ERROR resume on non-cleanup block
        }
    }
}


// Seed B (non-inlined items)
// Check that validation rejects resume terminator in a non-cleanup block.
//
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "built")]


fn main_7fc18b19() {
let args: Vec<String> = env::args().collect();
mir! {
        {
            UnwindResume() //~ ERROR resume on non-cleanup block
        }
    }
if args.len() < 2 {
        return;
    }
let path = &args[1];
let content = fs::read_to_string(path).expect("failed to read file");
let _: i32 = content.trim().parse().expect("failed to parse int");
    println!("FFL Fusion Done");
}
fn main() {}
