// RUN: %clang_cc1 -emit-llvm-only  -triple x86_64-apple-darwin9 %s

#define ATTR __attribute__((__ms_struct__))

#define size_struct_0 1
#define size_struct_1 4
#define size_struct_2 24
#define size_struct_3 8
#define size_struct_4 32
#define size_struct_5 12
#define size_struct_6 40
#define size_struct_7 8
#define size_struct_8 20
#define size_struct_9 32

struct _struct_0
{
  char member_0;
} ATTR;
typedef struct _struct_0 struct_0;

struct _struct_1
{
  char member_0;
  short member_1:13;
} ATTR;
typedef struct _struct_1 struct_1;

struct _struct_2
{
  double member_0;
  unsigned char member_1:8;
  int member_2:32;
  unsigned char member_3:5;
  short member_4:14;
  short member_5:13;
  unsigned char:0;
} ATTR;
typedef struct _struct_2 struct_2;

struct _struct_3
{
  unsigned int member_0:26;
  unsigned char member_1:2;

} ATTR;
typedef struct _struct_3 struct_3;

struct _struct_4
{
  unsigned char member_0:7;
  double member_1;
  double member_2;
  short member_3:5;
  char member_4:2;

} ATTR;
typedef struct _struct_4 struct_4;

struct _struct_5
{
  unsigned short member_0:12;
  int member_1:1;
  unsigned short member_2:6;

} ATTR;
typedef struct _struct_5 struct_5;

struct _struct_6
{
  unsigned char member_0:7;
  unsigned int member_1:25;
  char member_2:1;
  double member_3;
  short member_4:9;
  double member_5;

} ATTR;
// RUN: %clang_cc1 -emit-llvm-only  -triple x86_64-apple-darwin9 %s

#define ATTR __attribute__((__ms_struct__))

#define size_struct_0 1
#define size_struct_1 4
#define size_struct_2 24
#define size_struct_3 8
typedef struct _struct_6 struct_6;

struct _struct_7
{
  double member_0;

} ATTR;
typedef struct _struct_7 struct_7;

struct _struct_8
{
  unsigned char member_0:7;
  int member_1:11;
  int member_2:5;
  int:0;
  char member_4:8;
  unsigned short member_5:4;
  unsigned char member_6:3;
  int member_7:23;

} ATTR;
typedef struct _struct_8 struct_8;

struct _struct_9
{
  double member_0;
  unsigned int member_1:6;
  int member_2:17;
  double member_3;
  unsigned int member_4:22;

} ATTR;
typedef struct _struct_9 struct_9;

struct_0 test_struct_0 = { 123 };
struct_1 test_struct_1 = { 82, 1081 };
struct_2 test_struct_2 = { 20.0, 31, 407760, 1, 14916, 6712 };
struct_3 test_struct_3 = { 64616999, 1 };
struct_4 test_struct_4 = { 61, 20.0, 20.0, 12, 0 };
struct_5 test_struct_5 = { 909, 1, 57 };
struct_6 test_struct_6 = { 12, 21355796, 0, 20.0, 467, 20.0 };
struct_7 test_struct_7 = { 20.0 };
struct_8 test_struct_8 = { 126, 1821, 22, 125, 6, 0, 2432638 };
struct_9 test_struct_9 = { 20.0, 3, 23957, 20.0, 1001631 };


static int a0[(sizeof (struct_0) == size_struct_0) -1];
static int a1[(sizeof (struct_1) == size_struct_1) -1];
static int a2[(sizeof (struct_2) == size_struct_2) -1];
static int a3[(sizeof (struct_3) == size_struct_3) -1];
static int a4[(sizeof (struct_4) == size_struct_4) -1];
static int a5[(sizeof (struct_5) == size_struct_5) -1];
static int a6[(sizeof (struct_6) == size_struct_6) -1];
static int a7[(sizeof (struct_7) == size_struct_7) -1];
static int a8[(sizeof (struct_8) == size_struct_8) -1];
static int a9[(sizeof (struct_9) == size_struct_9) -1];

// RUN: %clang_cc1 -std=c++20 -fsyntax-only -verify %s

namespace Undefined {
  template<typename T>
  struct A {
    template<typename U>
    static constexpr int f(); // expected-note {{declared here}}

    template<typename U>
    static const int x; // expected-note {{declared here}}

    template<typename U>
    static const int x<U*>; // expected-note {{declared here}}

    template<typename U>
    struct B; // expected-note {{template is declared here}}

    template<typename U>
    struct B<U*>; // expected-note {{template is declared here}}
  };

  template<>
  template<typename U>
  constexpr int A<short>::f() {
    return A<long>::f<U>();
  }

  template<>
  template<typename U>
  constexpr int A<short>::x = A<long>::x<U>;

  template<>
  template<typename U>
  constexpr int A<short>::x<U*> = A<long>::x<U*>;

  template<>
  template<typename U>
  struct A<short>::B<U*> {
    static constexpr int y = A<long>::B<U*>::y;
  };

  template<>
  template<typename U>
  struct A<short>::B {
    static constexpr int y = A<long>::B<U>::y;
  };

