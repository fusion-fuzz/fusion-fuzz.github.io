#![no_std]
#![no_main]
#![feature(lang_items)]
//@ compile-flags:-C panic=abort



// Seed A (non-inlined items)
//@ normalize-stderr: "loaded from .*liballoc-.*.rmeta" -> "loaded from SYSROOT/liballoc-*.rmeta"

#[lang = "owned_box"]
struct Foo<T>(T); //~ ERROR E0152



// Seed B (non-inlined items)
//@ compile-flags:-C panic=abort


#[panic_handler] //~ ERROR attribute cannot be used on statics
#[panic_handler] //~ ERROR attribute cannot be used on statics
static X: u32 = 42;

//~? ERROR `#[panic_handler]` function required, but not found
static X_d37585b: u32 = 42;

//~? ERROR `#[panic_handler]` function required, but not found

fn main_37585b6e() {

    println!("FFL Fusion Done");
}
fn main() {}
