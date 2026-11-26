#![feature(gca_min_const_items)]
use std::gca;
fn main() {
    impl gca!({ fn foo() {} }) {}
}
