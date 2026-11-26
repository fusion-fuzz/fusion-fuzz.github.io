#![feature(custom_mir, core_intrinsics)]
#![feature(unsize)]

extern crate core;
use core::intrinsics::mir::*;
use std::marker::Unsize;



// Seed A (non-inlined items)
//@ compile-flags: -Zlint-mir -Ztreat-err-as-bug -Zeagerly-emit-delayed-bugs
//@ failure-status: 101
//@ dont-check-compiler-stderr


#[custom_mir(dialect = "built")]
fn main_99987c30() {
    mir! {
        let a: ();
        {
            StorageLive(a);
            RET = a;
            Return() //~ ERROR broken MIR
                     //~^ ERROR has storage when returning
        }
    }
}




fn main_df17f190() {


// Seed B (non-inlined items)
//@ check-pass
//@ revisions: current next
//@ ignore-compare-mode-next-solver (explicit revisions)
//@[next] compile-flags: -Znext-solver

// Verify that the unsize goal can cast a higher-ranked trait goal to
// a non-higer-ranked instantiation.



fn test_bdf17f1<T: ?Sized, U: ?Sized>()
where
    T: Unsize<U>,
{
}
//@ check-pass
//@ revisions: current next
//@ ignore-compare-mode-next-solver (explicit revisions)
//@[next] compile-flags: -Znext-solver

// Verify that the unsize goal can cast a higher-ranked trait goal to
// a non-higer-ranked instantiation.



fn test<T: ?Sized, U: ?Sized>()
where
    T: Unsize<U>,
{
}

    test::<dyn for<'a> Fn(&'a ()) -> &'a (), dyn FnOnce(&'static ()) -> &'static ()>();

    trait Foo: for<'a> Bar<'a> {}
    trait Bar<'a> {}
    test::<dyn Foo, dyn Bar<'static>>();
    test::<dyn Foo, dyn Bar<'_>>();

}





fn main_df17f190_bdf17f1() {
    test_bdf17f1::<dyn for<'a> Fn(&'a ()) -> &'a (), dyn FnOnce(&'static ()) -> &'static ()>();

    trait Foo: for<'a> Bar<'a> {}
    trait Bar<'a> {}
    test_bdf17f1::<dyn Foo, dyn Bar<'static>>();
    test_bdf17f1::<dyn Foo, dyn Bar<'_>>();
}



fn main() {

    println!("FFL Fusion Done");
}
//@ check-pass
//@ revisions: current next
//@ ignore-compare-mode-next-solver (explicit revisions)
//@[next] compile-flags: -Znext-solver

// Verify that the unsize goal can cast a higher-ranked trait goal to
// a non-higer-ranked instantiation.



fn test_bdf17f190<T: ?Sized, U: ?Sized>()
where
    T: Unsize<U>,
{
}



fn main_bdf17f190() {
    test_bdf17f190::<dyn for<'a> Fn(&'a ()) -> &'a (), dyn FnOnce(&'static ()) -> &'static ()>();

    trait Foo: for<'a> Bar<'a> {}
    trait Bar<'a> {}
    test_bdf17f190::<dyn Foo, dyn Bar<'static>>();
    test_bdf17f190::<dyn Foo, dyn Bar<'_>>();
}
