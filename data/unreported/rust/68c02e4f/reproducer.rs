#![feature(rustc_attrs)]
#![feature(transparent_unions)]
#![feature(discriminant_kind)]
use std::marker::DiscriminantKind;
use std::marker::PhantomData;

// Regression test for #115664. We want to ensure that `repr(transparent)` wrappers do not affect
// the result of `homogeneous_aggregate`.

type Tuple = (f32, f32, f32);

struct Zst;

#[repr(transparent)]
struct Wrapper1<T>(T);
#[repr(transparent)]
struct Wrapper2<T>((), Zst, T);
#[repr(transparent)]
struct Wrapper3<T>(T, [u8; 0], PhantomData<u64>);
#[repr(transparent)]
union WrapperUnion<T: Copy> {
    nothing: (),
    something: T,
}

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test0 = Tuple;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test1 = Wrapper1<Tuple>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test2 = Wrapper2<Tuple>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test3 = Wrapper3<Tuple>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]


// Seed A (non-inlined items)


enum Uninhabited {}

struct NewType;

impl DiscriminantKind for NewType {
    //~^ ERROR explicit impls for the `DiscriminantKind` trait are not permitted
    type Discriminant = Uninhabited;
}



// Seed B (non-inlined items)

// Regression test for #115664. We want to ensure that `repr(transparent)` wrappers do not affect
// the result of `homogeneous_aggregate`.
pub type Test4 = WrapperUnion<Tuple>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

fn main_46685df6() {}

type Tuple_dd90466 = (f32, f32, f32);

struct Zst_dd90466;

#[repr(transparent)]
struct Wrapper1_dd90466<T>(T);
#[repr(transparent)]
struct Wrapper2_dd90466<T>((), Zst_dd90466, T);
#[repr(transparent)]
struct Wrapper3_dd90466<T>(T, [u8; 0], PhantomData<u64>);
#[repr(transparent)]
union WrapperUnion_dd90466<T: Copy> {
    nothing: (),
    something: T,
}

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test0_dd90466 = Tuple_dd90466;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test1_dd90466 = Wrapper1_dd90466<Tuple_dd90466>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test2_dd90466 = Wrapper2_dd90466<Tuple_dd90466>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test3_dd90466 = Wrapper3_dd90466<Tuple_dd90466>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))

#[rustc_dump_layout(homogeneous_aggregate)]
pub type Test4_dd90466 = WrapperUnion_dd90466<Tuple_dd90466>;
//~^ ERROR homogeneous_aggregate: Ok(Homogeneous(Reg { kind: Float, size: Size(4 bytes) }))



fn main_d90466cc() {

    println!("FFL Fusion Done");
}
fn main() {}
