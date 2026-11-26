#![feature(register_tool)]
#![register_tool(foo::bar)] //~ ERROR malformed `register_tool` attribute input

// Seed A (non-inlined items)
//@ edition: 2021
//@ compile-flags: -Zunpretty=expanded
//@ check-pass

// NOTE: This is not considered RTN syntax currently.
// This is simply parenthesized generics.

trait Trait {
    async fn method() {}
}

fn foo<T: Trait<method(i32): Send>>() {}




fn main_97f23d47() {

    println!("FFL Fusion Done");
}
fn main_530efce0() {}
fn main() {}
