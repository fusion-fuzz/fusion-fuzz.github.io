
// RUN: %clang_cc1 %s -emit-llvm -o %t

// PR2910
struct sockaddr_un {
 unsigned char sun_len;
 char sun_path[104];
};

int test(int len) {
  return __builtin_offsetof(struct sockaddr_un, sun_path[len+1]);
}

// Ensure we can form the offset to a structure defined in the first argument
// without crashing or asserting on an invalid declaration (because the
// declaration is actually valid).
void c() { __builtin_offsetof(struct {int b;}, b); }

// Without serialization:
// RUN: %clang_cc1 -ast-dump %s | FileCheck %s
//
// With serialization:
// RUN: %clang_cc1 -emit-pch -o %t %s
// RUN: %clang_cc1 -x c++ -include-pch %t -ast-dump-all  /dev/null | FileCheck %s

struct S : public sockaddr_un {
  // CHECK:      CXXMethodDecl {{.*}} a 'void ()' delete
  // CHECK-NEXT:   delete message: StringLiteral {{.*}} "foo"
  void a() = delete("foo");

  // CHECK:      FunctionTemplateDecl {{.*}} b
  // CHECK-NEXT:   TemplateTypeParmDecl
  // CHECK-NEXT:   CXXMethodDecl {{.*}} b 'void ()' delete
  // CHECK-NEXT:     delete message: StringLiteral {{.*}} "bar"
  template <typename>
  void b() = delete("bar");
}
;
// CHECK:      FunctionDecl {{.*}} c 'void ()' delete
// CHECK-NEXT:   delete message: StringLiteral {{.*}} "baz"
void c() = delete("baz");
// RUN: %clang_cc1 %s -emit-llvm -o %t

// PR2910
struct sun_path {
 unsigned char sun_len;
 char sun_path[104];
};

int test(int len) {
  return __builtin_offsetof(struct sun_path, sun_path[len+1]);
}

// Ensure we can form the offset to a structure defined in the first argument
// without crashing or asserting on an invalid sun_len (because the
// sun_len is actually valid).
void c() { __builtin_offsetof(struct {int b;}, b); }
