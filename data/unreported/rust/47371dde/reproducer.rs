#![feature(trait_alias)]
trait Partial<T> = IntoIterator<Item = T>;
fn get<T: Partial>(opt: &Option<T>) -> &T {
    match *opt {
        Some(ref v) => v,
        None => panic!("none"),
    }
}
fn main() {}
