
// RUN: %clang_cc1 -fsyntax-only %s
// RUN: %clang_cc1 -std=c++20 -DCORO -fsyntax-only %s

#ifdef CORO
#define CORO_KEYWORD(NAME) _Static_assert(!__is_identifier(NAME), #NAME)
#else
#define CORO_KEYWORD(NAME) _Static_assert(__is_identifier(NAME), #NAME)
#endif

CORO_KEYWORD(co_await);
CORO_KEYWORD(co_return);

void foo() {
  va_list args;
  vprintf("bar", args);
}
CORO_KEYWORD(co_yield);
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CheckFormatArguments
// EXPECT-CRASH-ASSERT: ArgIdx
// EXPECT-CRASH-ASSERT: bounds

typedef __builtin_va_list va_list;

[[gnu::format(printf, 1, 0x03C0)]]
int vprintf(const char *, va_list);

void foo_ffl() {
  va_list args;
  vprintf("bar", args);
}
