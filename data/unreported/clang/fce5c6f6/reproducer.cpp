
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: VisitCastExpr
// EXPECT-CRASH-ASSERT: hasSameUnqualifiedType
// EXPECT-CRASH-ASSERT: Implicit

void foo(char8_t u8) { (int[])(u8 == U'\u00FF'); }

// RUN: not %clang -target powerpc64le-unknown-linux-gnu -fsyntax-only \
// RUN:   -mcpu=pwr9 -mfloat128 %s 2>&1 | FileCheck %s --check-prefix=HASF128
// RUN: not %clang -target powerpc64le-unknown-linux-gnu -fsyntax-only \
// RUN:   -mcpu=power9 -mfloat128 %s 2>&1 | FileCheck %s --check-prefix=HASF128
// RUN: not %clang -target powerpc64le-unknown-linux-gnu -fsyntax-only \
// RUN:   -mcpu=pwr8 -mfloat128 %s 2>&1 | FileCheck %s --check-prefix=HASF128
// RUN: not %clang -target powerpc64le-unknown-linux-gnu -fsyntax-only \
// RUN:   -mcpu=pwr7 -mfloat128 %s 2>&1 | FileCheck %s --check-prefix=HASF128
// RUN: not %clang -target powerpc64le-unknown-linux-gnu -fsyntax-only \
// RUN:   -mfloat128 %s 2>&1 | FileCheck %s --check-prefix=HASF128

static_assert(false, "__float128 enabled");
#endif

// HASF128: __float128 enabled
// HASF128-NOT: option '-mfloat128' cannot be specified with
// NOF128: option '-mfloat128' cannot be specified with
// RUN: not %clang -target powerpc64le-unknown-linux-gnu -fsyntax-only \
// RUN:   -mcpu=pwr6 -mfloat128 %s 2>&1 | FileCheck %s --check-prefix=NOF128
// RUN: not %clang -target powerpc64le-unknown-linux-gnu -fsyntax-only \
// RUN:   -mno-vsx -mfloat128 %s 2>&1 | FileCheck %s --check-prefix=NOF128

#ifdef __FLOAT128__
static_assert(false, "__float128 enabled");
#endif

// HASF128: __float128 enabled
// HASF128-NOT: option '-mfloat128' cannot be specified with
// NOF128: option '-mfloat128' cannot be specified with
