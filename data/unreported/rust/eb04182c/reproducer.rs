#![feature(lang_items)]
#![feature(no_core)]
#![no_core]
#![no_main]
use std::mem::size_of;
//@ compile-flags:-C panic=abort


#[panic_handler]
fn panic() -> ! {
    //~^ ERROR requires `panic_info` lang_item
    loop {}
}

#[lang = "pointee_sized"]
//@ run-pass


// The main point of this test is to ensure that we can parse and resolve
// associated items on associated types.

trait Foo {
    type U;
}

trait Bar {
    // Note 1: Chains of associated items in a path won't type-check.
    // Note 2: Associated consts can't depend on type parameters or `Self`,
    // which are the only types that an associated type can be referenced on for
    // now, so we can only test methods.
    fn method() -> u32;
    fn generic_method<T>() -> usize;
}

struct MyFoo;
struct MyBar;

impl Foo for MyFoo {
    type U = MyBar;
}
pub trait PointeeSized {}

#[lang = "meta_sized"]
pub trait MetaSized: PointeeSized {}

#[lang = "sized"]
trait Sized: MetaSized {}

impl Bar for MyBar {
    fn method() -> u32 {
        2u32
    }
    fn generic_method<T>() -> usize {
        size_of::<T>()
    }
}

fn foo<T>()
    where T: Foo,
          T::U: Bar,
{
    assert_eq!(2u32, <T as Foo>::U::method());
    assert_eq!(8usize, <T as Foo>::U::generic_method::<f64>());
}

fn main_2c779f5e() {
    foo::<MyFoo>();
}
fn main() {}
