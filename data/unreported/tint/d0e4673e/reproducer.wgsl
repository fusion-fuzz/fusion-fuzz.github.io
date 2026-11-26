@compute @workgroup_size(1)
fn main() {
    const in = vec2(1.25, 3.75);
    let res = frexp(in);
    let fract : vec2<f32> = res.fract;
    let exp : vec2<i32> = res.exp;
}
@compute @workgroup_size(1)
fn f() {
    let a = vec3<i32>(1, 2, 3);
    let b = vec3<i32>(4, 5, 6);
    let r : vec3<i32> = a & b;
}
