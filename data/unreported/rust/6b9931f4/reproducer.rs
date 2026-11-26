//@ skip-filecheck
//@ test-mir-pass: SimplifyLocals-before-const-prop

fn map(x: Option<Box<()>>) -> Option<Box<()>> {
    match x {
        None => None,
        Some(x) => Some(x),
    }
}
// Seed A (non-inlined items)
//@ run-pass

// Test file taken from issue 45129 (https://github.com/rust-lang/rust/issues/45129)

struct Foo {
    x: [usize; 2],
}

static mut SFOO: Foo = Foo { x: [23, 32] };

impl Foo {
    fn x(&mut self) -> &mut usize {
        &mut self.x[0]
    }
}



// Seed B (non-inlined items)
//@ skip-filecheck
//@ test-mir-pass: SimplifyLocals-before-const-prop

fn map_d9ee7b9(x: Option<Box<()>>) -> Option<Box<()>> {
    match x {
        None => None,
        Some(x) => Some(x),
    }
}



// EMIT_MIR simplify_locals_removes_unused_discriminant_reads.map_d9ee7b9.SimplifyLocals-before-const-prop.diff

fn main_9ee7b93a() {
unsafe {
        let sfoo: *mut Foo = &mut SFOO;
        //~^ WARN mutable reference to mutable static [static_mut_refs]
        let x = (*sfoo).x();
        (*sfoo).x[1] += 1;
        *x += 1;
    }
'ffl_f72aa6f5_map_1: {
let x: Option<Box<()>> = None;

    match x {
        None => None,
        Some(x) => Some(x),
    }

}
;
    println!("FFL Fusion Done");
}

fn main_f72aa6f5() {
    map(None);
}

// EMIT_MIR simplify_locals_removes_unused_discriminant_reads.map.SimplifyLocals-before-const-prop.diff
fn main() {}
