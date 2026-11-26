#![deny(function_casts_as_integer)]
#![allow(unused_variables, dead_code)] // For the rustfix-ed code.
#![feature(rustc_attrs)]

//@ run-rustfix


fn foo() {

struct S;

}



enum MyEnum {
    Variant(u32),
}



struct MyStruct(u32);



fn main_9f499988() {
    let x = foo as usize; //~ ERROR: function_casts_as_integer
    let x = String::len as usize; //~ ERROR: function_casts_as_integer
    let x = MyEnum::Variant as usize; //~ ERROR: function_casts_as_integer
    let x = MyStruct as usize; //~ ERROR: function_casts_as_integer
    // Ok.
    let x = foo as fn() as usize;
    let x = foo as *const () as usize;
}

trait A_da3ba3d {
    fn foo_a(&self) {}
}

trait B_da3ba3d {
    fn foo_b(&self) {}
}

trait C_da3ba3d: A_da3ba3d + B_da3ba3d {
    fn foo_c(&self) {}
}

struct S_da3ba3d;

#[rustc_dump_vtable]
impl A_da3ba3d for S_da3ba3d {}
//~^ error vtable

trait A {
    fn foo_a(&self) {}
}



trait B {
    fn foo_b(&self) {}
}



trait C: A + B {
    fn foo_c(&self) {}
}





#[rustc_dump_vtable]
impl A for S {}


//~^ error vtable

#[rustc_dump_vtable]
impl B for S {}


//~^ error vtable

#[rustc_dump_vtable]
impl C for S {}


//~^ error vtable

fn main_ba3ba3d1f() {}

#[rustc_dump_vtable]
impl B_da3ba3d for S_da3ba3d {}
//~^ error vtable

#[rustc_dump_vtable]
impl C_da3ba3d for S_da3ba3d {}
//~^ error vtable

fn main_a3ba3d1f() {}
fn main() {}
