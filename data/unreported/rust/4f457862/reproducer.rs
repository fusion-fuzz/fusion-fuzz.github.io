#[rustc_comptime]
trait Bar {
    fn method() -> impl Sized { //~ ERROR: duplicate definitions with name `method`
    }
}
