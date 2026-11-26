
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -emit-llvm -o %t %s
// RUN: %clang_cc1 -x objective-c++ -triple x86_64-apple-darwin10 -emit-llvm -o %t %s

@interface Super {
  int ivar_super_a : 5;
}
@end

@interface A : Super {
@public
  int ivar_a : 5;
}
@end

int f0(A *a) {
  return a->ivar_a;
}

@interface A () {
@public
  int ivar_ext_a : 5;
  int ivar_ext_b : 5;
}@end

int f1(A *a) {
  return a->ivar_ext_a + a->ivar_a;
}

@interface A () {
@public
  int ivar_ext2_a : 5;
  int ivar_ext2_b : 5;
}@end

int f2(A* a) {
  return a->ivar_ext2_a + a->ivar_ext_a + a->ivar_a;
}

@implementation A {

// Same reasoning as S3.
struct S4 {
  union {
    int x;
  };
  static const int test0 = __alignof__(x);
  static const int test1 = __alignof__(S0::x);
  auto test2() -> char(&)[__alignof__(x)];
};

// Regression test for asking for the alignment of a field within an invalid
// record.
struct S5 {
  S1 s;  // expected-error {{incomplete type}}
  int x;
};
const int test8 = __alignof__(S5::x);

int test14[2];

static_assert(alignof(test14) == 4, "foo"); // expected-warning {{'alignof' applied to an expression is a GNU extension}}

// PR19992
static_assert(alignof(int[]) == alignof(int), ""); // ok

namespace alignof_array_expr {
  alignas(32) extern int n[];
  static_assert(alignof(n) == 32, ""); // expected-warning {{GNU extension}}

  template<int> struct S {
    static int a[];
  };
  template<int N> int S<N>::a[N];
  // ok, does not complete type of S<-1>::a
  static_assert(alignof(S<-1>::a) == alignof(int), ""); // expected-warning {{GNU extension}}
}

template <typename T> void n(T) {
  alignas(T) int T1;
  char k[__alignof__(T1)];
  static_assert(sizeof(k) == alignof(long long), "");
}
template void n(long long);

namespace PR22042 {
template <typename T>
void Fun(T A) {
  typedef int __attribute__((__aligned__(A))) T1; // expected-error {{requested alignment is dependent but declaration is not dependent}}
  int k1[__alignof__(T1)];
}

template <int N>
struct S {
  typedef __attribute__((aligned(N))) int Field[sizeof(N)]; // expected-error {{requested alignment is dependent but declaration is not dependent}}
};
}

typedef int __attribute__((aligned(16))) aligned_int;
template <typename>
using template_alias = aligned_int;
static_assert(alignof(template_alias<void>) == 16, "Expected alignment of 16" );

struct PR47138 {
  invalid_type a; // expected-error {{unknown type}}
};
static_assert(__alignof__(PR47138) == 1, ""); // Don't crash.
@public
  int ivar_b : 5;
  int ivar_c : 5;
  int ivar_d : 5;
}
@end

int f3(A *a) {  
  return a->ivar_d + a->ivar_ext2_a + a->ivar_ext_a + a->ivar_a;
}
