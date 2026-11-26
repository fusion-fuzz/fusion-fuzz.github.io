#![feature(

// Seed A (non-inlined items)
//@ check-pass
    min_generic_const_args,
    generic_const_parameter_types,
    inherent_associated_types,
    min_adt_const_params,
    const_param_ty_trait
)]

struct ThreeTypes<T1, T2, T3>(T1, T2, T3);

impl<T1, T2, T3: std::marker::ConstParamTy_> ThreeTypes<T1, T2, T3> {
    type const INHERENT: [T3; 0] = [];
}

struct Struct<const O: [u32; 0]>;

fn f() -> Struct<{ core::direct_const_arg!(ThreeTypes::<u8, u16, u32>::INHERENT) }> {
    Struct
}



// Seed B (non-inlined items)
//@ check-pass
//@ edition: 2021
//@ revisions: assumptions no_assumptions
//@[assumptions] compile-flags: -Zhigher-ranked-assumptions

pub trait FutureIterator {
    type Future<'s, 'cx>: Send
    where
        's: 'cx;
}

fn call<I: FutureIterator>() -> impl Send {
    async { // a coroutine checked for autotrait impl `Send`
        let x = None::<I::Future<'_, '_>>; // a type referencing GAT
        async {}.await; // a yield point
    }
}

fn call2<'a: 'b, 'b, I: FutureIterator>() -> impl Send {
    async { // a coroutine checked for autotrait impl `Send`
        let x = None::<I::Future<'a, 'b>>; // a type referencing GAT
        async {}.await; // a yield point
    }
}



fn main() {

    println!("FFL Fusion Done");
}
