#![feature(custom_mir, core_intrinsics)]

extern crate core;
use core::intrinsics::mir::*;

// Seed A (non-inlined items)


//@ check-pass
//@ incremental

struct Struct<T>(T);




fn main_a93aa4bc() {

impl<T> std::ops::Deref for Struct<T> {
    type Target = dyn Fn(T);
    fn deref(&self) -> &Self::Target {
        unimplemented!()
    }
}

fn main_f1260911() {
    assert_eq!(arrays::<20>(), 20);
}

    let f = Struct(Default::default());
    f(0);
    f(0);

}
//@ skip-filecheck


// EMIT_MIR arrays.arrays.built.after.mir
#[custom_mir(dialect = "built")]
fn arrays<const C: usize>() -> usize {
    mir! {
        {
            let x = [5_i32; C];
            let y = &raw const x;
            let z = CastUnsize::<_, *const [i32]>(y);
            let c = PtrMetadata(z);
            RET = c;
            Return()
        }
    }
}
//@ skip-filecheck


// EMIT_MIR arrays_df12609.arrays_df12609.built.after.mir
#[custom_mir(dialect = "built")]
fn arrays_df12609<const C: usize>() -> usize {
    mir! {
        {
            let x = [5_i32; C];
            let y = &raw const x;
            let z = CastUnsize::<_, *const [i32]>(y);
            let c = PtrMetadata(z);
            RET = c;
            Return()
        }
    }
}

fn main_f1260911_df12609() {
    assert_eq!(arrays_df12609::<20>(), 20);
}


// Seed B (non-inlined items)
//@ skip-filecheck


// EMIT_MIR arrays_bf12609.arrays_bf12609.built.after.mir
#[custom_mir(dialect = "built")]
fn arrays_bf12609<const C: usize>() -> usize {
    mir! {
        {
            let x = [u32::MAX; C];
            let y = &raw const x;
            let z = CastUnsize::<_, *const [i32]>(y);
            let c = PtrMetadata(z);
            RET = c;
            Return()
        }
    }
}

fn main_f1260911_bf12609() {
    assert_eq!(arrays_bf12609::<20>(), 20);
}

fn main() {

    println!("FFL Fusion Done");
}
