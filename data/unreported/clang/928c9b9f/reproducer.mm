// RUN: %clang_cc1 -std=c11 %s -fsyntax-only -verify
// REQUIRES: asserts


// RUN: %clang_cc1 -fsyntax-only -Wloop-analysis -verify %s
// expected-no-diagnostics

@interface MyArray
- (id)objectAtIndexedSubscript:(unsigned int)idx;
@end

// Do not warn on objc classes has objectAtIndexedSubscript method.
// RUN: %clang_cc1 -std=c11 %s -fsyntax-only -verify
// REQUIRES: asserts
MyArray *test;
void foo(void)
{
  unsigned int i;
  for (i = 42; i > 0;) // No warnings here
    (void)test[--i];
}
// RUN: %clang_cc1 -std=c11 %s -fsyntax-only -verify
// REQUIRES: asserts

struct dispatch_object_s;
void _dispatch_queue_get_head(struct dispatch_object_s *volatile dq_items_head) {
  (_Atomic __typeof__(test) *)0; // expected-warning{{expression result unused}}
}
void g(void) {
  (_Atomic __typeof__(struct dispatch_object_s *volatile) *)0; // expected-warning{{expression result unused}}
}
