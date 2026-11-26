#![crate_type = "lib"]
#![feature(rustc_attrs)]
#![feature(thread_local)]

// Seed A (non-inlined items)
//@ ignore-aarch64
//@ ignore-riscv32
//@ ignore-riscv64

// Confirm that non-AArch64 and non-RISC-V targets error when compiling scalable vectors
// (see #153593)


#[rustc_scalable_vector(4)]
//@ skip-filecheck
//@ test-mir-pass: SimplifyLocals-before-const-prop


#[derive(Copy, Clone)]
enum E {
    A,
    B,
}

// EMIT_MIR simplify_locals.c.SimplifyLocals-before-const-prop.diff
fn c() {
    let bytes = [0u8; 10];
    // Unused cast
    let _: &[u8] = &bytes;
}

// EMIT_MIR simplify_locals.d1.SimplifyLocals-before-const-prop.diff
fn d1() {
    // Unused set discriminant
    let _ = E::A;
}

// EMIT_MIR simplify_locals.d2.SimplifyLocals-before-const-prop.diff
fn d2() {
    // Unused set discriminant
    { (10, E::A) }.1 = E::B;
}

// EMIT_MIR simplify_locals.r.SimplifyLocals-before-const-prop.diff
fn r() {
    let mut a = 1;
    // Unused references
    let _ = &a;
    let _ = &mut a;
}
//~^ ERROR: scalable vectors are not supported on this architecture
struct ScalableVec(i32);

#[thread_local]
static mut X: u32 = 0;

// EMIT_MIR simplify_locals.t1.SimplifyLocals-before-const-prop.diff
fn t1() {
    // Unused thread local
    unsafe { X };
}

// EMIT_MIR simplify_locals.t2.SimplifyLocals-before-const-prop.diff
fn t2() {
    // Unused thread local
    unsafe { &mut X };
}

// EMIT_MIR simplify_locals.t3.SimplifyLocals-before-const-prop.diff
fn t3() {
    // Unused thread local
    unsafe { *&mut X };
}

// EMIT_MIR simplify_locals.t4.SimplifyLocals-before-const-prop.diff
fn t4() -> u32 {
    // Used thread local
    unsafe { X + 1 }
}

// EMIT_MIR simplify_locals.expose_provenance.SimplifyLocals-before-const-prop.diff
fn expose_provenance(p: *const usize) {
    // Used pointer to address cast. Has a side effect of exposing the provenance.
    p as usize;
}

fn main_07c1c647() {
    c();
    d1();
    d2();
    r();
    t1();
    t2();
    t3();
    t4();
    expose_provenance(&0);
}


// Seed B (non-inlined items)
//@ skip-filecheck
//@ test-mir-pass: SimplifyLocals-before-const-prop


#[derive(Copy, Clone)]
enum E_b07c1c6 {
    A,
    B,
}

// EMIT_MIR simplify_locals.c_b07c1c6.SimplifyLocals-before-const-prop.diff
fn c_b07c1c6() {
    let bytes = [0u8; 10];
    // Unused cast
    let _: &[u8] = &bytes;
}

// EMIT_MIR simplify_locals.d1_b07c1c6.SimplifyLocals-before-const-prop.diff
fn d1_b07c1c6() {
    // Unused set discriminant
    let _ = E_b07c1c6::A;
}

// EMIT_MIR simplify_locals.d2_b07c1c6.SimplifyLocals-before-const-prop.diff
fn d2_b07c1c6() {
    // Unused set discriminant
    { (10, E_b07c1c6::A) }.1 = E_b07c1c6::B;
}

// EMIT_MIR simplify_locals.r_b07c1c6.SimplifyLocals-before-const-prop.diff
fn r_b07c1c6() {
    let mut a = 1;
    // Unused references
    let _ = &a;
    let _ = &mut a;
}

#[thread_local]
static mut X_b07c1c6: u32 = 0;

// EMIT_MIR simplify_locals.t1_b07c1c6.SimplifyLocals-before-const-prop.diff
fn t1_b07c1c6() {
    // Unused thread local
    unsafe { X_b07c1c6 };
}

// EMIT_MIR simplify_locals.t2_b07c1c6.SimplifyLocals-before-const-prop.diff
fn t2_b07c1c6() {
    // Unused thread local
    unsafe { &mut X_b07c1c6 };
}

// EMIT_MIR simplify_locals.t3_b07c1c6.SimplifyLocals-before-const-prop.diff
fn t3_b07c1c6() {
    // Unused thread local
    unsafe { *&mut X_b07c1c6 };
}

// EMIT_MIR simplify_locals.t4_b07c1c6.SimplifyLocals-before-const-prop.diff
fn t4_b07c1c6() -> u32 {
    // Used thread local
    unsafe { X_b07c1c6 + 1 }
}

// EMIT_MIR simplify_locals.expose_provenance_b07c1c6.SimplifyLocals-before-const-prop.diff
fn expose_provenance_b07c1c6(p: *const usize) {
    // Used pointer to address cast. Has a side effect of exposing the provenance.
    p as usize;
}

fn main_07c1c647_b07c1c6() {
    c_b07c1c6();
    d1_b07c1c6();
    d2_b07c1c6();
    r_b07c1c6();
    t1_b07c1c6();
    t2_b07c1c6();
    t3_b07c1c6();
    t4_b07c1c6();
    expose_provenance_b07c1c6(&0);
}

fn main() {

    println!("FFL Fusion Done");
}
