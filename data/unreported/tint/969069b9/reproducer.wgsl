var<private> u : vec4<i32> = vec4<i32>(vec4<f32>(1.0f));
override size = 2;

@compute @workgroup_size(1)
fn main() {
    _ = u;
}

var<workgroup> a : array<f32, size>;

@compute @workgroup_size(1)
fn main_ffl() {
    _ = a[0];
}
