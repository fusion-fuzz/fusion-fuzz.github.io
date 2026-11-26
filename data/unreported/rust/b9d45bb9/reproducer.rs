#![feature(optimize_attribute)]

// Seed A (non-inlined items)
//@ revisions: NO-OPT SPEED-OPT
//@[NO-OPT] compile-flags: -Copt-level=0
//@[SPEED-OPT] compile-flags: -Copt-level=3 -Coverflow-checks=y


#[optimize(none)]
pub fn add_noopt() -> i32 {
    // CHECK-LABEL: fn add_noopt(
    // CHECK: AddWithOverflow(const 1_i32, const 2_i32);
    // CHECK-NEXT: assert
    1 + 2
}

#[optimize(none)]
fn test(cond: bool) {
    let v;
    while cond {
        v = 3;
        break;
    }
    println!("{}", v); //~ ERROR E0381
}
pub fn const_branch() -> i32 {
    // CHECK-LABEL: fn const_branch(
    // CHECK: [[BOOL:_[0-9]+]] = const true;
    // CHECK: switchInt(move [[BOOL]]) -> [0: [[BB_FALSE_SHIM:bb[0-9]+]], otherwise: [[BB_TRUE:bb[0-9]+]]];
    // CHECK-NEXT: }
    // CHECK: [[BB_FALSE_SHIM]]: {
    // CHECK-NEXT: goto -> [[BB_FALSE:bb[0-9]+]]
    // CHECK: [[BB_FALSE]]: {
    // CHECK-NEXT: _0 = const 0
    // CHECK: [[BB_TRUE]]: {
    // CHECK-NEXT: _0 = const 1
    // CHECK-NEXT: goto
    // CHECK-NEXT: }

    if true { 1 } else { 0 }
}

fn main_cb3a66d5() {}

fn main_978ff6aa() {
    test(true);
}


// Seed B (non-inlined items)
fn test_b978ff6(cond: bool) {
    let v;
    while cond {
        v = 3;
        break;
    }
    println!("{}", v); //~ ERROR E0381
}

fn main_978ff6aa_b978ff6() {
    test_b978ff6(true);
}

fn main() {

    println!("FFL Fusion Done");
}
