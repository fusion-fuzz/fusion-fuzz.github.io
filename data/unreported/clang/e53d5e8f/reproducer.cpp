#include <stddef.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

template <typename O> void foo(const O &) { static T t; }

template <typename O, void bar(const O &)> class C {
public:
  template <typename I> void baz(const I &i) { bar(i); }
};

void qux() {
  C<int, foo<int>> c;
  c.baz<int>(42);
}
#include <stddef.h>

int main() {
    int *arr = NULL;
    size_t n = 0;
    int i, j;
    for (i = 0; i < n - 1; i++) {
        int min_idx = i;
        for (j = i + 1; j < n; j++) {
            if (arr[j] < arr[min_idx]) min_idx = j;
        }
        if (min_idx != i) {
            int t = arr[i];
            arr[i] = arr[min_idx];
            arr[min_idx] = t;
        }
    }
    return 0;
}
