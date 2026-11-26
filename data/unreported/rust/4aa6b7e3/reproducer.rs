#![crate_type = "lib"]
#![feature(no_core, lang_items)]
#![no_core]
#![feature(const_trait_impl)]
//@ revisions: BADFLAGS BADFLAGSPC BADTARGET
//@ [BADFLAGS] compile-flags: --target=aarch64-unknown-linux-gnu -Zbranch-protection=leaf
//@ [BADFLAGS] check-fail
//@ [BADFLAGS] needs-llvm-components: aarch64
//@ [BADFLAGSPC] compile-flags: --target=aarch64-unknown-linux-gnu -Zbranch-protection=pc
//@ [BADFLAGSPC] check-fail
//@ [BADFLAGSPC] needs-llvm-components: aarch64
//@ [BADTARGET] compile-flags: --target=x86_64-unknown-linux-gnu -Zbranch-protection=bti
//@ [BADTARGET] check-fail
//@ [BADTARGET] needs-llvm-components: x86


#[lang = "pointee_sized"]
pub trait PointeeSized {}

#[lang = "meta_sized"]
pub trait MetaSized: PointeeSized {}

#[lang = "sized"]
//@ check-pass


const trait Foo {}

const impl<T> Foo for (T,) where T: [const] Foo {}

const fn needs_const_foo(_: impl [const] Foo + Copy) {}

const fn test<T: [const] Foo + Copy>(t: T) {
    needs_const_foo((t,));
}

pub trait Sized: MetaSized {}

//[BADFLAGS]~? ERROR incorrect value `leaf` for unstable option `branch-protection`
//[BADFLAGSPC]~? ERROR incorrect value `pc` for unstable option `branch-protection`
//[BADTARGET]~? ERROR `-Zbranch-protection` is only supported on aarch64
fn main_97e50932() {}
fn main() {}
