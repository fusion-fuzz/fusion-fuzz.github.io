#![feature(custom_mir, core_intrinsics)]
#![crate_type = "lib"]

#[custom_mir(dialect = "runtime", phase = "post-cleanup")]
fn f() {}
