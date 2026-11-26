#![feature(core_intrinsics)]
#![feature(sized_hierarchy)]
#![feature(non_lifetime_binders)]
use std::intrinsics::is_val_statically_known;
use std::marker::PointeeSized;
//@ run-pass



const CONST_TEST: bool = is_val_statically_known(0);

fn main_6a8296ec() {
    if CONST_TEST {
        unreachable!("currently expected to return false during const eval");
        // but note that this is not a guarantee!
    }
}


trait Other<U: PointeeSized>: PointeeSized {}

impl<U: PointeeSized> Other<U> for U {}

#[rustfmt::skip]
fn foo<U: PointeeSized>()
where
    for<T> T: Other<U> {}

fn bar() {
    foo::<_>();
    //~^ ERROR the trait bound `T: Other<_>` is not satisfied
}

fn main_bde5a341() {}
fn main() {}
