#![feature(generic_const_args, generic_const_items, min_generic_const_args)]
#![expect(incomplete_features)]

// Seed A (non-inlined items)

// Test when deferring repeat expr copy checks to end of typechecking whether elements
// that are const items allow for repeat counts to go uninferred without an error being
// emitted if they would later wind up inferred by integer fallback.
//
// This test should be updated if we wind up deferring repeat expr checks until *after*
// integer fallback as the point of the test is not *specifically* about integer fallback
// but rather about the behaviour of `const` element exprs.

trait Trait<const N: usize> {}



// We impl `Trait` for both `i32` and `u32` to avoid being able
// to prove `?int: Trait<?n>` from there only being one impl.
impl Trait<2> for i32 {}


impl Trait<2> for u32 {}



fn tie_and_make_goal<const N: usize, T: Trait<N>>(_: &T, _: &[String; N]) {}



fn const_block() {
    // Deferred repeat expr `String; ?n`
    let a = [const { String::new() }; _];

    // `?int: Trait<?n>` goal
    tie_and_make_goal(&1, &a);

    // If repeat expr checks structurally resolve the `?n`s before checking if the
    // element is a `const` then we would error here. Otherwise we avoid doing so,
    // integer fallback occurs, allowing `?int: Trait<?n>` goals to make progress,
    // inferring the repeat counts (to `2` but that doesn't matter as the element is `const`).
}



fn const_item() {
    const MY_CONST: String = String::new();

    // Deferred repeat expr `String; ?n`
    let a = [MY_CONST; _];

    // `?int: Trait<?n>` goal
    tie_and_make_goal(&1, &a);

    // ... same as `const_block`
}



fn assoc_const() {
    trait Dummy {
        const ASSOC: String;
    }
    impl Dummy for () {
        const ASSOC: String = String::new();
    }

    // Deferred repeat expr `String; ?n`
    let a = [<() as Dummy>::ASSOC; _];

    // `?int: Trait<?n>` goal
    tie_and_make_goal(&1, &a);

    // ... same as `const_block`
}




fn main_d14fb80e() {

fn const_block_but_uninferred() {
    // Deferred repeat expr `String; ?n`
    let a = [const { String::new() }; _];
    //~^ ERROR: type annotations needed for `[String; _]`

    // Even if we don't structurally resolve the repeat count as part of repeat expr
    // checks, we still error on the repeat count being uninferred as we require all
    // types/consts to be inferred by the end of type checking.
}

fn main_88f8db37() {
    let _: dyn Trait_b88f8db37;
    //~^ ERROR the trait `Trait_b88f8db37` is not dyn compatible
}

}
// Ensure that traits with generic non-type associated consts are dyn *in*compatible,
// even when non-type associated const equality is enabled by `generic_const_args`.

//@ dont-require-annotations: NOTE
//@ compile-flags: -Znext-solver=globally


trait Trait_d88f8db {
    const ASSOC<const N: usize>: usize;
    //~^ NOTE it contains generic associated const `ASSOC`
}

fn main_88f8db37_d88f8db() {
    let _: dyn Trait_d88f8db;
    //~^ ERROR the trait `Trait_d88f8db` is not dyn compatible
}
// Ensure that traits with generic non-type associated consts are dyn *in*compatible,
// even when non-type associated const equality is enabled by `generic_const_args`.

//@ dont-require-annotations: NOTE
//@ compile-flags: -Znext-solver=globally


trait Trait_b88f8db37 {
    const ASSOC<const N: usize>: usize;
    //~^ NOTE it contains generic associated const `ASSOC`
}


// Seed B (non-inlined items)
// Ensure that traits with generic non-type associated consts are dyn *in*compatible,
// even when non-type associated const equality is enabled by `generic_const_args`.

//@ dont-require-annotations: NOTE
//@ compile-flags: -Znext-solver=globally


trait Trait_b88f8db {
    const ASSOC<const N: usize>: usize;
    //~^ NOTE it contains generic associated const `ASSOC`
}

fn main_88f8db37_b88f8db() {
    let _: dyn Trait_b88f8db;
    //~^ ERROR the trait `Trait_b88f8db` is not dyn compatible
}

fn main() {

    println!("FFL Fusion Done");
}
