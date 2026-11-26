// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

template <typename T> using Ptr = __remove_pointer(T) *;

class C {
public:
  ptr;
};

struct S : C {
  S() {}
};

#include <stdio.h>

int main(void) {
    puts("/home/flag/flag");
    return 0;
}
