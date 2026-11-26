#![feature(rustc_attrs)]
#![crate_type = "lib"]
//! Regression test for <https://github.com/rust-lang/rust/issues/18919>.
use std::ffi::VaList;
//@ check-fail
//@ normalize-stderr: "randomization_seed: \d+" -> "randomization_seed: $$SEED"
//@ normalize-stderr: "pointer is 0\.\.=\d+" -> "pointer is 0..=$$MAX"
//@ normalize-stderr: "in_memory_order: \[[^\]]+\]" -> "in_memory_order: $$MEMORY_INDEX"
//@ normalize-stderr: "offsets: \[[^\]]+\]" -> "offsets: $$OFFSETS"
//@ revisions: x86_64 aarch64 win
//@ compile-flags: -O
//@ [x86_64] only-x86_64
//@ [x86_64] ignore-windows
//@ [x86_64] ignore-uefi
//@ [aarch64] only-aarch64
//@ [aarch64] ignore-windows
//@ [aarch64] ignore-apple
//@ [aarch64] ignore-uefi
// Windows doesn't use `#[rustc_pass_indirectly_in_non_rustic_abis]` and is tested in CI, so is here
// for comparison.
//@ [win] only-windows
//@ [win] only-x86_64


// Can't use `minicore` here as this is testing the implementation in `core::ffi` specifically.

#[rustc_abi(debug)]

type FuncType<'f> = dyn Fn(&isize) -> isize + 'f;

pub extern "C" fn take_va_list(_: VaList<'_>) {}
//~^ ERROR fn_abi_of(take_va_list) = FnAbi {
//[x86_64]~^^ ERROR mode: Indirect {
//[x86_64]~^^^ ERROR on_stack: false,
//[aarch64]~^^^^ ERROR mode: Indirect {
//[aarch64]~^^^^^ ERROR on_stack: false,
//[win]~^^^^^^ ERROR mode: Direct(

#[cfg(all(target_arch = "x86_64", not(windows)))]
#[rustc_abi(debug)]
pub extern "sysv64" fn take_va_list_sysv64(_: VaList<'_>) {}
//[x86_64]~^ ERROR fn_abi_of(take_va_list_sysv64) = FnAbi {
//[x86_64]~^^ ERROR mode: Indirect {
//[x86_64]~^^^ ERROR on_stack: false,

#[cfg(all(target_arch = "x86_64", not(windows)))]
#[rustc_abi(debug)]
pub extern "win64" fn take_va_list_win64(_: VaList<'_>) {}
//[x86_64]~^ ERROR: fn_abi_of(take_va_list_win64) = FnAbi {
//[x86_64]~^^ ERROR mode: Indirect {
//[x86_64]~^^^ ERROR on_stack: false,
fn ho_func(f: Option<FuncType>) {
    //~^ ERROR the size for values of type
}

enum Option<T> {
    Some(T),
    None,
}

fn main_e44d34b4() {}
fn main() {}
