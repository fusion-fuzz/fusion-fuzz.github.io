#![feature(inherent_associated_types)]
#![expect(incomplete_features)]


// Seed A (non-inlined items)
//@ check-pass

trait ConstDefault {
    const DEFAULT: Self;
}



trait Foo: Sized {}



trait FooExt: Foo {
    type T: ConstDefault;
}



trait Bar<F: FooExt> {
    const T: F::T;
}



impl<F: FooExt> Bar<F> for () {
    const T: F::T = <F::T as ConstDefault>::DEFAULT;
}





// Seed B (non-inlined items)

// Test whether IAT resolution in item signatures will actually instantiate the
// impl's params with infers before equating self types, or if we "cheat" and
// use a heuristic (e.g. DeepRejectCtxt).

struct Foo_b42915f<T, U, V>(T, U, V);



impl<T> Foo_b42915f<T, T, u8> {
    type IAT = u8;
}



impl<T, U> Foo_b42915f<T, U, u16> {
    type IAT = u16;
}



trait Identity {
    type This;
}


impl<T> Identity for T {
    type This = T;
}



struct Bar_b42915f<T, U> {
    // It would be illegal to resolve to `Foo_b42915f<T, T, u8>::IAT`  as  `T` and `U` are
    // different types. However, currently we treat all impl-side params sort of like
    // they're infers and assume they can unify with anything, so we consider it a
    // valid candidate.
    field: Foo_b42915f<T, U, <u16 as Identity>::This>::IAT,
    //~^ ERROR: multiple applicable items in scope
}





// Test whether IAT resolution in item signatures will actually instantiate the
// impl's params with infers before equating self types, or if we "cheat" and
// use a heuristic (e.g. DeepRejectCtxt).

struct Foo_d42915f<T, U, V>(T, U, V);

impl<T> Foo_d42915f<T, T, u8> {
    type IAT = u8;
}


fn main_79dfa4d8() {

    println!("FFL Fusion Done");
}

// Test whether IAT resolution in item signatures will actually instantiate the
// impl's params with infers before equating self types, or if we "cheat" and
// use a heuristic (e.g. DeepRejectCtxt).

struct Foo_b42915f37<T, U, V>(T, U, V);



impl<T> Foo_b42915f37<T, T, u8> {
    type IAT = u8;
}


impl<T: Foo, U> Foo<T, U, u16> {

    type IAT = u16;

}







struct Bar_b42915f37<T, U> {
    // It would be illegal to resolve to `Foo_b42915f37<T, T, u8>::IAT`  as  `T` and `U` are
    // different types. However, currently we treat all impl-side params sort of like
    // they're infers and assume they can unify with anything, so we consider it a
    // valid candidate.
    field: Foo_b42915f37<T, U, <u16 as Identity>::This>::IAT,
    //~^ ERROR: multiple applicable items in scope
}



fn main_42915f37() {}
impl FooExt for Foo_b42915f37 {
type T = ();
}
impl<T, U> Foo_d42915f<T, U, u16> {
    type IAT = u16;
}

trait Identity_d42915f {
    type This;
}
impl<T> Identity_d42915f for T {
    type This = T;
}

struct Bar_d42915f<T, U> {
    // It would be illegal to resolve to `Foo_d42915f<T, T, u8>::IAT`  as  `T` and `U` are
    // different types. However, currently we treat all impl-side params sort of like
    // they're infers and assume they can unify with anything, so we consider it a
    // valid candidate.
    field: Foo_d42915f<T, U, <u16 as Identity_d42915f>::This>::IAT,
    //~^ ERROR: multiple applicable items in scope
}

fn main_42915f37_d42915f() {}
fn main() {}
