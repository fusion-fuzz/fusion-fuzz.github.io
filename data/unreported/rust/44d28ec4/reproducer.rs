#[deny(single_use_lifetime)]
#[deny(unused)]
#[derive(Debug)]
struct MyString<'a>(&'a String);
fn main() {}
