#![feature(generic_const_parameter_types, adt_const_params, unsized_const_params)]
#![expect(incomplete_features)]
#![feature(fn_delegation)]

fn foo<'a, const N: &'a u32>() {}

fn bar() {
    foo::<'static, { &1_u32 }>();
    //~^ ERROR: anonymous constants with lifetimes in their type are not yet supported
    foo::<'_, { &1_u32 }>();
    //~^ ERROR: anonymous constants with lifetimes in their type are not yet supported
}

fn borrowck<'a, const N: &'static u32, const M: &'a u32>() {
    foo::<'a, M>();
    foo::<'static, M>();
    //~^ ERROR: lifetime may not live long enough
    foo::<'static, N>();
}
//@ run-pass


trait Trait<'a, A, const B: bool> {
    fn foo<'b, const B2: bool, T, U>(&self, f: impl FnOnce() -> usize) -> usize {
        f() + 1
    }
}

struct X;
impl<'a, A, const B: bool> Trait<'a, A, B> for X {}

reuse Trait::foo;
reuse Trait::<'static, (), true>::foo::<true, (), ()> as bar;

reuse foo as foo2;
reuse bar as bar2;

trait Trait2 {
    reuse foo2 as foo3;
    reuse bar2 as bar3;
}

impl Trait2 for () {}

reuse <() as Trait2>::foo3 as foo4;
reuse <() as Trait2>::bar3 as bar4;

fn main_a30a0501() {
    assert_eq!(foo::<'static, X, (), true, false, (), ()>(&X, || 123), 124);
    assert_eq!(foo2::<'static, X, (), true, false, (), ()>(&X, || 123), 124);
    assert_eq!(<()>::foo3::<'static, X, (), true, false, (), ()>(&X, || 123), 124);
    assert_eq!(foo4::<'static, X, (), true, false, (), ()>(&X, || 123), 124);

    assert_eq!(bar::<X>(&X, || 123), 124);
    assert_eq!(bar2::<X>(&X, || 123), 124);
    assert_eq!(<()>::bar3::<X>(&X, || 123), 124);
    assert_eq!(bar4::<X>(&X, || 123), 124);

    assert_eq!(bar(&X, || 123), 124);
    assert_eq!(bar2(&X, || 123), 124);
    assert_eq!(<()>::bar3(&X, || 123), 124);
    assert_eq!(bar4::<X>(&X, || 123), 124);
}

fn main_5cfb04c8() {}
fn main() {}
