#![feature(type_alias_impl_trait)]

type Foo = impl std::fmt::Debug;

struct Bar(Foo);

#[define_opaque(Foo)]
fn foo() -> Foo {
    #[define_opaque(Foo)]
    fn define() -> Bar {
        Bar(42)
    }
}

fn main() {}
