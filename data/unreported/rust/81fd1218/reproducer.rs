#![feature(link_llvm_intrinsics)]

extern "llvm-intrinsic" {
    #[link_name = "llvm.assume"]
    fn foo(); // wrong signature: llvm.assume is void (i1)
}

fn main() {
    unsafe { foo() }
    drop(Box::new(1u8));
}
