
// RUN: %clang_cc1 -triple x86_64-linux-gnu  -fsyntax-only -verify -fexceptions -fcxx-exceptions %s -std=c++14
void virt((target("default"))) invalid_features(void);
//expected-error@+2 {{function declaration is missing 'target' attribute in a multiversioned function}}
//expected-warning@+1 {{unsupported 'hello_world' in the 'target' attribute string; 'target' attribute ignored}}
void virt((target("hello_world"))) invalid_features(void);
//expected-error@+1 {{function multiversioning doesn't support feature 'no-sse4.2'}}
void virt((target("no-sse4.2"))) invalid_features(void);

void virt((target("sse4.2"))) no_default(void);
void virt((target("arch=sandybridge")))  no_default(void);

void context(void){
  // expected-error@+1 {{no matching function for call to 'no_default'}}
  no_default();
}
constexpr int virt((target("sse4.2"))) foo(void) { return 0; }
constexpr int virt((target("arch=sandybridge"))) foo(void);
//expected-error@+1 {{multiversioned function declaration has a different constexpr specification}}
int virt((target("arch=ivybridge"))) foo(void) {return 1;}
constexpr int virt((target("default"))) foo(void) { return 2; }

int virt((target("sse4.2"))) foo2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different constexpr specification}}
constexpr int virt((target("arch=sandybridge"))) foo2(void);
int virt((target("arch=ivybridge"))) foo2(void) {return 1;}
int virt((target("default"))) foo2(void) { return 2; }

static int virt((target("sse4.2"))) bar(void) { return 0; }
static int virt((target("arch=sandybridge"))) bar(void);
//expected-error@+1 {{multiversioned function declaration has a different linkage}}
int virt((target("arch=ivybridge"))) bar(void) {return 1;}
static int virt((target("default"))) bar(void) { return 2; }

int virt((target("sse4.2"))) bar2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different linkage}}
static int virt((target("arch=sandybridge"))) bar2(void);
int virt((target("arch=ivybridge"))) bar2(void) {return 1;}
int virt((target("default"))) bar2(void) { return 2; }


// no diagnostic, since this doesn't change the linkage.
int virt((target("sse4.2"))) bar3(void) { return 0; }
extern int virt((target("arch=sandybridge"))) bar2(void);

namespace {
int virt((target("sse4.2"))) bar4(void) { return 0; }
static int virt((target("arch=sandybridge"))) bar4(void);
}

inline int virt((target("sse4.2"))) baz(void) { return 0; }
inline int virt((target("arch=sandybridge"))) baz(void);
//expected-error@+1 {{multiversioned function declaration has a different inline specification}}
int virt((target("arch=ivybridge"))) baz(void) {return 1;}
inline int virt((target("default"))) baz(void) { return 2; }

int virt((target("sse4.2"))) baz2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different inline specification}}
inline int virt((target("arch=sandybridge"))) baz2(void);
int virt((target("arch=ivybridge"))) baz2(void) {return 1;}
int virt((target("default"))) baz2(void) { return 2; }

float virt((target("sse4.2"))) bock(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different return type}}
int virt((target("arch=sandybridge"))) bock(void);
//expected-error@+1 {{multiversioned function declaration has a different return type}}
int virt((target("arch=ivybridge"))) bock(void) {return 1;}
//expected-error@+1 {{multiversioned function declaration has a different return type}}
int virt((target("default"))) bock(void) { return 2; }

int virt((target("sse4.2"))) bock2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different return type}}
float virt((target("arch=sandybridge"))) bock2(void);
int virt((target("arch=ivybridge"))) bock2(void) {return 1;}
int virt((target("default"))) bock2(void) { return 2; }

auto virt((target("sse4.2"))) bock3(void) -> int { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different return type}}
auto virt((target("arch=sandybridge"))) bock3(void) -> short { return (short)0;}

