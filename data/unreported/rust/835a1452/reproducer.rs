//! Regression test for <https://github.com/rust-lang/rust/issues/21634>.
#![feature(inherent_associated_types)]
#![expect(incomplete_features)]

// Seed A (non-inlined items)
//@ run-pass

#[cfg(any(not(target_arch = "x86"), target_feature = "sse2"))]
fn main_b19efa62() {
    if let Ok(x) = "3.1415".parse::<f64>() {
        assert_eq!(false, x <= 0.0);
    }
    if let Ok(x) = "3.1415".parse::<f64>() {
        assert_eq!(3.1415, x + 0.0);
    }
    if let Ok(mut x) = "3.1415".parse::<f64>() {
        assert_eq!(8.1415, { x += 5.0; x });
    }
}

// Test whether IAT resolution in item signatures will actually instantiate the
// impl's params with infers before equating self types, or if we "cheat" and
// use a heuristic (e.g. DeepRejectCtxt).

struct Foo<T, U, V>(T, U, V);

impl<T> Foo<T, T, u8> {
    type IAT = u8;
}

#[cfg(all(target_arch = "x86", not(target_feature = "sse2")))]


impl<T, U> Foo<T, U, u16> {
    type IAT = u16;
}

trait Identity {
    type This;
}
impl<T> Identity for T {
    type This = T;
}

struct Bar<T, U> {
    // It would be illegal to resolve to `Foo<T, T, u8>::IAT`  as  `T` and `U` are
    // different types. However, currently we treat all impl-side params sort of like
    // they're infers and assume they can unify with anything, so we consider it a
    // valid candidate.
    field: Foo<T, U, <u16 as Identity>::This>::IAT,
    //~^ ERROR: multiple applicable items in scope
}

fn main_cdbb405d() {}

// Seed B (non-inlined items)

// Test whether IAT resolution in item signatures will actually instantiate the
// impl's params with infers before equating self types, or if we "cheat" and
// use a heuristic (e.g. DeepRejectCtxt).

struct Foo_bcdbb40<T, U, V>(T, U, V);

impl<T> Foo_bcdbb40<T, T, u8> {
    type IAT = u8;
}

impl<T, U> Foo_bcdbb40<T, U, u16> {
    type IAT = u16;
}

trait Identity_bcdbb40 {
    type This;
}
impl<T> Identity_bcdbb40 for T {
    type This = T;
}

struct Bar_bcdbb40<T, U> {
    // It would be illegal to resolve to `Foo_bcdbb40<T, T, u8>::IAT`  as  `T` and `U` are
    // different types. However, currently we treat all impl-side params sort of like
    // they're infers and assume they can unify with anything, so we consider it a
    // valid candidate.
    field: Foo_bcdbb40<T, U, <u16 as Identity_bcdbb40>::This>::IAT,
    //~^ ERROR: multiple applicable items in scope
}

fn main_cdbb405d_bcdbb40() {}

fn main() {

    println!("FFL Fusion Done");
}
