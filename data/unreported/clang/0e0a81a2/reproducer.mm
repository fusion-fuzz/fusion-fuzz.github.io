// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -Wno-objc-root-class %s
// RUN: %clang_cc1 -std=c++98 -x objective-c++ -triple x86_64-apple-darwin10 -fsyntax-only -verify -Wno-objc-root-class %s
// RUN: %clang_cc1 -std=c++11 -x objective-c++ -triple x86_64-apple-darwin10 -fsyntax-only -verify -Wno-objc-root-class %s

@interface Foo 
@end

// RUN: %clang_cc1 -fexceptions -triple x86_64-windows-msvc -debug-info-kind=limited -gcodeview -fdeclspec -emit-llvm %s -o - | FileCheck %s


// CHECK-LABEL: define {{.*}}void @doit
// CHECK: call {{.*}} ptr {{.*}}@"??2@YAPEAX_K@Z"(i64 noundef 4) {{.*}} !heapallocsite [[DBG_FOO:!.*]]
// CHECK: call {{.*}} ptr {{.*}}@"??2@YAPEAX_K@Z"(i64 noundef 4) {{.*}} !heapallocsite [[DBG_BAR:!.*]]


// CHECK-LABEL: define {{.*}}void @useinvoke
// CHECK: invoke {{.*}} ptr {{.*}}@"??2@YAPEAX_K@Z"(i64 noundef 4)
// CHECK-NEXT: to label {{.*}} unwind label {{.*}} !heapallocsite [[DBG_FOO]]

// CHECK: [[DBG_FOO]] = distinct !DICompositeType(tag: DW_TAG_structure_type,
// CHECK-SAME:                                 name: "Foo"
// CHECK: [[DBG_BAR]] = distinct !DICompositeType(tag: DW_TAG_structure_type,
// CHECK-SAME:                                 name: "y"

// a new expression in a default arg has caused crashes in the past, add here to test that edge case

@implementation Foo {
    struct y bar;
}

- (const struct y)bar {
    return bar;
}

- (void)baz {
    bar.x = 0;
    [self bar].x = 10; // expected-error-re {{{{assigning to 'readonly' return result of an Objective-C message not allowed|expression is not assignable}}}}
}
@end
// RUN: %clang_cc1 -fexceptions -triple x86_64-windows-msvc -debug-info-kind=limited -gcodeview -fdeclspec -emit-llvm %s -o - | FileCheck %s

struct Foo : public y {
  int x;
}
;
struct Bar {
  int y;
}
;
extern Foo *gv_foo;
extern Bar *gv_bar;
extern "C" void doit() {
  gv_foo = new Foo();
  gv_bar = new Bar();
}
// CHECK-LABEL: define {{.*}}void @doit
// CHECK: call {{.*}} ptr {{.*}}@"??2@YAPEAX_K@Z"(i64 noundef 4) {{.*}} !heapallocsite [[DBG_FOO:!.*]]
// CHECK: call {{.*}} ptr {{.*}}@"??2@YAPEAX_K@Z"(i64 noundef 4) {{.*}} !heapallocsite [[DBG_BAR:!.*]]

extern "C" void useinvoke() {
  struct HasDtor {
    ~HasDtor() { delete gv_foo; }
  } o;
  gv_foo = new Foo();
}
// CHECK-LABEL: define {{.*}}void @useinvoke
// CHECK: invoke {{.*}} ptr {{.*}}@"??2@YAPEAX_K@Z"(i64 noundef 4)
// CHECK-NEXT: to label {{.*}} unwind label {{.*}} !heapallocsite [[DBG_FOO]]

// CHECK: [[DBG_FOO]] = distinct !DICompositeType(tag: DW_TAG_structure_type,
// CHECK-SAME:                                 name: "Foo"
// CHECK: [[DBG_BAR]] = distinct !DICompositeType(tag: DW_TAG_structure_type,
// CHECK-SAME:                                 name: "Bar"

// a new expression in a default arg has caused crashes in the past, add here to test that edge case
void foo(int *a = new int) {}
void bar() { foo(); }
