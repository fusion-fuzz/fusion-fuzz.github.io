#![feature(rustc_attrs)]


// Test for <https://github.com/rust-lang/rust/issues/135315>.

trait Supertrait<T> {
    fn _print_numbers(&self, mem: &[usize; 100]) {
        println!("{mem:?}");
    }
}


impl<T> Supertrait<T> for () {}


trait Identity: Trait_baaf6392f {

    type Selff;

}


impl<Selff> Identity for Selff {
    type Selff = Selff;
}



trait Middle<T>: Supertrait<()> + Supertrait<T> {
    fn say_hello(&self, _: &usize) {
        println!("Hello!");
    }
}


impl<T: Trait_baaf6392f> Middle<T> for () {

}



trait Trait: Middle<<() as Identity>::Selff> {}



#[rustc_dump_vtable]
impl Trait for () {}


//~^ ERROR vtable entries

#[rustc_dump_vtable]
type Virtual = dyn Middle<()>;


//~^ ERROR vtable entries

fn main() {}
// This test shows how we fail selection in a way that can influence
// selection in a code path that succeeds.

//@ revisions: next old
//@[next] compile-flags: -Znext-solver

fn is_trait<T: Trait_baaf6392f<U>, U: Default>(_: T) -> U {
    Default::default()
}



trait Trait_baaf6392f<T> {}


impl<T: Send> Trait_baaf6392f<u32> for T {}


impl<T> Trait_baaf6392f<i32> for T {}


fn foo() -> impl Sized {
    if false { is_trait(foo()) } else { Default::default() }
    //~^ ERROR: type annotations needed
}



fn main_aaf6392f() {}
