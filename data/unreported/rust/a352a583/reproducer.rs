#![crate_type="rlib"]
#![deny(dead_code)]
#![crate_type = "lib"]

#[optimize(size)] //~ ERROR the `optimize` attribute is an experimental feature
fn size() {}

#[optimize(speed)] //~ ERROR the `optimize` attribute is an experimental feature
fn speed() {}

#[optimize(none)] //~ ERROR the `optimize` attribute is an experimental feature

// Seed A (non-inlined items)
//@ compile-flags:-Clink-dead-code -Copt-level=0


fn generic_fn<T>(a: T) -> (T, i32) {
    //~ MONO_ITEM fn generic_fn::nested_fn
    fn nested_fn(a: i32) -> i32 {
        a + 1
    }

    let x = {
        //~ MONO_ITEM fn generic_fn::nested_fn
        fn nested_fn(a: i32) -> i32 {
            a + 2
        }

        1 + nested_fn(1)
    };

    return (a, x + nested_fn(0));
}

//~ MONO_ITEM fn start
#[no_mangle]
pub fn start(_: isize, _: *const *const u8) -> isize {
    //~ MONO_ITEM fn generic_fn::<i64>
    let _ = generic_fn(0i64);
    //~ MONO_ITEM fn generic_fn::<u16>
    let _ = generic_fn(0u16);
    //~ MONO_ITEM fn generic_fn::<i8>
    let _ = generic_fn(0i8);

    0
}
fn none() {}

#[optimize(banana)]
//~^ ERROR the `optimize` attribute is an experimental feature
//~| ERROR malformed `optimize` attribute input [E0539]
fn not_known() {}

// Seed B (non-inlined items)

#[optimize(size_d61d685)] //~ ERROR the `optimize` attribute is an experimental feature
fn size_d61d685() {}

#[optimize(speed_d61d685)] //~ ERROR the `optimize` attribute is an experimental feature
fn speed_d61d685() {}

#[optimize(none_d61d685)] //~ ERROR the `optimize` attribute is an experimental feature
fn none_d61d685() {}

#[optimize(banana)]
//~^ ERROR the `optimize` attribute is an experimental feature
//~| ERROR malformed `optimize` attribute input [E0539]
fn not_known_d61d685() {}

fn main_61d685d0() {

    println!("FFL Fusion Done");
}
fn main() {}
