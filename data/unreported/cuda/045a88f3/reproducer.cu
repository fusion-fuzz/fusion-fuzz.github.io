#include <cuda/std/utility>
#include <thrust/execution_policy.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include <thrust/transform.h>
#include <unittest/unittest.h>
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









// r600-error@+1 2 {{__bf16 is not supported on this target}}
__bf16 hostfn(__bf16 a) {
  return a;
}

// r600-error@+2 {{__bf16 is not supported on this target}}
// r600-error@+1 {{vector size not an integral multiple of component size}}
typedef __bf16 foo __attribute__((__vector_size__(16), __aligned__(16)));

#ifdef THRUST_TEST_DEVICE_SIDE
template <typename ExecutionPolicy, typename Iterator1, typename Iterator2>
__global__ void
stable_sort_by_key_kernel(ExecutionPolicy exec, Iterator1 keys_first, Iterator1 keys_last, Iterator2 values_first)
{
  thrust::stable_sort_by_key(exec, keys_first, keys_last, values_first);
}

struct make_pair_functor
{
  template <typename T1, typename T2>
  _CCCL_HOST_DEVICE cuda::std::pair<T1, T2> operator()(const T1& x, const T2& y)
  {
    return cuda::std::make_pair(x, y);
  } // end operator()()
}; // end make_pair_functor

template <typename ExecutionPolicy>
void TestPairStableSortByKeyDevice(ExecutionPolicy exec)
{
  size_t n = 10000;
  using P  = cuda::std::pair<int, int>;

  // host arrays
  thrust::host_vector<int> h_p1 = unittest::random_integers<int>(n);
  thrust::host_vector<int> h_p2 = unittest::random_integers<int>(n);
  thrust::host_vector<P> h_pairs(n);

  thrust::host_vector<int> h_values(n);
  thrust::sequence(h_values.begin(), h_values.end());

  // zip up pairs on the host
  thrust::transform(h_p1.begin(), h_p1.end(), h_p2.begin(), h_pairs.begin(), make_pair_functor());

  // device arrays
  thrust::device_vector<P> d_pairs    = h_pairs;
  thrust::device_vector<int> d_values = h_values;

  // sort on the device
  stable_sort_by_key_kernel<<<1, 1>>>(exec, d_pairs.begin(), d_pairs.end(), d_values.begin());
  cudaError_t const err = cudaDeviceSynchronize();
  REQUIRE(cudaSuccess == err);

  // sort on the host
  thrust::stable_sort_by_key(h_pairs.begin(), h_pairs.end(), h_values.begin());

  REQUIRE((h_pairs == d_pairs));
  REQUIRE(h_values == d_values);
};

TEST_CASE("TestPairStableSortByKeyDeviceSeq", "[pair_sort_by_key]")
{
  TestPairStableSortByKeyDevice(thrust::seq);
}

TEST_CASE("TestPairStableSortByKeyDeviceDevice", "[pair_sort_by_key]")
{
  TestPairStableSortByKeyDevice(thrust::device);
}
#endif
