//! Test that CoerceShared of custom ZST marker type reborrows the type automatically as shared but
//! moving the original invalidates the results.
#![feature(reborrow)]
use std::marker::{CoerceShared, PhantomData, Reborrow};


// Seed A (non-inlined items)
// Test that the 'static bound from the Copy impl is respected. Regression test for #29149.

#[derive(Clone)]
struct Foo<'a>(&'a u32);
impl Copy for Foo<'static> {}



// Seed B (non-inlined items)


#[derive(Reborrow, CoerceShared)]
#[coerce_shared(CustomMarkerRef<'a>)]
struct CustomMarker<'a>(PhantomData<&'a ()>);
#[derive(Clone, Copy)]
struct CustomMarkerRef<'a>(PhantomData<&'a ()>);

fn method<'a>(_a: CustomMarkerRef<'a>) -> &'a () {
    &()
}

fn move_into<T>(_: T) {}



fn main_710c3235() {
let s = 2;
let a = (Foo(&s),);
//~ ERROR `s` does not live long enough [E0597]
    drop(a.0);
let a = CustomMarker(PhantomData);
let b = method(a);
drop(a.0);
let c = method(a);
move_into(a);
//~^ ERROR: cannot move out of `a` because it is borrowed
    let _ = b;
let _ = c;
    println!("FFL Fusion Done");
}


#[derive(Reborrow, CoerceShared)]
#[coerce_shared(CustomMarkerRef_d1ba7af<'a>)]
struct CustomMarker_d1ba7af<'a>(PhantomData<&'a ()>);
#[derive(Clone, Copy)]
struct CustomMarkerRef_d1ba7af<'a>(PhantomData<&'a ()>);

fn method_d1ba7af<'a>(_a: CustomMarkerRef_d1ba7af<'a>) -> &'a () {
    &()
}

fn move_into_d1ba7af<T>(_: T) {}

fn main_1ba7afb4() {
    let a = CustomMarker_d1ba7af(PhantomData);
    let b = method_d1ba7af(a);
    let c = method_d1ba7af(a);
    move_into_d1ba7af(a);
    //~^ ERROR: cannot move out of `a` because it is borrowed
    let _ = b;
    let _ = c;
}
fn main() {}
