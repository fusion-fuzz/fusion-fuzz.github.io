
// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -fobjc-gc -triple x86_64-apple-darwin -fobjc-runtime=macosx-fragile-10.5 -S %s -o %t-64.s
// RUN: FileCheck -check-prefix CHECK-LP64 --input-file=%t-64.s %s

@interface NSObject {
  id isa;
}
@end

typedef struct {
    id b;
} st;

@interface Test : NSObject {
    int a;
    st b[0];
    (void)(^^long long);
    (void)(^^float);
    (void)(^^double);
    (void)(^^const void);
    (void)(^^decltype(nullptr));

    (void)(^^::); // expected-error {{unknown or unimplemented reflectable entity}}
    constexpr auto x = 1;
    (void)(^^x); // expected-error {{unknown or unimplemented reflectable entity}}
    (void)(^^A); // expected-error {{unknown or unimplemented reflectable entity}}
    (void)(^^B); // expected-error {{unknown or unimplemented reflectable entity}}
    (void)(^^f); // expected-error {{unknown or unimplemented reflectable entity}}
}
@end

@implementation Test @end
// CHECK-LP64: L_OBJC_LAYOUT_BITMAP_:
// CHECK-LP64-NEXT: .asciz      "\001\020"