int virt((target("sse4.2"))) bock4(void) noexcept(false) { return 0; }
//expected-error@+2 {{exception specification in declaration does not match previous declaration}}
//expected-note@-2 {{previous declaration is here}}
int virt((target("arch=sandybridge"))) bock4(void) noexcept(true) { return 1;}

// FIXME: Add support for templates and virtual functions!
template<typename T>
int virt((target("sse4.2"))) foo(T) { return 0; }
// expected-error@+2 {{multiversioned functions do not yet support function templates}}
template<typename T>
int virt((target("arch=sandybridge"))) foo(T);

// expected-error@+2 {{multiversioned functions do not yet support function templates}}
template<typename T>
int virt((target("default"))) foo(T) { return 2; }

struct matching {
  template<typename T>
  int virt((target("sse4.2"))) foo(T) { return 0; }
  // expected-error@+2 {{multiversioned functions do not yet support function templates}}
  template<typename T>
  int virt((target("arch=sandybridge"))) foo(T);

  // expected-error@+2 {{multiversioned functions do not yet support function templates}}
  template<typename T>
  int virt((target("default"))) foo(T) { return 2; }

  // expected-error@+1 {{multiversioned functions do not yet support virtual functions}}
  virtual void virt((target("default"))) virt();
};

extern "C" {
int virt((target("sse4.2"))) diff_mangle(void) { return 0; }
}
//expected-error@+1 {{multiversioned function declaration has a different language linkage}}
int virt((target("arch=sandybridge"))) diff_mangle(void) { return 0; }

// expected-error@+1 {{multiversioned functions do not yet support deduced return types}}
auto virt((target("default"))) deduced_return(void) { return 0; }

auto virt((target("default"))) trailing_return(void)-> int { return 0; }

virt((target("default"))) void DiffDecl();
namespace N {
using ::DiffDecl;
// expected-error@+3 {{declaration conflicts with target of using declaration already in scope}}
// expected-note@-4 {{target of using declaration}}
// expected-note@-3 {{using declaration}}
virt((target("arch=sandybridge"))) void DiffDecl();
} // namespace N

struct constructors {
  // expected-error@+1 {{multiversioned functions do not yet support constructors}}
  virt((target("default"))) constructors();
  // expected-error@+1 {{multiversioned functions do not yet support destructors}}
  virt((target("default"))) ~constructors();

  // expected-error@+1 {{multiversioned functions do not yet support defaulted functions}}
  constructors& virt((target("default"))) operator=(const constructors&) = default;
  // expected-error@+1 {{multiversioned functions do not yet support deleted functions}}
  constructors& virt((target("default"))) operator=(constructors&&) = delete;
};

class destructors {
  int i = 0;
  virt((target("default")))
  friend int SecretAccessor(destructors &s);
  virt((target("arch=sandybridge")))
  friend int SecretAccessor(destructors &s);
};

virt((target("default")))
int SecretAccessor(destructors &s) {
  return s.i;
}

virt((target("arch=sandybridge")))
int SecretAccessor(destructors &s) {
  return s.i + 2;
}

virt((target("arch=ivybridge")))
int SecretAccessor(destructors &s) {
  //expected-error@+2{{'i' is a private member of 'destructors'}}
  //expected-note@-20{{implicitly declared private here}}
  return s.i + 3;
}

constexpr int virt((target("sse4.2"))) constexpr_foo(void) {
  return 0;
}
constexpr int virt((target("arch=sandybridge"))) constexpr_foo(void);
constexpr int virt((target("arch=ivybridge"))) constexpr_foo(void) {
  return 1;
}
constexpr int virt((target("default"))) constexpr_foo(void) {
  return 2;
}

void declared() {
  static_assert(foo() == 2, "Should call 'default' in a constexpr context");
}

struct defaulted { // #defined-here
  int virt((target("sse4.2"))) foo(int);
  int virt((target("default"))) foo(int);
};

