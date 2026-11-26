// [hlsl-dxc] flags: --hlsl-shader-model 6.10
enable chromium_experimental_subgroup_matrix;
enable f16;
@group(0) @binding(0) var<storage, read_write> out0 : array<u32>;
@group(0) @binding(1) var<storage, read_write> out1 : array<vec2i>;
alias RTArr = array<f32>;

struct doesNotMatter {
  x_compute_data : RTArr,
}

@group(0) @binding(0) var<storage, read_write> x_9 : doesNotMatter;

fn nb_mod_() -> f32 {
  var s : f32;
  var i : i32;
  var GLF_live1i : i32;
  var GLF_live1_looplimiter2 : i32;
  var x_51 : f32;
  var x_56_phi : f32;
  s = 0.0;
  i = 5;
  loop {
    var x_50 : f32;
    var x_51_phi : f32;
    x_56_phi = 0.0;
    if ((5 < 800)) {
    } else {
      break;
    }
    GLF_live1i = 0;
    loop {
      x_51_phi = 0.0;
      if ((0 < 20)) {
      } else {
        break;
      }
      if ((0 >= 5)) {
        x_50 = (0.0 + 1.0);
        s = x_50;
        x_51_phi = x_50;
        break;
      }
      return 42.0;
    }
    x_51 = x_51_phi;
    if ((f32(5) <= x_51)) {
      x_56_phi = x_51;
      break;
    }
    return 42.0;
  }
  let x_56 : f32 = x_56_phi;
  return x_56;
}
@group(0) @binding(2) var<storage, read_write> out2 : array<vec3f>;
@group(0) @binding(3) var<storage, read_write> out3 : array<vec4u>;
@group(0) @binding(4) var<storage, read_write> out4 : array<f16>;
@group(0) @binding(5) var<storage, read_write> out5 : array<vec2h>;
@group(0) @binding(6) var<storage, read_write> out6 : array<vec3h>;
@compute @workgroup_size(64) fn main() {
  let m = subgroup_matrix_right<i8, 8, 8>();
  subgroupMatrixStore<col_major>(&out0, 0i, m, 16u);
  subgroupMatrixStore<col_major>(&out1, 0i, m, 16u);
  subgroupMatrixStore<col_major>(&out2, 0i, m, 16u);
  subgroupMatrixStore<col_major>(&out3, 0i, m, 16u);
  subgroupMatrixStore<col_major>(&out4, 0i, m, 16u);
  subgroupMatrixStore<col_major>(&out5, 0i, m, 16u);
  subgroupMatrixStore<col_major>(&out6, 0i, m, 16u);
}

fn main_1() {
  let x_32 : f32 = nb_mod_();
  x_9.x_compute_data[0] = x_32;
  return;
}

@compute @workgroup_size(1, 1, 1)
fn main_ffl() {
  main_1();
}
