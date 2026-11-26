#![feature(rustc_attrs)]

#[rustc_force_inline]
fn three() -> u8 {
    3
}

fn call<F: Fn() -> u8>(f: &F) -> u8 {
    f()
}

fn main() {
    call(&three);
}
