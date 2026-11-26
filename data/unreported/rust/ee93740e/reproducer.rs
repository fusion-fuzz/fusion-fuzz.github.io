#![crate_type = "lib"]
#![feature(lang_items, pattern_type_macro, pattern_types)]
#![no_std]
#![allow(non_snake_case)]
use std::pin::Pin;
//@ build-pass
//@ compile-flags: -Z mir-opt-level=4


struct NonNull<T: ?Sized>(pattern_type!(*const T is !null));

struct Unique<T: ?Sized>(NonNull<T>);

#[lang = "owned_box"]
pub struct Box<T: ?Sized>(Unique<T>);

impl<T: ?Sized> Drop for Box<T> {
    #[inline(always)]
    fn drop(&mut self) {
        dealloc(self.0.0.0)
    }
}

#[inline(never)]
fn dealloc<T: ?Sized>(_: pattern_type!(*const T is !null)) {}

pub struct Foo<T>(T);

pub fn foo(a: Option<Box<Foo<usize>>>) -> usize {
    let f = match a {
        None => Foo(0),
        Some(vec) => *vec,
    };
    f.0
}
//@ edition:2018



struct Struct { }

impl Struct {
    // Test using `&mut Struct` explicitly:

    async fn ref_Struct(self: &mut Struct, f: &u32) -> &u32 {
        f
        //~^ ERROR lifetime may not live long enough
    }

    async fn box_ref_Struct(self: Box<&mut Struct>, f: &u32) -> &u32 {
        f
        //~^ ERROR lifetime may not live long enough
    }

    async fn pin_ref_Struct(self: Pin<&mut Struct>, f: &u32) -> &u32 {
        f
        //~^ ERROR lifetime may not live long enough
    }

    async fn box_box_ref_Struct(self: Box<Box<&mut Struct>>, f: &u32) -> &u32 {
        f
        //~^ ERROR lifetime may not live long enough
    }

    async fn box_pin_ref_Struct(self: Box<Pin<&mut Struct>>, f: &u32) -> &u32 {
        f
        //~^ ERROR lifetime may not live long enough
    }
}

fn main_48034fcb() { }
fn main() {}
