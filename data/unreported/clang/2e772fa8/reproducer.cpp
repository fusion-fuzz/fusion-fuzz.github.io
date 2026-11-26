
// RUN: %clang_cc1 %s -emit-llvm -o - | grep noalias

void * __attribute__ ((malloc)) foo (void) { return 0; }

static long ffl_fusion = (long)(malloc);

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: APInt
// EXPECT-CRASH-ASSERT: isIntN
// EXPECT-CRASH-ASSERT: N-bit

template <typename T, int ffl_fusion> struct S;

template <typename T> struct S<T, 1> {
  typedef T foo __attribute__((ext_vector_type(0xdeadbeef)));
};
void bar_ffl() { char1 baz{42}; }

using char1 = S<char, 1>;

void bar() { char1 baz{42}; }
