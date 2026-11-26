#include "MoveOnly.h"
#include "test_macros.h"
#include <cuda/std/cassert>
#include <cuda/std/concepts>
#include <cuda/std/ranges>
#include <cuda/std/utility>
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
//===----------------------------------------------------------------------===//
//
// Part of libcu++, the C++ Standard Library for your entire system,
// under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES.
//
//===----------------------------------------------------------------------===//

// cuda::std::views::single









// Can't invoke without arguments.
static_assert(!cuda::std::is_invocable_v<decltype((cuda::std::views::single))>);
// Can invoke with a move-only type.
static_assert(cuda::std::is_invocable_v<decltype((cuda::std::views::single)), MoveOnly>);

TEST_FUNC constexpr bool vec16_a()
{
  // Lvalue.
  {
    int x            = 42;
    decltype(auto) v = cuda::std::views::single(x);
    static_assert(cuda::std::same_as<decltype(v), cuda::std::ranges::single_view<int>>);
    assert(v.size() == 1);
    assert(v.front() == x);
  }

  // Prvalue.
  {
    decltype(auto) v = cuda::std::views::single(42);
    static_assert(cuda::std::same_as<decltype(v), cuda::std::ranges::single_view<int>>);
    assert(v.size() == 1);
    assert(v.front() == 42);
  }

  // Const lvalue.
  {
    const int x      = 42;
    decltype(auto) v = cuda::std::views::single(x);
    static_assert(cuda::std::same_as<decltype(v), cuda::std::ranges::single_view<int>>);
    assert(v.size() == 1);
    assert(v.front() == x);
  }

  // Xvalue.
  {
    int x            = 42;
    decltype(auto) v = cuda::std::views::single(cuda::std::move(x));
    static_assert(cuda::std::same_as<decltype(v), cuda::std::ranges::single_view<int>>);
    assert(v.size() == 1);
    assert(v.front() == x);
  }

  return true;
}

// r600-error@+1 2 {{__bf16 is not supported on this target}}
__bf16 hostfn(__bf16 a) {
  return a;
}

// r600-error@+2 {{__bf16 is not supported on this target}}
// r600-error@+1 {{vector size not an integral multiple of component size}}
typedef __bf16 foo __attribute__((__vector_size__(16), __aligned__(16)));

int main(int, char**)
{
  vec16_a();
#if defined(_CCCL_BUILTIN_ADDRESSOF)
  static_assert(vec16_a());
#endif // _CCCL_BUILTIN_ADDRESSOF

  return 0;
}

// REQUIRES: amdgpu-registered-target
// REQUIRES: x86-registered-target

// RUN: %clang_cc1 "-aux-triple" "x86_64-unknown-linux-gnu" "-triple" "r600-unknown-unknown"\
// RUN:    -fcuda-is-device "-aux-target-cpu" "x86-64" -fsyntax-only -verify=r600 %s

// AMDGCN has storage-only support for bf16. R600 does not support it should error out when
// it's the main target.
// There should be no errors on using the type itself, or when loading/storing values for amdgcn.
// r600 should error on all uses of the type.

// r600-error@+1 {{__bf16 is not supported on this target}}
// r600-error@+1 {{__bf16 is not supported on this target}}
// r600-error@+1 {{__bf16 is not supported on this target}}
// r600-error@+1 {{__bf16 is not supported on this target}}

// r600-error@+1 2 {{__bf16 is not supported on this target}}
__device__ void x(bool b, __bf16 *out, __bf16 in) {
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

// r600-error@+1 2 {{__bf16 is not supported on this target}}

// r600-error@+2 {{__bf16 is not supported on this target}}
// r600-error@+1 {{vector size not an integral multiple of component size}}