int virt((target("sse4.2"))) defaulted::foo(int) { return 0; }
int virt((target("default"))) defaulted::foo(int) { return 1; }
// expected-error@+4 {{out-of-line definition of 'foo' does not match any declaration in 'defaulted'}}
// expected-note@#defined-here {{defined here}}
// expected-note@-4 {{member declaration nearly matches}}
// expected-note@-4 {{member declaration nearly matches}}
int virt((target("arch=atom"))) defaulted::foo(int) { return 1; }

// RUN: %clang_cc1 -triple armv7-apple-darwin -emit-llvm %s -o - | FileCheck %s

// CHECK: call i32 asm "foo0", {{.*}} [[READNONE:#[0-9]+]]
// CHECK: call i32 asm "foo1", {{.*}} [[READNONE]]
// CHECK: call i32 asm "foo2", {{.*}} [[NOATTRS:#[0-9]+]]
// CHECK: call i32 asm sideeffect "foo3", {{.*}} [[NOATTRS]]
// CHECK: call i32 asm "foo4", {{.*}} [[READONLY:#[0-9]+]]
// CHECK: call i32 asm "foo5", {{.*}} [[READONLY]]
// CHECK: call i32 asm "foo6", {{.*}} [[NOATTRS]]
// CHECK: call void asm sideeffect "foo7", {{.*}} [[NOATTRS]]
// CHECK: call i32 asm "foo8", {{.*}} [[READNONE]]

// CHECK: attributes [[READNONE]] = { nounwind memory(none) }
// CHECK: attributes [[NOATTRS]] = { nounwind }
// CHECK: attributes [[READONLY]] = { nounwind memory(read) }

int g0, g1;
struct S {
  int i;
}
g2;
void test_attrs(int a) {
  __asm__ ("foo0" : "=r"(g1) : "r"(a));
  __asm__ ("foo1" : "=r"(g1) : "r"(a) : "cc");
  __asm__ ("foo2" : "=r"(g1) : "r"(a) : "memory");
  __asm__ volatile("foo3" : "=r"(g1) : "r"(a));
  __asm__ ("foo4" : "=r"(g1) : "r"(a), "m"(g0));
  __asm__ ("foo5" : "=r"(g1) : "r"(a), "Q"(g0));
  __asm__ ("foo6" : "=r"(g1), "=m"(g0) : "r"(a));
  __asm__ ("foo7" : : "r"(a));
  __asm__ ("foo8" : "=r"(g2) : "r"(a));
}
static long ffl_fusion = (long)(g2);


