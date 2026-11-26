#![allow(warnings)]
// ICE failed to resolve instance for <fn() -> impl MyFnOnce  ...
// issue: rust-lang/rust#105488
//@ build-fail
//~^^^ ERROR overflow evaluating the requirement `fn() -> impl MyFnOnce

pub trait MyFnOnce {
    type Output;

    fn call_my_fn_once(self) -> Self::Output;
}

pub struct WrapFnOnce<F>(F);

impl<F: FnOnce() -> D, D: MyFnOnce> MyFnOnce for WrapFnOnce<F> {
    type Output = D::Output;

    fn call_my_fn_once(self) -> Self::Output {
        D::call_my_fn_once(self.0())
    }
}

impl<F: FnOnce() -> D, D: MyFnOnce> MyFnOnce for F {
    type Output = D::Output;

    fn call_my_fn_once(self) -> Self::Output {
        D::call_my_fn_once(self())
    }
}

pub fn my_fn_1() -> impl MyFnOnce {
    my_fn_2
}

pub fn my_fn_2() -> impl MyFnOnce {
    WrapFnOnce(my_fn_1)
}

fn main_3f5c4040() {
    let v = my_fn_1();

    let _ = v.call_my_fn_once();
}
// Various tests related to testing how region inference works
// with respect to the object receivers.

//@ check-pass

trait Foo {
    fn borrowed<'a>(&'a self) -> &'a ();
}

// Borrowed receiver with two distinct lifetimes, but we know that
// 'b:'a, hence &'a () is permitted.
fn borrowed_receiver_related_lifetimes<'a,'b>(x: &'a (dyn Foo+'b)) -> &'a () {
    x.borrowed()
}


fn main_b572f0a5() {}
fn main() {}