  template<>
  template<typename U>
  constexpr int A<long>::f() {
    return 1;
  }

  template<>
  template<typename U>
  constexpr int A<long>::x = 1;

  template<>
  template<typename U>
  constexpr int A<long>::x<U*> = 2;

  template<>
  template<typename U>
  struct A<long>::B {
    static constexpr int y = 1;
  };

  template<>
  template<typename U>
  struct A<long>::B<U*> {
    static constexpr int y = 2;
  };

  static_assert(A<int>::f<int>() == 0); // expected-error {{static assertion expression is not an integral constant expression}}
                                        // expected-note@-1 {{undefined function 'f<int>' cannot be used in a constant expression}}
  static_assert(A<int>::x<int> == 0); // expected-error {{static assertion expression is not an integral constant expression}}
                                      // expected-note@-1 {{initializer of 'x<int>' is unknown}}
  static_assert(A<int>::x<int*> == 0); // expected-error {{static assertion expression is not an integral constant expression}}
                                       // expected-note@-1 {{initializer of 'x<int *>' is unknown}}
  static_assert(A<int>::B<int>::y == 0); // expected-error {{implicit instantiation of undefined template 'Undefined::A<int>::B<int>'}}
  static_assert(A<int>::B<int*>::y == 0); // expected-error {{implicit instantiation of undefined template 'Undefined::A<int>::B<int *>'}}

  static_assert(A<short>::f<int>() == 1);
  static_assert(A<short>::x<int> == 1);
  static_assert(A<short>::x<int*> == 2);
  static_assert(A<short>::B<int>::y == 1);
  static_assert(A<short>::B<int*>::y == 2);
}
// namespace Undefined

namespace Defined {
  template<typename T>
  struct A {
    template<typename U>
    static constexpr int f() {
      return 0;
    };

    template<typename U>
    static const int x = 0;

    template<typename U>
    static const int x<U*> = 0;

    template<typename U>
    struct B {
      static constexpr int y = 0;
    };

    template<typename U>
    struct B<U*> {
      static constexpr int y = 0;
    };
  };

  template<>
  template<typename U>
  constexpr int A<short>::f() {
    return A<long>::f<U>();
  }

  template<>
  template<typename U>
  constexpr int A<short>::x = A<long>::x<U>;

  template<>
  template<typename U>
  constexpr int A<short>::x<U*> = A<long>::x<U*>;

  template<>
  template<typename U>
  struct A<short>::B<U*> {
    static constexpr int y = A<long>::B<U*>::y;
  };

  template<>
  template<typename U>
  struct A<short>::B {
    static constexpr int y = A<long>::B<U>::y;
  };

  template<>
  template<typename U>
  constexpr int A<long>::f() {
    return 1;
  }

  template<>
  template<typename U>
  constexpr int A<long>::x = 1;

  template<>
  template<typename U>
  constexpr int A<long>::x<U*> = 2;

  template<>
  template<typename U>
  struct A<long>::B {
    static constexpr int y = 1;
  };

  template<>
  template<typename U>
  struct A<long>::B<U*> {
    static constexpr int y = 2;
  };

  static_assert(A<int>::f<int>() == 0);
  static_assert(A<int>::x<int> == 0);
  static_assert(A<int>::x<int*> == 0);
  static_assert(A<int>::B<int>::y == 0);
  static_assert(A<int>::B<int*>::y == 0);

  static_assert(A<short>::f<int>() == 1);
  static_assert(A<short>::x<int> == 1);
  static_assert(A<short>::x<int*> == 2);
  static_assert(A<short>::B<int>::y == 1);
  static_assert(A<short>::B<int*>::y == 2);
}
// namespace Defined

namespace Constrained {
  template<typename T, typename _FflDeclT = _struct_2>
  struct A {
    // FIXME expected-note@-1 2{{defined here}}
    template<typename U, bool V> requires V
    static constexpr int f(); // expected-note {{declared here}}
    // FIXME expected-note@-1 {{declared here}}

    template<typename U, bool V> requires V
    static const int x; // expected-note {{declared here}}
    // FIXME expected-note@-2 2{{previous template declaration is here}}
    // FIXME expected-note@-2 {{declared here}}

    template<typename U, bool V> requires V
    static const int x<U*, V>; // expected-note {{declared here}}
    // FIXME expected-note@-1 {{partial specialization matches}}

    template<typename U, bool V> requires V
    struct B; // expected-note {{template is declared here}}
    // FIXME expected-note@-2 2{{previous template declaration is here}}
    // FIXME expected-note@-2 {{template is declared here}}

    template<typename U, bool V> requires V
    struct B<U*, V>; // expected-note {{template is declared here}}
    // FIXME expected-note@-1 {{partial specialization matches}}
  };

  template<>
  template<typename U, bool V> requires V
  constexpr int A<short>::f() {
    return A<long>::f<U, V>();
  }
  // FIXME expected-error@-3 {{out-of-line definition of 'f' does not match any declaration in 'Constrained::A<short>'}}

