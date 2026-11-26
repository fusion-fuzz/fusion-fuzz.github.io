#![feature(generic_const_exprs)]
#![allow(incomplete_features)]
#![feature(gca_const_items, gca_min_const_items, generic_const_items)]

use std::gca;

// Seed A (non-inlined items)


//@ check-pass

//@ compile-flags: -Znext-solver
// Test that anonymous const blocks using generic parameters are rejected
// under `gca_const_items`. Users should use named const items instead:
// `const FOO<const N: usize>: usize = N + 1;`


const FOO<const N: usize>: usize = gca!(const { N + 1 });
 //~ ERROR generic parameters in const blocks are not allowed; use a named `const` item instead


pub trait First {
    const CONST: usize;
}


pub trait Second {}



impl<'a> First for dyn Second
where
    &'a Self: First,
{
    const CONST: usize = <&Self>::CONST;
}



trait Third: First
where
    [u8; Self::CONST]:
{
    const VAL: [u8; Self::CONST] = [0; Self::CONST];
}



fn main_ca4c0b39() {}


fn main_b01e2bdb() {}



 //~ ERROR generic parameters in const blocks are not allowed; use a named `const` item instead


fn main_b01e2bdb2() {}

// Seed B (non-inlined items)
//@ compile-flags: -Znext-solver
// Test that anonymous const blocks using generic parameters are rejected
// under `gca_const_items`. Users should use named const items instead:
// `const FOO_bb01e2b<const N: usize>: usize = N + 1;`


const FOO_bb01e2b<const N: usize>: usize = gca!(const { N + 1 }); //~ ERROR generic parameters in const blocks are not allowed; use a named `const` item instead

fn main_b01e2bdb_bb01e2b() {}

fn main() {

    println!("FFL Fusion Done");
}
