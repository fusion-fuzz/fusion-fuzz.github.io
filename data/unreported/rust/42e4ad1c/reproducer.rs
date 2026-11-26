#![crate_type = "lib"]
#![feature(rustc_attrs, auto_traits)]

// Seed A (non-inlined items)
struct MyType;
struct MyType2;
struct MyType3;
struct MyType4;

impl std::fmt::Display for MyType {
   fn fmt(&self, x: &str) -> () { }
   //~^ ERROR method `fmt` has an incompatible type
}

// Related to <https://github.com/rust-lang/rust/issues/113840>
//
// This test makes sure that multiple auto traits can reuse the
// same pointer for upcasting (e.g. `Send`/`Sync`)


// Markers
auto trait M0 {}
auto trait M1 {}
auto trait M2 {}

// Just a trait with a method
trait T {
    fn method(&self) {}
}

trait A: M0 + M1 + M2 + T {}

trait B: M0 + M1 + T + M2 {}

trait C: M0 + T + M1 + M2 {}

trait D: T + M0 + M1 + M2 {}

struct S;

impl M0 for S {}
impl M1 for S {}
impl M2 for S {}
impl T for S {}

#[rustc_dump_vtable]
impl std::fmt::Display for MyType2 {
   fn fmt(&self) -> () { }
   //~^ ERROR method `fmt` has 1 parameter
}

impl std::fmt::Display for MyType3 {
   fn fmt() -> () { }
   //~^ ERROR method `fmt` has a `&self` declaration in the trait
}

impl std::fmt::Display for MyType4 {}
//~^ ERROR not all trait items

fn main_35440f0d() {}
impl A for S {}
//~^ ERROR vtable entries

#[rustc_dump_vtable]
impl B for S {}
//~^ ERROR vtable entries

#[rustc_dump_vtable]
impl C for S {}
//~^ ERROR vtable entries

#[rustc_dump_vtable]
impl D for S {}
//~^ ERROR vtable entries

fn main_6a61e2f9() {}


// Seed B (non-inlined items)
// Related to <https://github.com/rust-lang/rust/issues/113840>
//
// This test makes sure that multiple auto traits can reuse the
// same pointer for upcasting (e.g. `Send`/`Sync`)


// Markers
auto trait M0 {}
auto trait M1 {}
auto trait M2 {}

// Just a trait with a method
trait T_b6a61e2 {
    fn method(&self) {}
}

trait A_b6a61e2: M0 + M1 + M2 + T_b6a61e2 {}

trait B_b6a61e2: M0 + M1 + T_b6a61e2 + M2 {}

trait C_b6a61e2: M0 + T_b6a61e2 + M1 + M2 {}

trait D_b6a61e2: T_b6a61e2 + M0 + M1 + M2 {}

struct S_b6a61e2;

impl M0 for S_b6a61e2 {}
impl M1 for S_b6a61e2 {}
impl M2 for S_b6a61e2 {}
impl T_b6a61e2 for S_b6a61e2 {}

#[rustc_dump_vtable]
impl A_b6a61e2 for S_b6a61e2 {}
//~^ ERROR vtable entries

#[rustc_dump_vtable]
impl B_b6a61e2 for S_b6a61e2 {}
//~^ ERROR vtable entries

#[rustc_dump_vtable]
impl C_b6a61e2 for S_b6a61e2 {}
//~^ ERROR vtable entries

#[rustc_dump_vtable]
impl D_b6a61e2 for S_b6a61e2 {}
//~^ ERROR vtable entries

fn main_6a61e2f9_b6a61e2() {}

fn main() {

    println!("FFL Fusion Done");
}
