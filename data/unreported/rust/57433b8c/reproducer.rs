#![feature(reborrow, generic_const_exprs)]
#![allow(incomplete_features)]
use std::marker::{CoerceShared, Reborrow};

struct MyMut<'a>(&'a u8);
impl Reborrow for MyMut<'_> {}

#[derive(Clone, Copy)]
struct MyRef<'a>(&'a u8);
impl<'a> CoerceShared<MyRef<'a>> for MyMut<'a> {}

fn main() {
    const {
        let v = 1;
        let _x: MyRef<'_> = MyMut(&v);
    };
}
