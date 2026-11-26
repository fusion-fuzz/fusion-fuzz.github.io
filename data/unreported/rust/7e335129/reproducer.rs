#![feature(rustc_attrs)]
#[rustc_must_implement_one_of(a, b)]
trait Foo {
    fn c() -> impl Sized;
    fn a() {}
    fn b() {}
}
impl Foo for () {
    fn c() -> impl Sized {}
    fn a() {}
}
fn main() {}
