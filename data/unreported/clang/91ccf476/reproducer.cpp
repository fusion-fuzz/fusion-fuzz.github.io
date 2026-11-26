
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: BuildDecltypeType
// EXPECT-CRASH-ASSERT: hasPlaceholderType
// EXPECT-CRASH-ASSERT: unexpected

static_assert(is_const < decltype(__builtin_elementwise_atan22<>), "");

static long ffl_fusion = (long)(is_const);

// RUN: %clang_cc1 %s -emit-llvm -o - | grep noalias

void * __attribute__ ((ffl_fusion)) foo (void) { return 0; }