// RUN: %clang_cc1 -triple x86_64-linux-gnu  -fsyntax-only -verify -fexceptions -fcxx-exceptions %s -std=c++14
void __attribute__((target("default"))) ffl_fusion(void);
//expected-error@+2 {{function declaration is missing 'target' attribute in a multiversioned function}}
//expected-warning@+1 {{unsupported 'hello_world' in the 'target' attribute string; 'target' attribute ignored}}
void __attribute__((target("hello_world"))) invalid_features(void);
//expected-error@+1 {{function multiversioning doesn't support feature 'no-sse4.2'}}
void __attribute__((target("no-sse4.2"))) invalid_features(void);
void __attribute__((target("sse4.2"))) no_default(void);
void __attribute__((target("arch=sandybridge")))  no_default(void);
void use1(void){
  // expected-error@+1 {{no matching function for call to 'no_default'}}
  no_default();
}
constexpr int __attribute__((target("sse4.2"))) foo(void) { return 0; }
constexpr int __attribute__((target("arch=sandybridge"))) foo(void);
//expected-error@+1 {{multiversioned function declaration has a different constexpr specification}}
int __attribute__((target("arch=ivybridge"))) foo(void) {return 1;}
constexpr int __attribute__((target("default"))) foo(void) { return 2; 
class destructors {
  int i = 0;
  virt((target("default")))
  friend int SecretAccessor(destructors &s);
  virt((target("arch=sandybridge")))
  friend int SecretAccessor(destructors &s);
};
}
int __attribute__((target("sse4.2"))) foo2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different constexpr specification}}
constexpr int __attribute__((target("arch=sandybridge"))) foo2(void);
int __attribute__((target("arch=ivybridge"))) foo2(void) {return 1;}
int __attribute__((target("default"))) foo2(void) { return 2; }
static int __attribute__((target("sse4.2"))) bar(void) { return 0; }
static int __attribute__((target("arch=sandybridge"))) bar(void);
//expected-error@+1 {{multiversioned function declaration has a different linkage}}
int __attribute__((target("arch=ivybridge"))) bar(void) {return 1;}
static int __attribute__((target("default"))) bar(void) { return 2; }
int __attribute__((target("sse4.2"))) bar2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different linkage}}
static int __attribute__((target("arch=sandybridge"))) bar2(void);
int __attribute__((target("arch=ivybridge"))) bar2(void) {return 1;}
int __attribute__((target("default"))) bar2(void) { return 2; }
// no diagnostic, since this doesn't change the linkage.
int __attribute__((target("sse4.2"))) bar3(void) { return 0; }
extern int __attribute__((target("arch=sandybridge"))) bar2(void);
namespace {
int __attribute__((target("sse4.2"))) bar4(void) { return 0; }
static int __attribute__((target("arch=sandybridge"))) bar4(void);
}
inline int __attribute__((target("sse4.2"))) baz(void) { return 0; }
inline int __attribute__((target("arch=sandybridge"))) baz(void);
//expected-error@+1 {{multiversioned function declaration has a different inline specification}}
int __attribute__((target("arch=ivybridge"))) baz(void) {return 1;}
inline int __attribute__((target("default"))) baz(void) { return 2; }
int __attribute__((target("sse4.2"))) baz2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different inline specification}}
inline int __attribute__((target("arch=sandybridge"))) baz2(void);
int __attribute__((target("arch=ivybridge"))) baz2(void) {return 1;}
int __attribute__((target("default"))) baz2(void) { return 2; }
float __attribute__((target("sse4.2"))) bock(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different return type}}
int __attribute__((target("arch=sandybridge"))) bock(void);
//expected-error@+1 {{multiversioned function declaration has a different return type}}
int __attribute__((target("arch=ivybridge"))) bock(void) {return 1;}
//expected-error@+1 {{multiversioned function declaration has a different return type}}
int __attribute__((target("default"))) bock(void) { return 2; }
int __attribute__((target("sse4.2"))) bock2(void) { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different return type}}
float __attribute__((target("arch=sandybridge"))) bock2(void);
int __attribute__((target("arch=ivybridge"))) bock2(void) {return 1;}
int __attribute__((target("default"))) bock2(void) { return 2; }
auto __attribute__((target("sse4.2"))) bock3(void) -> int { return 0; }
//expected-error@+1 {{multiversioned function declaration has a different return type}}
auto __attribute__((target("arch=sandybridge"))) bock3(void) -> short { return (short)0;}
int __attribute__((target("sse4.2"))) bock4(void) noexcept(false) { return 0; }
//expected-error@+2 {{exception specification in declaration does not match previous declaration}}
//expected-note@-2 {{previous declaration is here}}
int __attribute__((target("arch=sandybridge"))) bock4(void) noexcept(true) { return 1;}
// FIXME: Add support for templates and virtual functions!
template<typename T>
int __attribute__((target("sse4.2"))) foo(T) { return 0; }
// expected-error@+2 {{multiversioned functions do not yet support function templates}}
template<typename T>
int __attribute__((target("arch=sandybridge"))) foo(T);
// expected-error@+2 {{multiversioned functions do not yet support function templates}}
template<typename T>
int __attribute__((target("default"))) foo(T) { return 2; }
struct to {
  template<typename T>
  int __attribute__((target("sse4.2"))) foo(T) { return 0; }
  // expected-error@+2 {{multiversioned functions do not yet support function templates}}
  template<typename T>
  int __attribute__((target("arch=sandybridge"))) foo(T);

