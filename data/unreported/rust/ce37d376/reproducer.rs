trait Foo<'a> { type Input; }
trait SuperFn: for<'a> Foo<'a> + for<'a> Fn(<Self as Foo<'a>>::Input) + Super2 {}
impl<T> SuperFn for T where T: for<'a> Fn(<Self as Foo<'a>>::Input) + for<'a> Foo<'a> {}
trait Foo2<'a> { type Input; }
trait Super2: for<'a> Foo2<'a> + for<'a> Fn(<Self as Foo2<'a>>::Input) {}
fn main() {}
