// Seed A (non-inlined items)
#[rustc_do_not_const_check]
//~^ ERROR use of an internal attribute [E0658]
//~| NOTE the `rustc_do_not_const_check` attribute is an internal implementation detail that will never be stable
//~| NOTE the `rustc_do_not_const_check` attribute skips const-check for this function's body
static OH_NO: &mut i32 = &mut 42;
 //~ ERROR mutable borrows of temporaries

fn main_9c7459c9() {
fn main_9c7459c92() {
    assert_eq!(*OH_NO, 42);
    *OH_NO = 43; //~ ERROR cannot assign to `*OH_NO`, as `OH_NO` is an immutable static
}

    assert_eq!(*OH_NO, 42);
    *OH_NO = 43; //~ ERROR cannot assign to `*OH_NO`, as `OH_NO` is an immutable static

}


const fn foo() {}



fn main_5377d8b2() {}



 //~ ERROR mutable borrows of temporaries

// Seed B (non-inlined items)
static OH_NO_b9c7459: &mut i32 = &mut 42; //~ ERROR mutable borrows of temporaries
fn main_9c7459c9_b9c7459() {
    assert_eq!(*OH_NO_b9c7459, 42);
    *OH_NO_b9c7459 = 43; //~ ERROR cannot assign to `*OH_NO_b9c7459`, as `OH_NO_b9c7459` is an immutable static
}

fn main() {

    println!("FFL Fusion Done");
}
