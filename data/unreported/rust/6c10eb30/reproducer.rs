#![feature(type_alias_impl_trait)]

// Seed A (non-inlined items)

fn take(_x: Box<isize>) {

fn test<A>()
where
    Ty<A>: 'static,
{
    assert_static::<A>()
    //~^ ERROR: the parameter type `A` may not live long enough
}

fn main_11eb2418() {}

}






pub type Ty<A> = impl Sized + 'static;


#[define_opaque(Ty)]
fn defining<A: 'static>(s: A) -> Ty<A> {
    s
    //~^ ERROR: the parameter type `A` may not live long enough
}


pub fn assert_static<A: 'static>() {}




// Seed B (non-inlined items)

pub type Ty_b11eb24<A> = impl Sized + 'static;
#[define_opaque(Ty_b11eb24)]
fn defining_b11eb24<A: 'static>(s: A) -> Ty_b11eb24<A> {
    s
    //~^ ERROR: the parameter type `A` may not live long enough
}
pub fn assert_static_b11eb24<A: 'static>() {}

fn test_b11eb24<A>()
where
    Ty_b11eb24<A>: 'static,
{
    assert_static_b11eb24::<A>()
    //~^ ERROR: the parameter type `A` may not live long enough
}

fn main_11eb2418_b11eb24() {}

fn main() {
let x: Box<isize> = Box::new(25);
loop {
        'ffl_d43db10f_take_1: {
let _x: Box<isize> = x;


fn test<A>()
where
    Ty<A>: 'static,
{
    assert_static::<A>()
    //~^ ERROR: the parameter type `A` may not live long enough
}

fn main_11eb2418() {}


}; //~ ERROR use of moved value: `x`
    }
    println!("FFL Fusion Done");
}
