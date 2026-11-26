enable wgpu_binding_array;
@group(0) @binding(0)
var t: binding_array<texture_storage_2d<rgba32float, write>, 5>;

fn f() {
  let x = t[1u];
}

@compute @workgroup_size(1)
fn main() {
  f();
}
