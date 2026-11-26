#![feature(no_core, lang_items)]
#![no_core]
#![crate_type = "lib"]

// Seed A (non-inlined items)
// Regression test for #87573, ensures that duplicate lang items or invalid generics
// for lang items doesn't cause ICE.


pub static STATIC_BOOL: bool = true;

#[lang = "pointee_sized"]
pub trait PointeeSized {}

#[lang = "meta_sized"]
pub trait MetaSized: PointeeSized {}

#[lang = "sized"]
trait Sized: MetaSized {}

#[lang = "copy"]
//@ compile-flags: -Znext-solver
//@ check-pass

// A regression test for https://github.com/rust-lang/trait-system-refactor-initiative/issues/252.
// `fn fudge_inference_if_ok` might lose relationships between ty vars so we need to make sure
// there'll be no ambiguous aliases referencing infer vars from inside of the fudge scope.

trait Trait {
    type Assoc;
}
impl<T: Trait> Trait for W<T> {
    type Assoc = T::Assoc;
}
impl Trait for i32 {
    type Assoc = i32;
}

struct W<T>(T);
fn foo<T: Trait>(_: <T as Trait>::Assoc) -> T {
    todo!()
}

fn main_a3350252() {
    let x: W<_> = foo(1);
    let _: W<i32> = x;
}
trait Copy {}

#[lang = "sync"]
trait Sync {}
impl Sync for bool {}

#[lang = "drop_glue"]
//~^ ERROR: `drop_glue` lang item must be applied to a function with 1 generic argument
fn drop_fn() {
    while false {}
}

#[lang = "start"]
//~^ ERROR: `start` lang item must be applied to a function with 1 generic argument
fn start() {}


// Seed B (non-inlined items)
//@ compile-flags: -Znext-solver
//@ check-pass

// A regression test for https://github.com/rust-lang/trait-system-refactor-initiative/issues/252.
// `fn fudge_inference_if_ok` might lose relationships between ty vars so we need to make sure
// there'll be no ambiguous aliases referencing infer vars from inside of the fudge scope.

trait Trait_ba33502 {
    type Assoc;
}
impl<T: Trait_ba33502> Trait_ba33502 for W_ba33502<T> {
    type Assoc = T::Assoc;
}
impl Trait_ba33502 for i32 {
    type Assoc = i32;
}

struct W_ba33502<T>(T);
fn foo_ba33502<T: Trait_ba33502>(_: <T as Trait_ba33502>::Assoc) -> T {
    todo!()
}

fn main_a3350252_ba33502() {
    let x: W_ba33502<_> = foo_ba33502(1);
    let _: W_ba33502<i32> = x;
}

fn main() {

    println!("FFL Fusion Done");
}
