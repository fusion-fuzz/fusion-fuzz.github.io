// REQUIRES: amdgpu-registered-target
// REQUIRES: x86-registered-target

// RUN: %clang_cc1 "-aux-triple" "x86_64-unknown-linux-gnu" "-triple" "r600-unknown-unknown"\
// RUN:    -fcuda-is-device "-aux-target-cpu" "x86-64" -fsyntax-only -verify=r600 %s

// AMDGCN has storage-only support for bf16. R600 does not support it should error out when
// it's the main target.
// There should be no errors on using the type itself, or when loading/storing values for amdgcn.
// r600 should error on all uses of the type.

// r600-error@+1 {{__bf16 is not supported on this target}}
typedef __attribute__((ext_vector_type(2))) __bf16 bf16_x2;
// r600-error@+1 {{__bf16 is not supported on this target}}
typedef __attribute__((ext_vector_type(4))) __bf16 bf16_x4;
// r600-error@+1 {{__bf16 is not supported on this target}}
typedef __attribute__((ext_vector_type(8))) __bf16 bf16_x8;
// r600-error@+1 {{__bf16 is not supported on this target}}
typedef __attribute__((ext_vector_type(16))) __bf16 bf16_x16;

// r600-error@+1 2 {{__bf16 is not supported on this target}}
__device__ void test(bool b, __bf16 *out, __bf16 in) {
  __bf16 bf16 = in;  // r600-error {{__bf16 is not supported on this target}}
  *out = bf16;

  // r600-error@+1 {{__bf16 is not supported on this target}}
  typedef __attribute__((ext_vector_type(2))) __bf16 bf16_x2;
  bf16_x2 vec2_a, vec2_b;
  vec2_a = vec2_b;

  // r600-error@+1 {{__bf16 is not supported on this target}}
  typedef __attribute__((ext_vector_type(4))) __bf16 bf16_x4;
  bf16_x4 vec4_a, vec4_b;
  vec4_a = vec4_b;

  // r600-error@+1 {{__bf16 is not supported on this target}}
  typedef __attribute__((ext_vector_type(8))) __bf16 bf16_x8;
  bf16_x8 vec8_a, vec8_b;
  vec8_a = vec8_b;

  // r600-error@+1 {{__bf16 is not supported on this target}}
  typedef __attribute__((ext_vector_type(16))) __bf16 bf16_x16;
  bf16_x16 vec16_a, vec16_b;
  vec16_a = vec16_b;
}

// RUN: %clang_cc1 -triple amdgpu9.06-amd-amdhsa -fcuda-is-device -x hip %s \
// RUN:   -fgpu-rdc -std=c++11 -emit-llvm -o - | FileCheck %s
// CHECK-LABEL: @__clang_gpu_used_external = internal {{.*}}global
// References to the kernels must be in order of appearance.
// CHECK-SAME: [ptr @_Z6kernelILi3EEvPi, ptr @_Z6kernelILi1EEvPi, ptr @_Z6kernelILi2EEvPi, ptr @_Z6kernelILi0EEvPi]

template <int N>
__global__ void kernel(int* out) { *out = N; }

// r600-error@+1 2 {{__bf16 is not supported on this target}}
__bf16 hostfn(__bf16 a) {
  return a;
}

// r600-error@+2 {{__bf16 is not supported on this target}}
// r600-error@+1 {{vector size not an integral multiple of component size}}
typedef __bf16 foo __attribute__((__vector_size__(16), __aligned__(16)));

void host(int n) {
    void * k;
    switch (n) {
        case 3: k = (void*)&kernel<3>; break;
        case 1: k = (void*)&kernel<1>; break;
        case 2: k = (void*)&kernel<2>; break;
        case 0: k = (void*)&kernel<0>; break;
    }
}
