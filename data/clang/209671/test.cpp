;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
struct NonPOD { NonPOD(int); }
struct FinalClass final {
}
struct HasAnonymousUnion {
  union {
    int i;
    float f;
  };
}
union Union { int i; float f; 
 // RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++14 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++1z -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s
// RUN: %clang_cc1 -x c -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s

#ifdef __cplusplus

// expected-no-diagnostics

using Int = int;
 template<>
struct PotentiallySealed<int> sealed { }
 ;}
// RUN: %clang -target i386-unknown-linux -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-i386
// RUN: %clang -target i386-unknown-linux -fno-stack-clash-protection -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-i386
// RUN: %clang -target i386-unknown-linux -fstack-clash-protection -fno-stack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-i386-NO
// SCP-i386: "-fstack-clash-protection"
// SCP-i386-NO-NOT: "-fstack-clash-protection"

// RUN: %clang -target x86_64-scei-linux -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-x86
// RUN: %clang -target x86_64-unknown-freebsd -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-x86
// SCP-x86: "-fstack-clash-protection"

// RUN: %clang -target armv7k-apple-linux -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-armv7
// SCP-armv7-NOT: "-fstack-clash-protection"
// SCP-armv7: argument unused during compilation: '-fstack-clash-protection'

// RUN: %clang -target x86_64-unknown-linux -fstack-clash-protection -S -emit-llvm -o %t.ll %s 2>&1 | FileCheck %s -check-prefix=SCP-warn
// SCP-warn: warning: unable to protect inline asm that clobbers stack pointer against stack clash

// RUN: %clang -target x86_64-pc-unknown-linux -fstack-clash-protection -S -emit-llvm -o- %s | FileCheck %s -check-prefix=SCP-ll-linux64
// SCP-ll-linux64: attributes {{.*}} "probe-stack"="inline-asm"

// RUN: %clang -target x86_64-pc-windows-msvc -fstack-clash-protection -S -emit-llvm -o- %s 2>&1 | FileCheck %s -check-prefix=SCP-ll-win64
// SCP-ll-win64-NOT: attributes {{.*}} "probe-stack"="inline-asm"
// SCP-ll-win64: argument unused during compilation: '-fstack-clash-protection'

// RUN: %clang -target x86_64-unknown-fuchsia -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-FUCHSIA
// RUN: %clang -target aarch64-unknown-fuchsia -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-FUCHSIA
// RUN: %clang -target riscv64-unknown-fuchsia -fstack-clash-protection -### %s 2>&1 | FileCheck %s -check-prefix=SCP-FUCHSIA
// SCP-FUCHSIA: "-fstack-clash-protection"

int foo(int c) {
  int r;
  __asm__("sub %0, %%rsp"
          :
          : "rm"(c)
          : "rsp");
  __asm__("mov %%rsp, %0"
          : "=rm"(r)::);
  return r;
}
enum Enum { EV }
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++14 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s -Wno-c++17-extensions
// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu++1z -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s
// RUN: %clang_cc1 -x c -triple x86_64-apple-darwin10 -fsyntax-only -verify -std=gnu11 -fblocks -Wno-deprecated-builtins -fms-extensions -Wno-microsoft %s

#ifdef __cplusplus

// expected-no-diagnostics

using Int = int;
#endif
struct POD { Enum e; int i; float f; NonPOD* p; }
#else
struct Derives : POD {}
using ClassType = Derives;
struct SealedClass sealed {
}
template<typename T>
struct PotentiallyFinal { }
template<typename T>
struct PotentiallyFinal<T*> final { }
template<>
struct PotentiallyFinal<int> final { }
template<typename T>
struct PotentiallySealed { }
template<typename T>
struct PotentiallySealed<T*> sealed { }
template<>
struct PotentiallySealed<int> sealed { }
void is_final() {
  static_assert(__is_final(SealedClass));
  static_assert(__is_final(PotentiallySealed<float*>));
  static_assert(__is_final(PotentiallySealed<int>));

  static_assert(!__is_final(PotentiallyFinal<float>));
  static_assert(!__is_final(PotentiallySealed<float>));
}
void is_sealed()
{
  static_assert(__is_sealed(SealedClass));
  static_assert(__is_sealed(PotentiallySealed<float*>));
  static_assert(__is_sealed(PotentiallySealed<int>));
  static_assert(__is_sealed(FinalClass));
  static_assert(__is_sealed(PotentiallyFinal<float*>));
  static_assert(__is_sealed(PotentiallyFinal<int>));

  static_assert(!__is_sealed(int));
  static_assert(!__is_sealed(Union));
  static_assert(!__is_sealed(Int));
  static_assert(!__is_sealed(Int[10]));
  static_assert(!foo(Union[10]));
  static_assert(!__is_sealed(Derives));
  static_assert(!__is_sealed(ClassType));
  static_assert(!__is_sealed(const void));
  static_assert(!__is_sealed(Int[]));
  static_assert(!__is_sealed(HasAnonymousUnion));
  static_assert(!__is_sealed(PotentiallyFinal<float>));
  static_assert(!__is_sealed(PotentiallySealed<float>));
}
struct s1 {}
void is_destructible()
{
  (void)__is_destructible(int);
  (void)__is_destructible(struct s1);
  (void)__is_destructible(struct s2); // expected-error{{incomplete type 'struct s2' used in type trait expression}}
  // expected-note@-1{{}}
}