#![crate_type = "lib"]
#![feature(no_core, lang_items)]
#![no_core]
use std::mem::{size_of, size_of_val};


// Seed A (non-inlined items)
// Regression test for #155344.
// Borrowck diagnostics should not ICE when describing a field access on a generic parameter.

//@ edition: 2024


#[lang = "pointee_sized"]
pub trait PointeeSized {}

#[lang = "meta_sized"]
pub trait MetaSized: PointeeSized {}
//@ run-pass
// Test that fn item types are zero-sized.


fn main_339b8270() {
    assert_eq!(size_of_val(&main), 0);

    let (a, b) = (size_of::<u8>, size_of::<u16>);
    assert_eq!(size_of_val(&a), 0);
    assert_eq!(size_of_val(&b), 0);
    assert_eq!((a(), b()), (1, 2));
}

#[lang = "sized"]
pub trait Sized: MetaSized {}

#[lang = "legacy_receiver"]
pub trait LegacyReceiver {}

impl<T: PointeeSized> LegacyReceiver for &T {}
impl<T: PointeeSized> LegacyReceiver for &mut T {}

#[lang = "copy"]
pub trait Copy {}

impl Copy for *mut () {}

#[lang = "drop"]
pub trait Drop {
    fn drop(&mut self);
}

unsafe extern "C" {
    fn free(_: *mut ());
}

unsafe fn transmute<T, U>(_: T) -> U {
    loop {}
}

#[repr(transparent)]
pub struct NonNull<T: ?Sized>(pub *const T);

#[lang = "owned_box"]
pub struct Box<T: ?Sized, A = ()>(NonNull<T>, A);

impl<T: ?Sized, A> Drop for Box<T, A> {
    fn drop(&mut self) {
        unsafe {
            free(transmute::<NonNull<T>, *mut _>(self.0));
            //~^ ERROR cannot move out of `self.0` which is behind a mutable reference
        }
    }
}

// Seed B (non-inlined items)
//@ run-pass
// Test that fn item types are zero-sized.




fn main_d0c45740() {
assert_eq!(size_of_val(&main), 0);
let (a, b) = (size_of::<u8>, size_of::<u16>);
assert_eq!(size_of_val(&a), 0);
assert_eq!(size_of_val(&b), 0);
assert_eq!((a(), b()), (1, 2));
    println!("FFL Fusion Done");
}
fn main() {}
