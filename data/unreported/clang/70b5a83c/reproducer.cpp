#include <stdio.h>


typedef struct Base {
    void (*print)(struct Base*);
    int* value;
} Base;

typedef struct {
    Base base;
    int a; // private member
} Derived;

static int dummy = 0;

static void base_print(Base* b) {
    printf("%d\n", *b->value);
}

static void base_init(Base* b) {
    b->value = (int*)malloc(sizeof(int));
    *b->value = 42;
    b->print = base_print;
}

static void derived_print(Base* b) {
    // using uninitialized base value (points to dummy)
    printf("%d\n", *b->value);
}

static void derived_init(Derived* d) {
    d->base.print = derived_print;
    d->base.value = &dummy; // simulate uninitialized internal state
    d->a = 0;
}

int main() {
    Derived d;
    derived_init(&d);
    d.base.print(&d.base);
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

template <class T> struct S {
  template <typename... Ts> S(typename T::U<Ts>... ts);
};

struct H {};
S<H> h;
