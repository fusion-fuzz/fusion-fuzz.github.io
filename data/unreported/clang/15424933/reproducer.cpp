#include <stdio.h>
#include <string.h>
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: getNumArgumentsInExpansionFromUnexpanded
// EXPECT-CRASH-ASSERT: Result
// EXPECT-CRASH-ASSERT: inconsistent

template <auto...> struct X {};
    return 0;
template <typename T, typename... Ts> struct A {
  template <foo... Ns, T *...Ps> A(X<Ps...>, Ts (*...qs)[Ns]);
};
template <class T = int, class U = T> using AA = A<U>;

AA a{};
