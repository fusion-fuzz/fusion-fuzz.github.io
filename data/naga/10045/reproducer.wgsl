struct AtomicStruct {
    atomic_arr: array<atomic<i32>, 2>,
}
struct Ah {
  ffl_decl_891457 : AtomicStruct,
}
@group(0) @binding(0)
var<storage> ah: Ah;
fn cs_main() {
    let ah = ah;
}
