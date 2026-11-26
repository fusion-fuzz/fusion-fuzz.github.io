#![feature(generic_const_exprs, inherent_associated_types, gca_const_items, gca_min_const_items)]
#![allow(incomplete_features)]
use std::gca;
struct Foo<const A: usize>;
impl<const A: usize> Foo<A> {
    const SIZE: usize = { todo!() };
    fn to_bytes() -> [u8; gca!(Self::SIZE)] { todo!() }
}
fn main() {}
