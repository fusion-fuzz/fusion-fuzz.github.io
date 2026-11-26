#![feature(custom_mir)]
#[custom_mir(dialect = "built")]
const X: *const u8 = b"" as _;
fn main() {}
