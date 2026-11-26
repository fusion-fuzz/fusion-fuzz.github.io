const foo: array<u32, 65> = array<u32, 65>(
);
fn main_ffl2() {
  let ballot: vec4<u32> = select(vec4<u32>(0u), vec4<u32>(0xffffffffu), foo);
}
