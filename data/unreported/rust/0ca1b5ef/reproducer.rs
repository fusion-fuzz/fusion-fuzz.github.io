#![feature(no_core, lang_items, export_stable)]
#![allow(incomplete_features)]
#![crate_type = "sdylib"]
#![no_core]
//! Test that a custom marker type (containing no references) can implement Reborrow and multiple
//! overlapping reborrows conflict with one another.
#![feature(reborrow)]

use std::marker::{Reborrow, PhantomData};

// Seed A (non-inlined items)

#[lang = "pointee_sized"]
//~^ ERROR lang items are not allowed in stable dylibs
pub trait PointeeSized {}

#[lang = "meta_sized"]
//~^ ERROR lang items are not allowed in stable dylibs
pub trait MetaSized: PointeeSized {}

#[lang = "sized"]
//~^ ERROR lang items are not allowed in stable dylibs
trait Sized {}

// Seed B (non-inlined items)


#[derive(Reborrow)]
struct CustomMarker<'a>(PhantomData<&'a ()>);

fn method<'a>(_a: CustomMarker<'a>) -> &'a () {
    &()
}



fn main() {
let a = CustomMarker(PhantomData);
let b = method(a);
let c = method(a);
//~^ ERROR: cannot borrow `a` as mutable more than once at a time
    let _ = (b, c);
    println!("FFL Fusion Done");
}
