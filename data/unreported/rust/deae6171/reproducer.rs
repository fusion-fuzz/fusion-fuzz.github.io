#![feature(generic_const_exprs)]
#![allow(incomplete_features)]
#![cfg_attr(full, feature(generic_const_exprs))]
#![cfg_attr(full, allow(incomplete_features))]


// Seed A (non-inlined items)
//@ revisions: rpass

fn test<const SIZE: usize>() {}



trait SomeTrait {
    const SIZE: usize;
}


//@ revisions: full min

struct Foo<T, U = [u8; std::mem::size_of::<T>()]>(T, U);


//[min]~^ ERROR generic parameters may not be used in const operations


struct A<'a, T> {
    some_ref: &'a str,
    _maker: core::marker::PhantomData<T>,
}



impl<'a, T: SomeTrait> A<'a, T>
where
    [(); T::SIZE]: ,
{
    fn call_test() {
        test::<{ T::SIZE }>();
    }
}



fn main_7ead9673() {}


struct Bar<T = [u8; N], const N: usize>(T);


//~^ ERROR generic parameter defaults cannot reference parameters before they are declared
//~| ERROR generic parameters with a default

fn main_54651bb0() {
//[min]~^ ERROR generic parameters may not be used in const operations

struct Bar_b54651b<T = [u8; N], const N: usize>(T);
//@ revisions: full min

struct Foo_b54651bb0<T, U = [u8; std::mem::size_of::<T>()]>(T, U);

}




// Seed B (non-inlined items)
//@ revisions: full min

struct Foo_b54651b<T, U = [u8; std::mem::size_of::<T>()]>(T, U);




//~^ ERROR generic parameter defaults cannot reference parameters before they are declared
//~| ERROR generic parameters with a default

fn main_54651bb0_b54651b() {}



fn main() {

    println!("FFL Fusion Done");
}


//[min]~^ ERROR generic parameters may not be used in const operations

struct Bar_b54651bb0<T = [u8; N], const N: usize>(T);


//~^ ERROR generic parameter defaults cannot reference parameters before they are declared
//~| ERROR generic parameters with a default

fn main_54651bb02() {}
impl SomeTrait for Bar_b54651bb0 {
const SIZE: usize = 0;
}
