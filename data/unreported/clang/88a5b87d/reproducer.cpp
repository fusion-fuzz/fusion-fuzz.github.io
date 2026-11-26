// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CheckConvertedConstantExpression
// EXPECT-CRASH-ASSERT: isIntegralOrEnumerationType
// EXPECT-CRASH-ASSERT: unexpected

enum struct __attribute__((mode(SF))) E { foo = 42 };

static long ffl_fusion = (long)(E);

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CheckBaseSpecifier
// EXPECT-CRASH-ASSERT: BaseDecl
// EXPECT-CRASH-ASSERT: incomplete

class A {
  template <typename T> struct S1;
  template <typename T>
  template <typename I>
  struct S1<T>::S2 : S1<T> void ffl_fusion();
};
