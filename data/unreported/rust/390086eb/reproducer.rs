#![feature(extern_item_impls, contracts)]
#![allow(incomplete_features)]
#[eii(hello)]
fn hello(x: u64);
#[hello]
#[core::contracts::requires(x > 0)]
fn hello_impl(x: u64) { let y = 1; drop(y); }
fn main() {}