  template<>
  template<typename U, bool V> requires V
  constexpr int A<short>::x = A<long>::x<U, V>;
  // FIXME expected-error@-2 {{requires clause differs in template redeclaration}}

  template<>
  template<typename U, bool V> requires V
  constexpr int A<short>::x<U*, V> = A<long>::x<U*, V>;
  // FIXME expected-note@-1 {{partial specialization matches}}

  template<>
  template<typename U, bool V> requires V
  struct A<short>::B<U*, V> {
    static constexpr int y = A<long>::B<U*, V>::y;
  };
    // FIXME expected-note@-3 {{partial specialization matches}}

  template<>
  template<typename U, bool V> requires V
  struct A<short>::B {
    static constexpr int y = A<long>::B<U, V>::y;
  };
  // FIXME expected-error@-4 {{requires clause differs in template redeclaration}}

  template<>
  template<typename U, bool V> requires V
  constexpr int A<long>::f() {
    return 1;
  }
  // FIXME expected-error@-3 {{out-of-line definition of 'f' does not match any declaration in 'Constrained::A<long>'}}

  template<>
  template<typename U, bool V> requires V
  constexpr int A<long>::x = 1;
  // FIXME expected-error@-2 {{requires clause differs in template redeclaration}}

  template<>
  template<typename U, bool V> requires V
  constexpr int A<long>::x<U*, V> = 2;

  template<>
  template<typename U, bool V> requires V
  struct A<long>::B {
    static constexpr int y = 1;
  };
  // FIXME expected-error@-4 {{requires clause differs in template redeclaration}}

  template<>
  template<typename U, bool V> requires V
  struct A<long>::B<U*, V> {
    static constexpr int y = 2;
  };

  static_assert(A<int>::f<int, true>() == 0); // expected-error {{static assertion expression is not an integral constant expression}}
                                              // expected-note@-1 {{undefined function 'f<int, true>' cannot be used in a constant expression}}
  static_assert(A<int>::x<int, true> == 0); // expected-error {{static assertion expression is not an integral constant expression}}
                                            // expected-note@-1 {{initializer of 'x<int, true>' is unknown}}
  static_assert(A<int>::x<int*, true> == 0); // expected-error {{static assertion expression is not an integral constant expression}}
                                             // expected-note@-1 {{initializer of 'x<int *, true>' is unknown}}
  static_assert(A<int>::B<int, true>::y == 0); // expected-error {{implicit instantiation of undefined template 'Constrained::A<int>::B<int, true>'}}
  static_assert(A<int>::B<int*, true>::y == 0); // expected-error {{implicit instantiation of undefined template 'Constrained::A<int>::B<int *, true>'}}

  static_assert(A<short>::f<int, true>() == 1);
  // FIXME expected-error@-1 {{static assertion expression is not an integral constant expression}}
  // FIXME expected-note@-2 {{undefined function 'f<int, true>' cannot be used in a constant expression}}
  static_assert(A<short>::x<int, true> == 1);
  // FIXME expected-error@-1 {{static assertion expression is not an integral constant expression}}
  // FIXME expected-note@-2 {{initializer of 'x<int, true>' is unknown}}
  static_assert(A<short>::x<int*, true> == 2);
  // FIXME expected-error@-1 {{ambiguous partial specializations of 'x'}}
  static_assert(A<short>::B<int, true>::y == 1);
  // FIXME expected-error@-1 {{implicit instantiation of undefined template 'Constrained::A<short>::B<int, true>'}}
  static_assert(A<short>::B<int*, true>::y == 2);
  // FIXME expected-error@-1 {{ambiguous partial specializations of 'B<int *, true>'}}
}
// namespace Constrained

namespace Dependent {
  template<int I>
  struct A {
    template<int J>
    static constexpr int f();

    template<int J>
    static const int x;

    template<int J>
    struct B;
  };

  template<>
  template<int J>
  constexpr int A<0>::f() {
    return A<1>::f<J>();
  }

  template<>
  template<int J>
  constexpr int A<1>::f() {
    return J;
  }

  template<>
  template<int J>
  constexpr int A<0>::x = A<1>::x<J>;

  template<>
  template<int J>
  constexpr int A<1>::x = J;

  template<>
  template<int J>
  struct A<0>::B {
    static constexpr int y = A<1>::B<J>::y;
  };

  template<>
  template<int J>
  struct A<1>::B {
    static constexpr int y = J;
  };

  static_assert(A<0>::f<2>() == 2);
  static_assert(A<0>::x<2> == 2);
  static_assert(A<0>::B<2>::y == 2);
}
// namespace Dependent
// RUN: %clang_cc1 -emit-llvm-only  -triple x86_64-apple-darwin9 %s

#define ATTR __attribute__((size_struct_6))

#define size_struct_0 1
#define size_struct_1 4
#define size_struct_2 24
#define size_struct_3 8
#define size_struct_4 32
#define size_struct_5 12
#define size_struct_6 40
#define size_struct_7 8
#define size_struct_8 20
#define size_struct_9 32













#define size_struct_4 32
#define size_struct_5 12
#define size_struct_6 40
#define size_struct_7 8
#define size_struct_8 20
#define size_struct_9 32
