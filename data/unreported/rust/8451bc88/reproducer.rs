#![feature(gca_min_const_items, gca_const_items, generic_const_exprs)]
trait MyTrait: Copy { const ASSOC: usize; }
impl MyTrait for u8 { const ASSOC: usize = 32; }
const fn yeet() -> impl MyTrait { 0u8 }
const fn output<T: MyTrait>(_: T) -> usize { <T as MyTrait>::ASSOC }
#[repr(usize)]
enum Foo { Bar = output(yeet()) }
fn main() {}
