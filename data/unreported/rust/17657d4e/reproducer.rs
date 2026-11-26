#![feature(inherent_associated_types)]
#![allow(incomplete_features)]

struct Foo<T, U, V>(T, U, V);

impl<T> Foo<T, T, u8> {
    type IAT = u8;
}

struct Bar<T, U> {
    field: Foo<T, U, <u16 as Identity>::This>::IAT,
}
