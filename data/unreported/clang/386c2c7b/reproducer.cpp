// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-NOASSERT

template<class T> struct Foo { T t; };
template<X class Y> using AFoo = Foo<Y>;
AFoo s = { 42 };

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: LayoutVirtualBases
// EXPECT-CRASH-ASSERT: isDependentType
// EXPECT-CRASH-ASSERT: Cannot

template <typename T> void foo() {
  using bar = int;

  struct S {};

  struct SS : S, public T {
    int k = __alignof__(k);
  };
}
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-NOASSERT

template<class T_ffl> struct Foo_ffl { T_ffl t; };
template<X class Y_ffl> using AFoo = Foo_ffl<Y_ffl>;
AFoo s = { 42 };
