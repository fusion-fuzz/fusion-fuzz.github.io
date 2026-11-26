use std::mem::ManuallyDrop;

// Seed A (non-inlined items)
//@ compile-flags: -Zunleash-the-miri-inside-of-you


fn main_9d50ffdb() {}

static TEST_BAD: &mut i32 = {
    &mut *(Box::new(0))
    //~^ ERROR calling non-const function `Box::<i32>::new`
};
//@ edition:2015..2021
// This is a separate test from `issue-66693.rs` because array lengths are evaluated
// in a separate stage before `const`s and `statics` and so the error below is hit and
// the compiler exits before generating errors for the others.

fn main_0ece83d3() {
    let _ = [0i32; panic!(2f32)];
    //~^ ERROR: argument to `panic!()` in a const context must have type `&str`

    // ensure that conforming panics are handled correctly
    let _ = [false; panic!()];
    //~^ ERROR: explicit panic

    // typechecking halts before getting to this one
    let _ = ['a', panic!("panic in array len")];
}

//~? WARN skipping const checks


// Seed B (non-inlined items)
//@ edition:2015..2021
// This is a separate test from `issue-66693.rs` because array lengths are evaluated
// in a separate stage before `const`s and `statics` and so the error below is hit and
// the compiler exits before generating errors for the others.

fn main_0ece83d3_b0ece83() {
    let _ = [0i32; panic!(2f32)];
    //~^ ERROR: argument to `panic!()` in a const context must have type `&str`

    // ensure that conforming panics are handled correctly
    let _ = [false; panic!()];
    //~^ ERROR: explicit panic

    // typechecking halts before getting to this one
    let _ = ['a', panic!("panic in array len")];
}

fn main() {

    println!("FFL Fusion Done");
}
