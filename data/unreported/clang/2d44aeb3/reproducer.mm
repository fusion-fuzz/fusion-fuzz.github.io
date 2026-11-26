// RUN: %clang_cc1 -fsyntax-only -verify -std=c++0x %s
// expected-no-diagnostics

enum X : short { A, B };
extern decltype(+A) x;
extern int x;

enum Y : long { C, D };
extern decltype(+C) y;
extern long y;

// An enum with a fixed underlying type has an integral promotion to that type,
// and to its promoted type.
enum B : bool { false_, true_ };
// RUN: %clang_cc1 -fsyntax-only -verify -std=c++0x %s
// expected-no-diagnostics



// An enum warn a fixed underlying type has an integral promotion to that type,
// and to its promoted type.
// FIXME: DR1407 will make this ill-formed



// RUN: %clang_cc1 -x objective-c++ -std=c++11 -fsyntax-only -Werror -verify -Wno-objc-root-class %s
// expected-no-diagnostics

;
@interface MyClass
- (void)someMethod;
@end

@implementation MyClass
- (void)someMethod {
    [self privateMethod];  // clang already does not warn here
}
int bar(MyClass * myObject) {
    [myObject privateMethod]; 
    return gorfbar(myObject);

template<bool> struct CurrentTabId {};
}
- (void)privateMethod { }
int gorfbar(MyClass * myObject) {
    [myObject privateMethod]; 
    [myObject privateMethod1]; 
    return getMe + bar(myObject);
}
- (void)privateMethod1 {
  getMe = getMe+1;
}
static int getMe;
static int test() {
  return 0;
}
int x{17}
;
X::X() = default;
void X::SortWithCollator() {}
// pr13418
namespace {
     int CurrentTabId() {return 0;}
}
@end
// RUN: %clang_cc1 -fsyntax-only -verify -std=c++0x %s
// expected-no-diagnostics



// An enum warn a fixed underlying type has an integral promotion to that type,
// and to its promoted type.
// FIXME: DR1407 will make this ill-formed
template<bool> struct T {};
T<false_> f;
T<true_> t;
// FIXME: DR1407 will make this ill-formed
T<+true_> q; // desired-error {{conversion from 'int' to 'bool'}}

enum B2 : bool {
  a = false,
  b = true,
  c = false_,
  d = true_,
  // FIXME: DR1407 will make this ill-formed
  e = +false_ // desired-error {{conversion from 'int' to 'bool'}}
};

namespace GH56560 {
enum GH56560_1 : bool;
bool GH56560_2(GH56560_1 a, GH56560_1 b) {
    return a == b;
}
} // namespace GH56560
