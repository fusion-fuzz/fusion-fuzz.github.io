#![feature(extern_item_impls)]
#![feature(decl_macro)]
#![feature(rustc_attrs)]
#![feature(eii_internals)]
#![allow(unexpected_cfgs)] // for the cfg-as-descriptions

use std::cell::RefCell;
use std::collections::HashMap;

// Seed A (non-inlined items)
//@ compile-flags: --crate-type rlib
// Uses manual desugaring of EII internals: tests whether the types of parameters match.

#[eii_declaration(bar)]
//@ run-pass
// This is a regression test for something that only came up while
// attempting to bootstrap librustc with new destructor lifetime
// semantics.



// This version does not yet work (associated type issues)...
#[cfg(cannot_use_this_yet)]
fn foo<'a>(map: RefCell<HashMap<&'static str, &'a [u8]>>) {
    let one = [1];
    assert_eq!(map.borrow().get("one"), Some(&one[..]));
}

#[cfg(cannot_use_this_yet_either)]
// ... and this version does not work (the lifetime of `one` is
// supposed to match the lifetime `'a`) ...
fn foo<'a>(map: RefCell<HashMap<&'static str, &'a [u8]>>) {
    let one = [1];
    assert_eq!(map.borrow().get("one"), Some(&&one[..]));
}

#[cfg(all(not(cannot_use_this_yet),not(cannot_use_this_yet_either)))]
fn foo<'a>(map: RefCell<HashMap<&'static str, &'a [u8]>>) {
    // ...so instead we walk through the trivial slice and make sure
    // it contains the element we expect.

    for (i, &x) in map.borrow().get("one").unwrap().iter().enumerate() {
        assert_eq!((i, x), (0, 1));
    }
}

fn main_3e84363a() {
    let zer = [0];
    let one = [1];
    let two = [2];
    let mut map = HashMap::new();
    map.insert("zero", &zer[..]);
    map.insert("one",  &one[..]);
    map.insert("two",  &two[..]);
    let map = RefCell::new(map);
    foo(map);
}
#[rustc_builtin_macro(eii_shared_macro)]
macro foo() {}

unsafe extern "Rust" {
    safe fn bar(x: u64) -> u64;
}

#[foo]
fn other(x: usize) -> u64 {
    //~^ ERROR function `other` has a type that is incompatible with the declaration
    3
}

fn main_1b894643() {
    bar(0);
}


// Seed B (non-inlined items)
//@ run-pass
// This is a regression test for something that only came up while
// attempting to bootstrap librustc with new destructor lifetime
// semantics.



// This version does not yet work (associated type issues)...
#[cfg(cannot_use_this_yet)]
fn foo_b3e8436<'a>(map: RefCell<HashMap<&'static str, &'a [u8]>>) {
    let one = [1];
    assert_eq!(map.borrow().get("one"), Some(&one[..]));
}

#[cfg(cannot_use_this_yet_either)]
// ... and this version does not work (the lifetime of `one` is
// supposed to match the lifetime `'a`) ...
fn foo_b3e8436<'a>(map: RefCell<HashMap<&'static str, &'a [u8]>>) {
    let one = [1];
    assert_eq!(map.borrow().get("one"), Some(&&one[..]));
}

#[cfg(all(not(cannot_use_this_yet),not(cannot_use_this_yet_either)))]
fn foo_b3e8436<'a>(map: RefCell<HashMap<&'static str, &'a [u8]>>) {
    // ...so instead we walk through the trivial slice and make sure
    // it contains the element we expect.

    for (i, &x) in map.borrow().get("one").unwrap().iter().enumerate() {
        assert_eq!((i, x), (0, 1));
    }
}

fn main_3e84363a_b3e8436() {
    let zer = [0];
    let one = [1];
    let two = [2];
    let mut map = HashMap::new();
    map.insert("zero", &zer[..]);
    map.insert("one",  &one[..]);
    map.insert("two",  &two[..]);
    let map = RefCell::new(map);
    foo_b3e8436(map);
}

fn main() {

    println!("FFL Fusion Done");
}
