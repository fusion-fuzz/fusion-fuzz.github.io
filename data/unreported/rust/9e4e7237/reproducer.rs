macro_rules! s {
    () => { S };
}
trait Tr {
    fn foo(self, _: u8);
}
trait Other {
    fn foo(self);
}
struct S;
impl Other for S { fn foo(self) {} }
fn main() {
    s!().foo(0);
}
