#![crate_type="lib"]
#![feature(no_core)]
#![no_core]
//@ edition:2015
// Regression test for the ICE reported in issue #83471.


#[lang = "pointee_sized"]
//~^ ERROR: lang items are subject to change [E0658]
pub trait PointeeSized {}

#[lang = "meta_sized"]
//~^ ERROR: lang items are subject to change [E0658]
pub trait MetaSized: PointeeSized {}

#[lang = "sized"]
trait Tr {
    type Assoc;
}

struct W<'a>(&'a ());

impl Tr for W<'_> {
    type Assoc = ();
}

// The normal way of capturing `'a`...
impl<'a> W<'a> {
    fn good1() -> impl Into<<W<'a> as Tr>::Assoc> + use<'a> {}
}

// This ensures that we don't error when we capture the *parent* copy of `'a`,
// since the opaque captures that rather than the duplicated `'a` lifetime
// synthesized from mentioning `'a` directly in the bounds.
impl<'a> W<'a> {
    fn good2() -> impl Into<<Self as Tr>::Assoc> + use<'a> {}
}

//~^ ERROR: lang items are subject to change [E0658]
trait Sized: MetaSized {}

#[lang = "fn"]
//~^ ERROR: lang items are subject to change [E0658]
//~| ERROR: `fn` lang item must be applied to a trait with 1 generic argument
trait Fn {
    fn call(export_name);
    //~^ ERROR: cannot find type `export_name` in this scope
    //~| WARNING: anonymous parameters are deprecated
    //~| WARNING: this is accepted in the current edition
}
fn call_through_fn_trait() {
    a()
    //~^ ERROR: cannot find function
}
// The normal way of capturing `'a`... but not mentioned in the bounds.
impl<'a> W<'a> {
    fn bad1() -> impl Into<<W<'a> as Tr>::Assoc> + use<> {}
    //~^ ERROR `impl Trait` captures lifetime parameter, but it is not mentioned in `use<...>` precise captures list
}

// But also make sure that we error here...
impl<'a> W<'a> {
    fn bad2() -> impl Into<<Self as Tr>::Assoc> + use<> {}
    //~^ ERROR `impl Trait` captures lifetime parameter, but it is not mentioned in `use<...>` precise captures list
}

fn main_5b29511b() {}
fn main() {}
