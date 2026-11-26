#![feature(unsafe_binders)]
use std::unsafe_binder::unwrap_binder;
#[derive(Copy, Clone)]
pub struct S(usize);
pub fn f(x: unsafe<'a> S) -> usize {
    unsafe { (|| unwrap_binder!(x).0)() }
}
fn main() {}
