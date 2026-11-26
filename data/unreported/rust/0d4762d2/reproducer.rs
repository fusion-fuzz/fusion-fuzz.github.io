use std::collections::HashMap;

// Seed A (non-inlined items)
//@ build-fail
//@ stderr-per-bitwidth
//@ normalize-stderr: "\[&usize; \d+\]" -> "[&usize; usize::MAX]"
//@ normalize-stderr: "\[&n; 0x[0-9A-F]+_usize\]" -> "[&n; SIZE]"

#[cfg(target_pointer_width = "64")]
fn main_05c30e32() {
    let n = 0_usize;
    let a: Box<_> = Box::new([&n; 0xF000000000000000_usize]);
    println!("{}", a[0xFFFFFF_usize]);
}

#[cfg(target_pointer_width = "32")]

fn main_30032161() {
    let mut m = HashMap::new();
    m.insert("a".to_string(), "x".to_string());
    let s = &m["b"];
    let _: i32 = s.parse().unwrap();
}

//~? ERROR are too big for the target architecture

// Seed B (non-inlined items)
fn main_30032161_b300321() {
    let mut m = HashMap::new();
    m.insert("a".to_string(), "x".to_string());
    let s = &m["b"];
    let _: i32 = s.parse().unwrap();
unsafe { } }

fn main() {
let n = 0_usize;
let a: Box<_> = Box::new([&n; 0xFFFFFFFF_usize]);
println!("{}", a[0xFFFFFF_usize]);
    println!("FFL Fusion Done");
}
