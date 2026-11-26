#include <stddef.h>
#include <stdio.h>
#include <time.h>
// RUN: %clang_cc1 -triple x86_64-apple-darwin1-1  -emit-llvm -o - %s | FileCheck %s

@interface Foo
-(float)myfo;
-(void)setMyfo: (int)p;
@end

void bar(Foo *x) {
  x.myfo++;
}

// CHECK: [[C1:%.*]] = call float @objc_msgSend
// CHECK: [[I:%.*]] = fadd float [[C1]], 1.000000e+00
// CHECK: [[CONV:%.*]] = fptosi float [[I]] to i32
// CHECK: [[T3:%.*]] = load ptr, ptr @OBJC_SELECTOR_REFERENCES_.2
// CHECK:  call void @objc_msgSend





typedef enum { LOCAL, UTC } TimeKind;

typedef struct {
    TimeKind kind;
    void (*interceptor[2])(time_t);
} Clock;

void local_interceptor(time_t t) {
    printf("[LOCAL] %ld\n", (long)t);
}

void utc_interceptor(time_t t) {
    printf("[UTC] %ld\n", (long)t);
}

int main() {
    Clock clk;
    clk.interceptor[LOCAL] = local_interceptor;
    clk.interceptor[UTC] = utc_interceptor;
    clk.kind = LOCAL;

    size_t offset = offsetof(Clock, interceptor);
    void (**interceptor_ptr)(time_t) = (void (**)(time_t))((char*)&clk + offset);

    for (int i = 0; i < 5; i++) {
        time_t t = time(NULL);
        interceptor_ptr[LOCAL](t);
        clock_t start = clock();
        while ((clock() - start) * 1.0 / CLOCKS_PER_SEC < 1.0) { }
    }
    for (int i = 0; i < 5; i++) {
        time_t t = time(NULL);
        interceptor_ptr[UTC](t);
        clock_t start = clock();
        while ((clock() - start) * 1.0 / CLOCKS_PER_SEC < 1.0) { }
    }

    Clock clk2;
    clk2.interceptor[LOCAL] = local_interceptor;
    clk2.interceptor[UTC] = utc_interceptor;
    void (**interceptor_ptr2)(time_t) = (void (**)(time_t))((char*)&clk2 + offset);
    return 0;

    for (int i = 0; i < 5; i++) {
        time_t t = time(NULL);
        interceptor_ptr2[LOCAL](t);
        clock_t start = clock();
        while ((clock() - start) * 1.0 / CLOCKS_PER_SEC < 1.0) { }
    }
    for (int i = 0; i < 5; i++) {
        time_t t = time(NULL);
        interceptor_ptr2[UTC](t);
        clock_t start = clock();
        while ((clock() - start) * 1.0 / CLOCKS_PER_SEC < 1.0) { }
    }

    return 0;
}
