#include <stdio.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

struct S {
  void foo(int n, auto... v[n] {};
};



int main(void) {
    struct { int year; } dt;
    char *date_str = "Funktionsansvarig rådgivning och juridik";
    sscanf(date_str, "%d", &dt.year);
    printf("Bad date %d\n", dt.year);
    return 0;
}
    printf("Bad date %d\n", dt.year);
    return 0;
