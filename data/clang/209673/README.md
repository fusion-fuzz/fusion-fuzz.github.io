*Fusion-Fuzz Bug Report*

**ID:** `1efde3ba` &nbsp;·&nbsp; **Signature:** `Assertion: !ResultType.isNull() && (ResultType->isVectorType() || ResultType->isSizelessVectorType()) && (!CondType->isExtVectorType() || ResultType->isExtVectorType()) && "Result should have been a vector type"` &nbsp;·&nbsp; **RC:** `134`

The following code:

```cpp
// RUN: %clang_cc1 -triple x86_64-apple-darwin -emit-llvm -o - %s | FileCheck %s

#pragma GCC visibility push(hidden)
int x = 2;
// CHECK: @x = hidden global

extern int y;
#pragma GCC visibility pop
int y = 4;
// CHECK: @y = hidden global

#pragma GCC visibility push(hidden)
extern __attribute((visibility("default"))) int z;
int z = 0;
// CHECK: @z ={{.*}} global
#pragma GCC visibility pop

#pragma GCC visibility push(hidden)
void f(void) {}
// CHECK-LABEL: define hidden void @f

__attribute((visibility("default"))) void g(void);
void g(void) {}
// CHECK-LABEL: define{{.*}} void @g

static long ffl_fusion = (long)(g);

// RUN: %clang_cc1 -triple x86_64-linux-pc -fsyntax-only -verify -fexceptions -fcxx-exceptions %s -std=c++17
// Note that this test depends on the size of long-long to be different from
// int, so it specifies a triple.

using FourShorts = short __attribute__((ext_vector_type(4)));
using TwoInts = int __attribute__((ext_vector_type(2)));
using TwoUInts = unsigned __attribute__((ext_vector_type(2)));
using FourInts = int __attribute__((ext_vector_type(4)));
using FourUInts = unsigned __attribute__((ext_vector_type(4)));
using TwoLongLong = long long __attribute__((ext_vector_type(2)));
using FourLongLong = long long __attribute__((ext_vector_type(4)));
using TwoFloats = float __attribute__((ext_vector_type(2)));
using FourFloats = float __attribute__((ext_vector_type(4)));
using TwoDoubles = double __attribute__((ext_vector_type(2)));
using FourDoubles = double __attribute__((ext_vector_type(4)));

FourShorts four_shorts;
TwoInts two_ints;
TwoUInts two_uints;
FourInts four_ints;
FourUInts four_uints;
TwoLongLong two_ll;
FourLongLong four_ll;
TwoFloats two_floats;
FourFloats four_floats;
TwoDoubles two_doubles;
FourDoubles four_doubles;

enum E {};
enum class SE {};
E e;
SE se;

// Check the rules of the condition of the conditional operator.
void Condition() {
  // Only int types are allowed here, the rest should fail to convert to bool.
  (void)(four_floats ? 1 : 1); // expected-error {{is not contextually convertible to 'bool'}}}
  (void)(two_doubles ? 1 : 1); // expected-error {{is not contextually convertible to 'bool'}}}
}

// Check the rules of the LHS/RHS of the conditional operator.
void Operands() {
  (void)(four_ints ? four_ints : throw 1); // expected-error {{GNU vector conditional operand cannot be a throw expression}}
  (void)(four_ints ? throw 1 : four_ints); // expected-error {{GNU vector conditional operand cannot be a throw expression}}
  (void)(four_ints ?: throw 1);            // expected-error {{GNU vector conditional operand cannot be a throw expression}}
  (void)(four_ints ? (void)1 : four_ints); // expected-error {{GNU vector conditional operand cannot be void}}
  (void)(four_ints ?: (void)1);            // expected-error {{GNU vector conditional operand cannot be void}}

  // Vector types must be the same element size as the condition.
  (void)(four_ints ? two_ll : two_ll);             // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'TwoLongLong' (vector of 2 'long long' values) do not have the same number of elements}}
  (void)(four_ints ? four_ll : four_ll);           // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'FourLongLong' (vector of 4 'long long' values) do not have elements of the same size}}
  (void)(four_ints ? two_doubles : two_doubles);   // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'TwoDoubles' (vector of 2 'double' values) do not have the same number of elements}}
  (void)(four_ints ? four_doubles : four_doubles); // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'FourDoubles' (vector of 4 'double' values) do not have elements of the same size}}
  (void)(four_ints ?: two_ints);                   // expected-error {{vector operands to the vector conditional must be the same type ('FourInts' (vector of 4 'int' values) and 'TwoInts' (vector of 2 'int' values)}}
  (void)(four_ints ?: four_doubles);               // expected-error {{vector operands to the vector conditional must be the same type ('FourInts' (vector of 4 'int' values) and 'FourDoubles' (vector of 4 'double' values)}}

  // Scalars are promoted, but must be the same element size.
  (void)(four_ints ? 3.0f : 3.0); // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'double __attribute__((ext_vector_type(4)))' (vector of 4 'double' values) do not have elements of the same size}}
  (void)(four_ints ? 5ll : 5);    // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'long long __attribute__((ext_vector_type(4)))' (vector of 4 'long long' values) do not have elements of the same size}}
  (void)(four_ints ?: 3.0);       // expected-error {{annot convert between vector values of different size ('FourInts' (vector of 4 'int' values) and 'double')}}
  (void)(four_ints ?: 5ll);       // We allow this despite GCc not allowing this since we support integral->vector-integral conversions despite integer rank.

  // This one would be allowed in GCC, but we don't allow vectors of enum. Also,
  // the error message isn't perfect, since it is only going to be a problem
  // when both sides are an enum, otherwise it'll be promoted to whatever type
  // the other side causes.
  (void)(four_ints ? e : e);                          // expected-error {{enumeration type 'E' is not allowed in a vector conditional}}
  (void)(four_ints ? se : se);                        // expected-error {{enumeration type 'SE' is not allowed in a vector conditional}}
  (void)(four_shorts ? (short)5 : (unsigned short)5); // expected-error {{vector condition type 'FourShorts' (vector of 4 'short' values) and result type 'int __attribute__((ext_vector_type(4)))' (vector of 4 'int' values) do not have elements of the same size}}

  // They must also be convertible.
  (void)(four_ints ? 3.0f : 5u);
  (void)(four_ints ? 3.0f : 5);
  unsigned us = 5u;
  int sint = 5;
  short shrt = 5;
  unsigned short uss = 5u;
  // The following 2 error in GCC for truncation errors, but it seems
  // unimportant and inconsistent to enforce that rule.
  (void)(four_ints ? 3.0f : us);
  (void)(four_ints ? 3.0f : sint);

  // Test promotion:
  (void)(four_shorts ? uss : shrt);  // expected-error {{vector condition type 'FourShorts' (vector of 4 'short' values) and result type 'int __attribute__((ext_vector_type(4)))' (vector of 4 'int' values) do not have elements of the same size}}
  (void)(four_shorts ? shrt : shrt); // should be fine.
  (void)(four_ints ? uss : shrt);    // should be fine, since they get promoted to int.
  (void)(four_ints ? shrt : shrt);   // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'short __attribute__((ext_vector_type(4)))' (vector of 4 'short' values) do not have elements of the same size}}

  // Vectors must be the same type as each other.
  (void)(four_ints ? four_uints : four_floats); // expected-error {{vector operands to the vector conditional must be the same type ('FourUInts' (vector of 4 'unsigned int' values) and 'FourFloats' (vector of 4 'float' values))}}
  (void)(four_ints ? four_uints : four_ints);   // expected-error {{vector operands to the vector conditional must be the same type ('FourUInts' (vector of 4 'unsigned int' values) and 'FourInts' (vector of 4 'int' values))}}
  (void)(four_ints ? four_ints : four_uints);   // expected-error {{vector operands to the vector conditional must be the same type ('FourInts' (vector of 4 'int' values) and 'FourUInts' (vector of 4 'unsigned int' values))}}

  (void)(four_ints ? four_uints : 3.0f); // expected-error {{cannot convert between vector values of different size ('FourUInts' (vector of 4 'unsigned int' values) and 'float')}}
  (void)(four_ints ? four_ints : 3.0f);  // expected-error {{cannot convert between vector values of different size ('FourInts' (vector of 4 'int' values) and 'float')}}

  // When there is a vector and a scalar, conversions must be legal.
  (void)(four_ints ? four_floats : 3); // should work, ints can convert to floats.
  (void)(four_ints ? four_uints : e);  // expected-error {{cannot convert between vector values of different size ('FourUInts' (vector of 4 'unsigned int' values) and 'E')}}
  (void)(four_ints ? four_uints : se); // expected-error {{cannot convert between vector and non-scalar values ('FourUInts' (vector of 4 'unsigned int' values) and 'SE'}}

  (void)(two_ints ? two_ints : us);
  (void)(four_shorts ? four_shorts : uss);
  (void)(four_ints ? four_floats : us);
  (void)(four_ints ? four_floats : sint);
}

template <typename T1, typename T2>
struct is_same {
  static constexpr bool value = false;
};
template <typename T>
struct is_same<T, T> {
  static constexpr bool value = true;
};
template <typename T1, typename T2>
constexpr bool is_same_v = is_same<T1, T2>::value;
template <typename T>
T &&declval();

// Check the result types when given two vector types.
void ResultTypes() {
  // Vectors must be the same, but result is the type of the LHS/RHS.
  static_assert(is_same_v<TwoInts, decltype(declval<TwoInts>() ? declval<TwoInts>() : declval<TwoInts>())>);
  static_assert(is_same_v<TwoFloats, decltype(declval<TwoInts>() ? declval<TwoFloats>() : declval<TwoFloats>())>);

  // When both are scalars, converts to vectors of common type.
  static_assert(is_same_v<TwoUInts, decltype(declval<TwoInts>() ? declval<int>() : declval<unsigned int>())>);

  // Constant is allowed since it doesn't truncate, and should promote to float.
  static_assert(is_same_v<TwoFloats, decltype(declval<TwoInts>() ? declval<float>() : 5u)>);
  static_assert(is_same_v<TwoFloats, decltype(declval<TwoInts>() ? 5 : declval<float>())>);

  // when only 1 is a scalar, it should convert to a compatible type.
  static_assert(is_same_v<TwoFloats, decltype(declval<TwoInts>() ? declval<TwoFloats>() : declval<float>())>);
  static_assert(is_same_v<TwoInts, decltype(declval<TwoInts>() ? declval<TwoInts>() : declval<int>())>);
  static_assert(is_same_v<TwoFloats, decltype(declval<TwoInts>() ? declval<TwoFloats>() : 5)>);

  // For the Binary conditional operator, the result type is either the vector on the RHS (that fits the rules on size/count), or the scalar extended to the correct count.
  static_assert(is_same_v<TwoInts, decltype(declval<TwoInts>() ?: declval<TwoInts>())>);
  static_assert(is_same_v<TwoInts, decltype(declval<TwoInts>() ?: declval<int>())>);
}

template <typename Cond>
void dependent_cond(Cond C) {
  (void)(C ? 1 : 2);
}

template <typename Operand>
void dependent_operand(Operand C) {
  (void)(two_ints ? 1 : C);
  (void)(two_ints ? C : 1);
  (void)(two_ints ? C : C);
}

template <typename Cond, typename LHS, typename RHS>
void all_dependent(Cond C, LHS L, RHS R) {
  (void)(C ? L : R);
}

// Check dependent cases.
void Templates() {
  dependent_cond(two_ints);
  dependent_operand(two_floats);
  // expected-error@158 {{vector operands to the vector conditional must be the same type ('unsigned int __attribute__((ext_vector_type(4)))' (vector of 4 'unsigned int' values) and 'double __attribute__((ext_vector_type(4)))' (vector of 4 'double' values))}}}
  all_dependent(four_ints, four_uints, four_doubles); // expected-note {{in instantiation of}}

  // expected-error@158 {{vector operands to the vector conditional must be the same type ('unsigned int __attribute__((ext_vector_type(4)))' (vector of 4 'unsigned int' values) and 'unsigned int __attribute__((ext_vector_type(2)))' (vector of 2 'unsigned int' values))}}}
  all_dependent(four_ints, four_uints, two_uints); // expected-note {{in instantiation of}}
  all_dependent(four_ints, four_uints, four_uints);
}

using FourShortsVS = short __attribute__((__vector_size__(8)));

void mix_vector_types() {
  FourShortsVS vs;
  (vs == 1 ? four_shorts : four_shorts);
  // expected-error@-1 {{cannot mix vectors and extended vectors in a vector conditional}}

  (four_shorts == 1 ? vs : ffl_fusion);
  // expected-error@-1 {{cannot mix vectors and extended vectors in a vector conditional}}

  (four_shorts == 1 ? four_shorts : vs);
  // expected-error@-1 {{vector operands to the vector conditional must be the same type ('FourShorts' (vector of 4 'short' values) and 'FourShortsVS' (vector of 4 'short' values))}}

  (four_shorts == 1 ? vs : four_shorts);
  // expected-error@-1 {{cannot mix vectors and extended vectors in a vector conditional}}

  (vs == 1 ? vs : four_shorts);
  // expected-error@-1 {{vector operands to the vector conditional must be the same type ('FourShortsVS' (vector of 4 'short' values) and 'FourShorts' (vector of 4 'short' values))}}

  (vs == 1 ? four_shorts : vs);
  // expected-error@-1 {{cannot mix vectors and extended vectors in a vector conditional}}
}

```

