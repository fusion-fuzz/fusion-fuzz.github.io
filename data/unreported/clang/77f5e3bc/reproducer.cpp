// RUN: clang++ -c -std=c++23 %s
// EXPECT-CRASH-ASSERT: addCallStack
// EXPECT-CRASH-ASSERT: CallRange.isValid

struct S {
  constexpr int foo() {}
};

static_assert([]() {
  S s;
  if (__builtin_invoke(&S::foo, s))
    return false;
  return true;
}());

#include <stdio.h>
#include <time.h>
int main(void) {
    time_t t = (time_t)1133216119;
    struct tm tmv;
    char buf[64];

  if (__builtin_invoke(&S::foo, s))
    return false;
  return true;
    tmv = *gmtime(&t);
    tmv.tm_mday += 1;
    mktime(&tmv);
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%S%z", &tmv);
    puts(buf);

    tmv = *gmtime(&t);
    tmv.tm_mon += 1;
    mktime(&tmv);
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%S%z", &tmv);
    puts(buf);

    tmv = *gmtime(&t);
    tmv.tm_mday += 7;
    mktime(&tmv);
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%S%z", &tmv);
    puts(buf);

    return 0;
}
// RUN: clang++ -c -std=c++23 %s
// EXPECT-CRASH-ASSERT: addCallStack
// EXPECT-CRASH-ASSERT: CallRange.isValid

struct S_ffl {
  constexpr int foo_ffl() {}
};

static_assert([]() {
  S_ffl s;
  if (__builtin_invoke(&S_ffl::foo, s))
    return false;
  return true;
}());
