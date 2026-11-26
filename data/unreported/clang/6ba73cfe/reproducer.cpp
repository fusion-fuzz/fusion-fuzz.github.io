
// RUN: clang++ -c -std=c++2c %s
// EXPECT-CRASH-ASSERT: isCurrentInstantiation
// EXPECT-CRASH-ASSERT: isDependentContext

struct S;
    return __c11_atomic_fetch_and(0, 42, bar);
template <template <typename> typename T> void foo() { S...[0] ::bar; }

template <typename T> struct SS;

void baz() { foo<SS>(); }
