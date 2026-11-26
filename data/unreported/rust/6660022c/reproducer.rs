#![feature(generic_const_items)]
#![feature(min_generic_const_args)]
#![feature(generic_const_args)]
#![expect(incomplete_features)]

// Seed A (non-inlined items)

//@ check-pass
//@ compile-flags: -Znext-solver


const ADD1<const N: usize>: usize = N + 1;



const INC<const N: usize>: usize = core::direct_const_arg!(ADD1::<N>);



const ARR: [(); core::direct_const_arg!(ADD1::<0>)] = [(); core::direct_const_arg!(INC::<0>)];



fn main_25a7ee59() {}


fn main_d7852551() {
//@ build-pass

pub enum Register<const N: u16> {
    Field0 = 40,
    Field1,
}

    let _b = Register::<0>::Field1 as u16;

}
//@ build-pass

pub enum Register_dd78525<const N: u16> {
    Field0 = 40,
    Field1,
}

fn main_d7852551_dd78525() {
    let _b = Register_dd78525::<0>::Field1 as u16;
}


// Seed B (non-inlined items)
//@ build-pass

pub enum Register_bd78525<const N: u16> {
    Field0 = 40,
    Field1,
}

fn main_d7852551_bd78525() {
    let _b = Register_bd78525::<0>::Field1 as u16;
}

fn main() {

    println!("FFL Fusion Done");
}
