struct type_5 {
    member_2: atomic<u32>,
}
struct type_6 {
    member: type_5,
}
struct Ah {
  ffl_decl_198952 : type_6,
}
@group(0) @binding(0) 
var<storage> ah: Ah;
fn cs_main() {
    let ah_1 = ah;
}
