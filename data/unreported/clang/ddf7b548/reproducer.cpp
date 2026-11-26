
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: InstantiatedLocal
// EXPECT-CRASH-ASSERT: Current
// EXPECT-CRASH-ASSERT: inner

template <typename T> struct S {
  static constexpr auto s(auto) {}
  auto s(int)
    requires true
  {
    return s.foo;
  }
  // PR3927
  #define f(x) h(x
  #define for(x) h(x
  #define h(x) x()
  B: f(f))
  C: for(for))

  // CHECK: {{^}}B: f(){{$}}
  // CHECK: {{^}}C: for(){{$}}

  #define f(x,y...) y
  f()

  // CHECK: #pragma omp parallel for
  #define FOO parallel
  #define Streaming _Pragma("omp FOO for")
  Streaming
};

static_assert(S<int[3]>{}.s(0) == 2);
