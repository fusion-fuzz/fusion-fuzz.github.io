#![feature(generic_const_exprs)]
#![allow(incomplete_features)]

// Seed A (non-inlined items)
//@ revisions: old next
//@ ignore-compare-mode-next-solver (explicit revisions)
//@[next] compile-flags: -Znext-solver
//@[next] check-pass
//@[old] known-bug: #117392
//@[old] failure-status: 101
//@[old] dont-check-compiler-stderr

// This test previously caused an ICE in `fn crash` when relating opaque
// types. This has been fixed by the opaque type rework in the new solver.
pub trait BorrowComposite {
    type Ref<'a>: 'a;
}

impl BorrowComposite for () {
    type Ref<'a> = ();
}

pub trait Component<Args> {
    type Output;
}

impl<Args> Component<Args> for () {
    type Output = ();
}

//@ check-pass

pub fn delay<Args: BorrowComposite, Make: for<'a> FnMut(Args::Ref<'a>) -> C, C: Component<Args>>(
    make: Make,
) -> impl Component<Args> {
}

pub fn crash() -> impl Component<()> {
    delay(|()| delay(|()| ()))
}

pub fn main_6e9e5d94() {}

pub struct ConstDefaultUnstable<const N: usize = { const { 3 } }>;

pub fn main_9cea99ce() {}


// Seed B (non-inlined items)
//@ check-pass


pub struct ConstDefaultUnstable_b9cea99<const N: usize = { const { 3 } }>;

pub fn main_9cea99ce_b9cea99() {}

fn main() {

    println!("FFL Fusion Done");
}
