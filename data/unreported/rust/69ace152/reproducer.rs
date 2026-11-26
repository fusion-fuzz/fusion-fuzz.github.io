//! Test using `#[rustc_splat]` on tuple arguments of pointers to generic functions.
#![expect(incomplete_features)]
#![feature(splat, tuple_trait)]
#![feature(rustc_attrs)]

use std::fmt::Debug;
use std::marker::Tuple;

// Seed A (non-inlined items)
//@ run-pass



fn generic<T: Tuple + Debug>(#[rustc_splat] a: T) -> String {
    format!("{a:?}")
}

// FIXME(rustfmt): the attribute gets deleted by rustfmt
#[rustfmt::skip]
fn main_0d8031cf() {
    let fn_ptr: fn(#[rustc_splat] (u32, i8)) -> String
        = generic as fn(#[rustc_splat] (u32, i8)) -> String;
    assert_eq!(fn_ptr(1, -2), "(1, -2)");
    assert_eq!(fn_ptr(1u32, -2i8), "(1, -2)");

    let fn_ptr: fn(#[rustc_splat] (u32, i8)) -> String
        = generic::<(u32, i8)> as fn(#[rustc_splat] (u32, i8)) -> String;
    assert_eq!(fn_ptr(1, -2), "(1, -2)");
    assert_eq!(fn_ptr(1u32, -2i8), "(1, -2)");

    let fn_ptr = generic as fn(#[rustc_splat] (u32, i8)) -> String;
    assert_eq!(fn_ptr(1, -2), "(1, -2)");
    assert_eq!(fn_ptr(1u32, -2i8), "(1, -2)");

    let fn_ptr = generic::<(u32, i8)> as fn(#[rustc_splat] (u32, i8)) -> String;
    assert_eq!(fn_ptr(1, -2), "(1, -2)");
    assert_eq!(fn_ptr(1u32, -2i8), "(1, -2)");

    let fn_ptr: fn(#[rustc_splat] (u32, i8)) -> String = generic as _;
    assert_eq!(fn_ptr(1, -2), "(1, -2)");
    assert_eq!(fn_ptr(1u32, -2i8), "(1, -2)");

    let fn_ptr: fn(#[rustc_splat] (u32, i8)) -> String = generic::<(u32, i8)> as _;
    assert_eq!(fn_ptr(1, -2), "(1, -2)");
    assert_eq!(fn_ptr(1u32, -2i8), "(1, -2)");

    // Now without explicit `as`, this requires turbofish
    let fn_ptr: fn(#[rustc_splat] (f64, i8)) -> String = generic::<(f64, i8)>;
    assert_eq!(fn_ptr(3.5, -2), "(3.5, -2)");
    assert_eq!(fn_ptr(3.5f64, -2i8), "(3.5, -2)");

    // FIXME(unused_variables): This is obviously used
    #[expect(unused_variables)]
    let fn_ptr = generic;
    assert_eq!(fn_ptr(-1, 2, 3.5), "(-1, 2, 3.5)");
    assert_eq!(fn_ptr(-1i8, 2u32, 3.5f64), "(-1, 2, 3.5)");

    #[expect(unused_variables)]
    let fn_ptr = generic::<(i8, u32, f64)>;
    assert_eq!(fn_ptr(-1, 2, 3.5), "(-1, 2, 3.5)");
    assert_eq!(fn_ptr(-1i8, 2u32, 3.5f64), "(-1, 2, 3.5)");
}

#[rustc_skip_during_method_dispatch]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input [E0539]
trait NotAList {}

#[rustc_skip_during_method_dispatch = "array"]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input [E0539]
trait AlsoNotAList {}

#[rustc_skip_during_method_dispatch()]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait Argless {}

#[rustc_skip_during_method_dispatch(array, boxed_slice, array)]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait Duplicate {}

#[rustc_skip_during_method_dispatch(slice)]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait Unexpected {}

#[rustc_skip_during_method_dispatch(array = true)]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait KeyValue {}

#[rustc_skip_during_method_dispatch("array")]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait String {}

#[rustc_skip_during_method_dispatch(array, boxed_slice)]
trait OK {}

#[rustc_skip_during_method_dispatch(array)]
//~^ ERROR: attribute cannot be used on
impl OK for () {}

fn main_038c6710() {}


// Seed B (non-inlined items)

#[rustc_skip_during_method_dispatch]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input [E0539]
trait NotAList_b038c67 {}

#[rustc_skip_during_method_dispatch = "array"]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input [E0539]
trait AlsoNotAList_b038c67 {}

#[rustc_skip_during_method_dispatch()]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait Argless_b038c67 {}

#[rustc_skip_during_method_dispatch(array, boxed_slice, array)]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait Duplicate_b038c67 {}

#[rustc_skip_during_method_dispatch(slice)]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait Unexpected_b038c67 {}

#[rustc_skip_during_method_dispatch(array = true)]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait KeyValue_b038c67 {}

#[rustc_skip_during_method_dispatch("array")]
//~^ ERROR: malformed `rustc_skip_during_method_dispatch` attribute input
trait String_b038c67 {}

#[rustc_skip_during_method_dispatch(array, boxed_slice)]
trait OK_b038c67 {}

#[rustc_skip_during_method_dispatch(array)]
//~^ ERROR: attribute cannot be used on
impl OK_b038c67 for () {}

fn main_038c6710_b038c67() {}

fn main() {

    println!("FFL Fusion Done");
}
