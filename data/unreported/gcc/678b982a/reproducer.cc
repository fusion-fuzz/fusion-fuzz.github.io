// { dg-do compile }
// { dg-options "-Os -fno-move-loop-invariants -std=c++11" }

struct NonTrivial3 {
  ~NonTrivial3();
};
void i() { thread_local NonTrivial3 tlarr[10]; }

/* { dg-do compile { target c++11 } } */
/* { dg-options -Wno-pedantic } */

struct str { int len; char s[]; }
;
struct foo {
  str x = {3, {1,2,3}}; /* { dg-error "(non-static)|(initialization)" } */
  foo() {}
}
;
struct bar {
  static constexpr str x = {3, {1,2,3}};
  bar() {}
}
;
struct baz {
  str x = {3};
  baz() {}
}
;
// { dg-do compile }
// { dg-options "-Os -fno-move-loop-invariants -std=c++11" }

struct NonTrivial3 {
  ~NonTrivial3();
}
;
void i() { thread_local NonTrivial3 tlarr[10]; }

// { dg-do compile }
// { dg-options "-Os -fno-move-loop-invariants -std=c++11" }

struct x {
  ~x();
}
;
void i() { thread_local x tlarr[10]; }
