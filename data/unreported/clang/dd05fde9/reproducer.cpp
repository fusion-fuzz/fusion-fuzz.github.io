#include "builtin_test_helpers.h"
#include <immintrin.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getSExtValue
// EXPECT-CRASH-ASSERT: getSignificantBits
// EXPECT-CRASH-ASSERT: int64_t

enum F { e = (__int128)-1 };

constexpr int foo() {
  F f = (F)(__int128)1e19;
  return (int)f;
}

  // CHECK-LABEL: test_mm512_maskz_shldv_epi16
  // CHECK: call <32 x i16> @llvm.fshl.v32i16(<32 x i16> %{{.*}}, <32 x i16> %{{.*}}, <32 x i16> %{{.*}})
  // CHECK: select <32 x i1> %{{.*}}, <32 x i16> %{{.*}}, <32 x i16> %{{.*}}
  return _mm512_maskz_shldv_epi16(__U, __S, __A, __B);
static_assert(foo() == 1e19, "");