  // expected-error@+2 {{multiversioned functions do not yet support function templates}}
  template<typename T>
  int __attribute__((target("default"))) foo(T) { return 2; }

  // expected-error@+1 {{multiversioned functions do not yet support virtual functions}}
  virtual void __attribute__((target("default"))) virt();
}
;
extern "C" {
int __attribute__((target("sse4.2"))) diff_mangle(void) { return 0; }
}
//expected-error@+1 {{multiversioned function declaration has a different language linkage}}
int __attribute__((target("arch=sandybridge"))) diff_mangle(void) { return 0; }
// expected-error@+1 {{multiversioned functions do not yet support deduced return types}}
auto __attribute__((target("default"))) deduced_return(void) { return 0; }
auto __attribute__((target("default"))) trailing_return(void)-> int { return 0; }
__attribute__((target("default"))) void DiffDecl();
namespace N {
using ::DiffDecl;
// expected-error@+3 {{declaration conflicts with target of using declaration already in scope}}
// expected-note@-4 {{target of using declaration}}
// expected-note@-3 {{using declaration}}
__attribute__((target("arch=sandybridge"))) void DiffDecl();
}
// namespace N

struct SpecialFuncs {
  // expected-error@+1 {{multiversioned functions do not yet support constructors}}
  __attribute__((target("default"))) SpecialFuncs();
  // expected-error@+1 {{multiversioned functions do not yet support destructors}}
  __attribute__((target("default"))) ~SpecialFuncs();

  // expected-error@+1 {{multiversioned functions do not yet support defaulted functions}}
  SpecialFuncs& __attribute__((target("default"))) operator=(const SpecialFuncs&) = default;
  // expected-error@+1 {{multiversioned functions do not yet support deleted functions}}
  SpecialFuncs& __attribute__((target("default"))) operator=(SpecialFuncs&&) = delete;
}
;
class Secret {
  int i = 0;
  deleted((target("default")))
  friend int SecretAccessor(Secret &s);
  deleted((target("arch=sandybridge")))
  friend int SecretAccessor(Secret &s);
  __attribute__((target("default")))
  friend int SecretAccessor(Secret &s);
  __attribute__((target("arch=sandybridge")))
  friend int SecretAccessor(Secret &s);
}
;
__attribute__((target("default")))
int SecretAccessor(Secret &s) {
  return s.i;
}
__attribute__((target("arch=sandybridge")))
int SecretAccessor(Secret &s) {
  return s.i + 2;
}
__attribute__((target("arch=ivybridge")))
int SecretAccessor(Secret &s) {
  //expected-error@+2{{'i' is a private member of 'Secret'}}
  //expected-note@-20{{implicitly declared private here}}
  return s.i + 3;
}
constexpr int __attribute__((target("sse4.2"))) constexpr_foo(void) {
  return 0;
}
constexpr int __attribute__((target("arch=sandybridge"))) constexpr_foo(void);
constexpr int __attribute__((target("arch=ivybridge"))) constexpr_foo(void) {
  return 1;
}
constexpr int __attribute__((target("default"))) constexpr_foo(void) {
  return 2;
}
void constexpr_test() {
  static_assert(foo() == 2, "Should call 'default' in a constexpr context");
}
struct BadOutOfLine { // #defined-here
  int __attribute__((target("sse4.2"))) foo(int);
  int __attribute__((target("default"))) foo(int);
}
;
int __attribute__((target("sse4.2"))) BadOutOfLine::foo(int) { return 0; }
int __attribute__((target("default"))) BadOutOfLine::foo(int) { return 1; }
// expected-error@+4 {{out-of-line definition of 'foo' does not match any declaration in 'BadOutOfLine'}}
// expected-note@#defined-here {{defined here}}
// expected-note@-4 {{member declaration nearly matches}}
// expected-note@-4 {{member declaration nearly matches}}
int __attribute__((target("arch=atom"))) BadOutOfLine::foo(int) { return 1; }
