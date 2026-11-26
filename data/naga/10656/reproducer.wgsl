enable dual_source_blending;
struct FragmentOutput {
    @location(0) @blend_src(0) a: vec4<f32>,
    @location(0) @blend_src(1) b: vec4<f32>,
    c: f32,
}
@fragment
fn main() -> FragmentOutput { return FragmentOutput(); }
