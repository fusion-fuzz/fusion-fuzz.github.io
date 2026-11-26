#![feature(generic_const_exprs, gca_min_const_items, gca_macroless_args)]
#![expect(incomplete_features)]
use std::gca;
fn pass_enum<const N: usize, const M: usize = const { N }> {
    pass_enum::<{ gca!(None) }>
}
fn main() {}
