// Seed A (non-inlined items)
// Regression test for https://github.com/rust-lang/rust/issues/3668
//
struct P {
    child: Option<Box<P>>,
}
trait PTrait {
    fn getChildOption(&self) -> Option<Box<P>>;
}

impl PTrait for P {
    fn getChildOption(&self) -> Option<Box<P>> {
        static childVal: Box<P> = self.child.get();
        //~^ ERROR attempt to use a non-constant value in a constant
        panic!();
    }
}
// Regression test for an ICE that occurred with the universes code:
//
// The signature of the closure `|_|` was being inferred to
// `exists<'r> fn(&'r u8)`. This should result in a type error since
// the signature `for<'r> fn(&'r u8)` is required. However, due to a
// bug in the type variable generalization code, the placeholder for
// `'r` was leaking out into the writeback phase, causing an ICE.

trait ClonableFn<T> {
    fn clone(&self) -> Box<dyn Fn(T)>;
}

impl<T, F: 'static> ClonableFn<T> for F
where
    F: Fn(T) + Clone,
{
    fn clone(&self) -> Box<dyn Fn(T)> {
        Box::new(self.clone())
    }
}

fn main_b92a3b00() {}

struct Foo(Box<dyn for<'a> ClonableFn<&'a bool>>);

fn main_37c0b694() {
    Foo(Box::new(|_| ())); //~ ERROR implementation of `FnOnce` is not general enough
}


// Seed B (non-inlined items)
// Regression test for an ICE that occurred with the universes code:
//
// The signature of the closure `|_|` was being inferred to
// `exists<'r> fn(&'r u8)`. This should result in a type error since
// the signature `for<'r> fn(&'r u8)` is required. However, due to a
// bug in the type variable generalization code, the placeholder for
// `'r` was leaking out into the writeback phase, causing an ICE.

trait ClonableFn_b37c0b6<T> {
    fn clone(&self) -> Box<dyn Fn(T)>;
}

impl<T, F: 'static> ClonableFn_b37c0b6<T> for F
where
    F: Fn(T) + Clone,
{
    fn clone(&self) -> Box<dyn Fn(T)> {
        Box::new(self.clone())
    }
}

struct Foo_b37c0b6(Box<dyn for<'a> ClonableFn_b37c0b6<&'a bool>>);

fn main_37c0b694_b37c0b6() {
    Foo_b37c0b6(Box::new(|_| ())); //~ ERROR implementation of `FnOnce` is not general enough
}

fn main() {

    println!("FFL Fusion Done");
}
