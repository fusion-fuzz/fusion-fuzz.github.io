enable wgpu_int16;

var<private> x: f32 = 1.5;

@compute @workgroup_size(1)
fn main() {
  let y = i16(x);
  _ = y;
}
