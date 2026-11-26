#![crate_type = "lib"]
#![allow(internal_features)]
#![feature(rustc_attrs, link_llvm_intrinsics)]

#[rustc_scalable_vector(4)]
#[allow(non_camel_case_types)]
#[repr(transparent)]
pub struct svbool4_t(bool);

pub fn trigger() -> svbool4_t {
    unsafe extern "C" {
        #[link_name = "llvm.aarch64.sve.whilelo.nxv4i1.u64"]
        fn _svwhilelt_b32_u64(op1: u64, op2: u64) -> svbool4_t;
    }
    unsafe { _svwhilelt_b32_u64(0, 1) }
}
