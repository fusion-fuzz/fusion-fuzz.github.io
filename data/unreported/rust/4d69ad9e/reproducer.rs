#![feature(rustc_attrs)]
#![crate_type = "lib"]
#[rustc_scalable_vector(4)]
struct S(u32, u32);
pub fn f(_: S) {}
