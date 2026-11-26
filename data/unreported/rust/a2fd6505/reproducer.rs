#![feature(custom_mir, core_intrinsics)]
#![feature(gca_adts, gca_min_const_items, gca_macroless_args, adt_const_params)]
extern crate core;
use core::intrinsics::mir::*;
use std::marker::ConstParamTy;




// Seed A (non-inlined items)
//@ skip-filecheck


union U {
    a: i32,
    b: u32,
}



// EMIT_MIR projections.unions.built.after.mir
#[custom_mir(dialect = "built")]
fn unions(u: U) -> i32 {
    mir! {
        {
            RET = u.a;
            Return()
        }
    }
}



// EMIT_MIR projections.tuples.built.after.mir
#[custom_mir(dialect = "analysis", phase = "post-cleanup")]
fn tuples(i: (u32, i32)) -> (u32, i32) {
    mir! {
        type RET = (u32, i32);
        {
            RET.0 = i.0;
            RET.1 = i.1;
            Return()
        }
    }
}



// EMIT_MIR projections.unwrap.built.after.mir
#[custom_mir(dialect = "built")]
fn unwrap(opt: Option<i32>) -> i32 {
    mir! {
        {
            RET = Field(Variant(opt, 1), 0);
            Return()
        }
    }
}



// EMIT_MIR projections.unwrap_deref.built.after.mir
#[custom_mir(dialect = "built")]
fn unwrap_deref(opt: Option<&i32>) -> i32 {
    mir! {
        {
            RET = *Field::<&i32>(Variant(opt, 1), 0);
            Return()
        }
    }
}



// EMIT_MIR projections.set.built.after.mir
#[custom_mir(dialect = "built")]
fn set(opt: &mut Option<i32>) {
    mir! {
        {
            place!(Field(Variant(*opt, 1), 0)) = 10;
            Return()
        }
    }
}



// EMIT_MIR projections.simple_index.built.after.mir
#[custom_mir(dialect = "built")]
fn simple_index(a: [i32; 10], b: &[i32]) -> i32 {
    mir! {
        {
            let temp = 3;
            RET = a[temp];
            RET = (*b)[temp];
            Return()
        }
    }
}





// Seed B (non-inlined items)
//@ run-pass


#[derive(Debug, Eq, PartialEq, ConstParamTy)]
enum Option<T> {
    Some(T),
}



fn with_option<const O: Option<u32>>() -> Option<u32> {
    O
}



fn test<const N: u32>() {
    with_option::<{ <Option<u32>>::Some(N) }>();
    with_option::<{ <Option<u32>>::Some(const { 42 }) }>();
}





fn main_ab6d7211() {
test::<5>();
let o = with_option::<{ <Option<u32>>::Some(const { 10 }) }>();
assert_eq!('ffl_44047487_unions_1: {
let u: U = U { a: 5 };

    mir! {
        {
            RET = u.a;
            Return()
        }
    }

}, 5);
assert_eq!(o, Option::Some(10));
assert_eq!('ffl_44047487_tuples_2: {
let i: (u32, i32) = (5, 6);

    mir! {
        type RET = (u32, i32);
        {
            RET.0 = i.0;
            RET.1 = i.1;
            Return()
        }
    }

}, (5, 6));
assert_eq!('ffl_44047487_unwrap_3: {
let opt: Option<i32> = Some(5);

    mir! {
        {
            RET = Field(Variant(opt, 1), 0);
            Return()
        }
    }

}, 5);
assert_eq!('ffl_44047487_unwrap_deref_4: {
let opt: Option<&i32> = Some(&5);

    mir! {
        {
            RET = *Field::<&i32>(Variant(opt, 1), 0);
            Return()
        }
    }

}, 5);
let mut o = Some(5);
'ffl_44047487_set_5: {
let opt: &mut Option<i32> = &mut o;

    mir! {
        {
            place!(Field(Variant(*opt, 1), 0)) = 10;
            Return()
        }
    }

}
;
assert_eq!(o, Some(10));
assert_eq!('ffl_44047487_simple_index_6: {
let a: [i32; 10] = [0; 10];
let b: &[i32] = &[0; 10];

    mir! {
        {
            let temp = 3;
            RET = a[temp];
            RET = (*b)[temp];
            Return()
        }
    }

}, 0);
    println!("FFL Fusion Done");
}
//@ run-pass


#[derive(Debug, Eq, PartialEq, ConstParamTy)]
enum Option_de84370<T> {
    Some(T),
}

fn with_option_de84370<const O: Option_de84370<u32>>() -> Option_de84370<u32> {
    O
}

fn test_de84370<const N: u32>() {
    with_option_de84370::<{ <Option_de84370<u32>>::Some(N) }>();
    with_option_de84370::<{ <Option_de84370<u32>>::Some(const { 42 }) }>();
}

fn main_e8437018_de84370() {
    test_de84370::<5>();

    let o = with_option_de84370::<{ <Option_de84370<u32>>::Some(const { 10 }) }>();
    assert_eq!(o, Option_de84370::Some(10));
}







fn main_e8437018() {
    test::<5>();

    let o = with_option::<{ <Option<u32>>::Some(const { 10 }) }>();
    assert_eq!(o, Option::Some(10));
}
fn main() {}