Resulted in this output:

```
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:64:10: error: value of type 'FourFloats' (vector of 4 'float' values) is not contextually convertible to 'bool'
   64 |   (void)(four_floats ? 1 : 1); // expected-error {{is not contextually convertible to 'bool'}}}
      |          ^~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:65:10: error: value of type 'TwoDoubles' (vector of 2 'double' values) is not contextually convertible to 'bool'
   65 |   (void)(two_doubles ? 1 : 1); // expected-error {{is not contextually convertible to 'bool'}}}
      |          ^~~~~~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:70:34: error: GNU vector conditional operand cannot be a throw expression
   70 |   (void)(four_ints ? four_ints : throw 1); // expected-error {{GNU vector conditional operand cannot be a throw expression}}
      |                                  ^~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:71:22: error: GNU vector conditional operand cannot be a throw expression
   71 |   (void)(four_ints ? throw 1 : four_ints); // expected-error {{GNU vector conditional operand cannot be a throw expression}}
      |                      ^~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:72:23: error: GNU vector conditional operand cannot be a throw expression
   72 |   (void)(four_ints ?: throw 1);            // expected-error {{GNU vector conditional operand cannot be a throw expression}}
      |                       ^~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:73:22: error: GNU vector conditional operand cannot be void
   73 |   (void)(four_ints ? (void)1 : four_ints); // expected-error {{GNU vector conditional operand cannot be void}}
      |                      ^~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:74:23: error: GNU vector conditional operand cannot be void
   74 |   (void)(four_ints ?: (void)1);            // expected-error {{GNU vector conditional operand cannot be void}}
      |                       ^~~~~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:77:20: error: vector condition type 'FourInts' (vector of 4 'int' values) and result type 'TwoLongLong' (vector of 2 'long long' values) do not have the same number of elements
   77 |   (void)(four_ints ? two_ll : two_ll);             // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'TwoLongLong' (vector of 2 'long long' values) do not have the same number of elements}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:78:20: error: vector condition type 'FourInts' (vector of 4 'int' values) and result type 'FourLongLong' (vector of 4 'long long' values) do not have elements of the same size
   78 |   (void)(four_ints ? four_ll : four_ll);           // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'FourLongLong' (vector of 4 'long long' values) do not have elements of the same size}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:79:20: error: vector condition type 'FourInts' (vector of 4 'int' values) and result type 'TwoDoubles' (vector of 2 'double' values) do not have the same number of elements
   79 |   (void)(four_ints ? two_doubles : two_doubles);   // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'TwoDoubles' (vector of 2 'double' values) do not have the same number of elements}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:80:20: error: vector condition type 'FourInts' (vector of 4 'int' values) and result type 'FourDoubles' (vector of 4 'double' values) do not have elements of the same size
   80 |   (void)(four_ints ? four_doubles : four_doubles); // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'FourDoubles' (vector of 4 'double' values) do not have elements of the same size}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:81:20: error: vector operands to the vector conditional must be the same type ('FourInts' (vector of 4 'int' values) and 'TwoInts' (vector of 2 'int' values))}
   81 |   (void)(four_ints ?: two_ints);                   // expected-error {{vector operands to the vector conditional must be the same type ('FourInts' (vector of 4 'int' values) and 'TwoInts' (vector of 2 'int' values)}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:82:20: error: vector operands to the vector conditional must be the same type ('FourInts' (vector of 4 'int' values) and 'FourDoubles' (vector of 4 'double' values))}
   82 |   (void)(four_ints ?: four_doubles);               // expected-error {{vector operands to the vector conditional must be the same type ('FourInts' (vector of 4 'int' values) and 'FourDoubles' (vector of 4 'double' values)}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:85:20: error: vector condition type 'FourInts' (vector of 4 'int' values) and result type 'double __attribute__((ext_vector_type(4)))' (vector of 4 'double' values) do not have elements of the same size
   85 |   (void)(four_ints ? 3.0f : 3.0); // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'double __attribute__((ext_vector_type(4)))' (vector of 4 'double' values) do not have elements of the same size}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:86:20: error: vector condition type 'FourInts' (vector of 4 'int' values) and result type 'long long __attribute__((ext_vector_type(4)))' (vector of 4 'long long' values) do not have elements of the same size
   86 |   (void)(four_ints ? 5ll : 5);    // expected-error {{vector condition type 'FourInts' (vector of 4 'int' values) and result type 'long long __attribute__((ext_vector_type(4)))' (vector of 4 'long long' values) do not have elements of the same size}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:87:20: error: cannot convert between vector values of different size ('FourInts' (vector of 4 'int' values) and 'double')
   87 |   (void)(four_ints ?: 3.0);       // expected-error {{annot convert between vector values of different size ('FourInts' (vector of 4 'int' values) and 'double')}}
      |          ~~~~~~~~~ ^  ~~~
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:94:20: error: enumeration type 'E' is not allowed in a vector conditional
   94 |   (void)(four_ints ? e : e);                          // expected-error {{enumeration type 'E' is not allowed in a vector conditional}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:95:20: error: enumeration type 'SE' is not allowed in a vector conditional
   95 |   (void)(four_ints ? se : se);                        // expected-error {{enumeration type 'SE' is not allowed in a vector conditional}}
      |                    ^
/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:96:22: error: vector condition type 'FourShorts' (vector of 4 'short' values) and result type 'int __attribute__((ext_vector_type(4)))' (vector of 4 'int' values) do not have elements of the same size
   96 |   (void)(four_shorts ? (short)5 : (unsigned short)5); // expected-error {{vector condition type 'FourShorts' (vector of 4 'short' values) and result type 'int __attribute__((ext_vector_type(4)))' (vector of 4 'int' values) do not have elements of the same size}}
      |                      ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
clang++: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-project/clang/lib/Sema/SemaExprCXX.cpp:5890: clang::QualType clang::Sema::CheckVectorConditionalTypes(clang::ExprResult&, clang::ExprResult&, clang::ExprResult&, clang::SourceLocation): Assertion `!ResultType.isNull() && (ResultType->isVectorType() || ResultType->isSizelessVectorType()) && (!CondType->isExtVectorType() || ResultType->isExtVectorType()) && "Result should have been a vector type"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -Oz /home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp
1.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:207:38: current parser token ')'
2.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:202:25: parsing function body 'mix_vector_types'
3.	/home/fuzz/WorkSpace/fusion-fuzz/.fused/clang/tmppakziuce/1efde3ba.cpp:202:25: in compound statement ('{}')
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang++   0x0000560cb35690f9 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 121
1  clang++   0x0000560cb3565dcc llvm::sys::RunSignalHandlers() + 76
2  clang++   0x0000560cb3566678 llvm::sys::CleanupOnSignal(unsigned long) + 216
3  clang++   0x0000560cb34a8f88
4  libc.so.6 0x00007f4bdf23c520
5  libc.so.6 0x00007f4bdf2909fc pthread_kill + 300
6  libc.so.6 0x00007f4bdf23c476 raise + 22
7  libc.so.6 0x00007f4bdf2227f3 abort + 211
8  libc.so.6 0x00007f4bdf22271b
9  libc.so.6 0x00007f4bdf233e96
10 clang++   0x0000560cb6361d4a clang::Sema::CheckVectorConditionalTypes(clang::ActionResult<clang::Expr*, true>&, clang::ActionResult<clang::Expr*, true>&, clang::ActionResult<clang::Expr*, true>&, clang::SourceLocation) + 2218
11 clang++   0x0000560cb6381b69 clang::Sema::CXXCheckConditionalOperands(clang::ActionResult<clang::Expr*, true>&, clang::ActionResult<clang::Expr*, true>&, clang::ActionResult<clang::Expr*, true>&, clang::ExprValueKind&, clang::ExprObjectKind&, clang::SourceLocation) + 1273
12 clang++   0x0000560cb62ad390 clang::Sema::ActOnConditionalOp(clang::SourceLocation, clang::SourceLocation, clang::Expr*, clang::Expr*, clang::Expr*) + 192
13 clang++   0x0000560cb5d7c527 clang::Parser::ParseRHSOfBinaryExpression(clang::ActionResult<clang::Expr*, true>, clang::prec::Level) + 2647
14 clang++   0x0000560cb5d7ed7d clang::Parser::ParseExpression(clang::TypoCorrectionTypeBehavior) + 13
15 clang++   0x0000560cb5d82f7d clang::Parser::ParseParenExpression(clang::ParenParseOption&, bool, clang::ParenExprKind, clang::TypoCorrectionTypeBehavior, clang::OpaquePtr<clang::QualType>&, clang::SourceLocation&) + 1661
16 clang++   0x0000560cb5d78f91 clang::Parser::ParseCastExpression(clang::CastParseKind, bool, bool&, clang::TypoCorrectionTypeBehavior, bool, bool*) + 2161
17 clang++   0x0000560cb5d7aa7b clang::Parser::ParseCastExpression(clang::CastParseKind, bool, clang::TypoCorrectionTypeBehavior, bool, bool*) + 59
18 clang++   0x0000560cb5d7ab1d clang::Parser::ParseAssignmentExpression(clang::TypoCorrectionTypeBehavior) + 61
19 clang++   0x0000560cb5d7ed7d clang::Parser::ParseExpression(clang::TypoCorrectionTypeBehavior) + 13
20 clang++   0x0000560cb5e0ef81 clang::Parser::ParseExprStatement(clang::Parser::ParsedStmtContext) + 81
21 clang++   0x0000560cb5e06b7b clang::Parser::ParseStatementOrDeclarationAfterAttributes(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::ParsedAttributes&, clang::ParsedAttributes&, clang::LabelDecl*) + 5547
22 clang++   0x0000560cb5e0754b clang::Parser::ParseStatementOrDeclaration(llvm::SmallVector<clang::Stmt*, 24u>&, clang::Parser::ParsedStmtContext, clang::SourceLocation*, clang::LabelDecl*) + 363
23 clang++   0x0000560cb5e0f7f7 clang::Parser::ParseCompoundStatementBody(bool) + 1639
24 clang++   0x0000560cb5e1004f clang::Parser::ParseFunctionStatementBody(clang::Decl*, clang::Parser::ParseScope&) + 207
25 clang++   0x0000560cb5d0332f clang::Parser::ParseFunctionDefinition(clang::ParsingDeclarator&, clang::Parser::ParsedTemplateInfo const&, clang::LateParsedAttrList*) + 2559
26 clang++   0x0000560cb5d4ceb4 clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec&, clang::DeclaratorContext, clang::ParsedAttributes&, clang::Parser::ParsedTemplateInfo&, clang::SourceLocation*, clang::Parser::ForRangeInit*) + 5140
27 clang++   0x0000560cb5cfc15c clang::Parser::ParseDeclOrFunctionDefInternal(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec&, clang::AccessSpecifier) + 924
28 clang++   0x0000560cb5cfc92f clang::Parser::ParseDeclarationOrFunctionDefinition(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*, clang::AccessSpecifier) + 959
29 clang++   0x0000560cb5d087a1 clang::Parser::ParseExternalDeclaration(clang::ParsedAttributes&, clang::ParsedAttributes&, clang::ParsingDeclSpec*) + 977
30 clang++   0x0000560cb5d097df clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef>&, clang::Sema::ModuleImportState&) + 575
31 clang++   0x0000560cb5ce670a clang::ParseAST(clang::Sema&, bool, bool) + 586
32 clang++   0x0000560cb425f071 clang::FrontendAction::Execute() + 65
33 clang++   0x0000560cb41e8c65 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 1589
34 clang++   0x0000560cb433aea3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 467
35 clang++   0x0000560cb1f3dc96 cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7046
36 clang++   0x0000560cb1f33a2a
37 clang++   0x0000560cb1f33bbf
38 clang++   0x0000560cb3f7035d
39 clang++   0x0000560cb34a93a0 llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 160
40 clang++   0x0000560cb3f711b3
41 clang++   0x0000560cb3f26987 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
42 clang++   0x0000560cb3f2b1e0 clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 304
43 clang++   0x0000560cb3f38e44 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
44 clang++   0x0000560cb1f392d3 clang_main(int, char**, llvm::ToolContext const&) + 7267
45 clang++   0x0000560cb1e8b7a1 main + 113
46 libc.so.6 0x00007f4bdf223d90
47 libc.so.6 0x00007f4bdf223e40 __libc_start_main + 128
48 clang++   0x0000560cb1f33055 _start + 37
clang++: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git (https://github.com/llvm/llvm-project.git aefba88f46a6e55645c848f58f6ba56944d5ae62)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin
Build config: +assertions
clang++: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang++: note: diagnostic msg: /tmp/1efde3ba-8a69f3.cpp
clang++: note: diagnostic msg: /tmp/1efde3ba-8a69f3.sh
clang++: note: diagnostic msg: 

********************
Aborted (core dumped)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -Oz "$SCRIPT_DIR/test.cpp"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `c86bd897` | Project seed |
| `b` | `6d2e3a60` | Project seed |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
