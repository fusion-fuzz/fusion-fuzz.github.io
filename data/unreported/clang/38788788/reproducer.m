// RUN: %clang_cc1 -fsyntax-only -x objective-c -fobjc-arc -verify -Wno-objc-root-class %s



@interface NSTextField 
- (void)setBackgroundColor:(NSColor *)color;
- (NSColor *)backgroundColor;
@end






// RUN: %clang -fsyntax-only -fobjc-runtime=macosx-10.8 \
// RUN:   -Wno-objc-root-class --serialize-diagnostics %t.dia %s 2>&1 \
// RUN:   | FileCheck %s --check-prefix=TEXT
// RUN: c-index-test -read-diagnostics %t.dia 2>&1 \
// RUN:   | FileCheck %s --check-prefix=SERIALIZED

// Form an identifier larger than 64 KiB without making the test file enormous.
#define CAT_IMPL(A, B) A##B
#define CAT(A, B) CAT_IMPL(A, B)
#define A0 a
#define A1 CAT(A0, A0)
#define A2 CAT(A1, A1)
#define A3 CAT(A2, A2)
#define A4 CAT(A3, A3)
#define A5 CAT(A4, A4)
#define A6 CAT(A5, A5)
#define A7 CAT(A6, A6)
#define A8 CAT(A7, A7)
#define A9 CAT(A8, A8)
#define A10 CAT(A9, A9)
#define A11 CAT(A10, A10)
#define A12 CAT(A11, A11)
#define A13 CAT(A12, A12)
#define A14 CAT(A13, A13)
#define A15 CAT(A14, A14)
#define A16 CAT(A15, A15)
#define LARGE_IDENTIFIER CAT(A16, z)

@protocol Protocol
@property int LARGE_IDENTIFIER;
@end

@interface MyClass <Protocol>
@end

@implementation MyClass
@end

// TEXT: warning: auto property synthesis will not synthesize property
// TEXT: note: add a '@synthesize' directive
// SERIALIZED: warning: auto property synthesis will not synthesize property
// SERIALIZED: note: add a '@synthesize' directive
// SERIALIZED: FIXIT:
// SERIALIZED-SAME: z;
// SERIALIZED: Number of diagnostics: 1

// RUN: %clang_cc1 -fsyntax-only -x objective-c -fobjc-arc -verify -Wno-objc-root-class %s

typedef struct __attribute__((objc_bridge_related(NSColor,colorWithCGColor:,CGColor))) CGColor *CGColorRef;
// expected-note 5 {{declared here}}
typedef struct __attribute__((objc_bridge_related(NSColor,,CGColor1))) CGColor1 *CGColorRef1;
typedef struct __attribute__((objc_bridge_related(NSColor,,))) CGColor2 *CGColorRef2;
@interface NSColor // expected-note 5 {{declared here}}
+ (NSColor *)colorWithCGColor:(CGColorRef)cgColor;
- (CGColorRef)CGColor;
- (CGColorRef1)CGColor1;
@end

@interface NSTextField 
- (void)LARGE_IDENTIFIER:(NSColor *)color;

- (NSColor *)backgroundColor;
@end

void foo(NSColor*);
// expected-note {{passing argument to parameter here}}

NSColor * Test1(NSTextField *textField, CGColorRef newColor) {
  foo(newColor); // expected-error {{'CGColorRef' (aka 'struct CGColor *') must be explicitly converted to 'NSColor *'; use '+colorWithCGColor:' method for this conversion}}
  textField.backgroundColor = newColor; // expected-error {{'CGColorRef' (aka 'struct CGColor *') must be explicitly converted to 'NSColor *__strong'; use '+colorWithCGColor:' method for this conversion}}
  return newColor; // expected-error {{'CGColorRef' (aka 'struct CGColor *') must be explicitly converted to 'NSColor *'; use '+colorWithCGColor:' method for this conversion}}
}
NSColor * Test2(NSTextField *textField, CGColorRef1 newColor) {
  foo(newColor); // expected-error {{incompatible pointer types passing 'CGColorRef1' (aka 'struct CGColor1 *') to parameter of type 'NSColor *'}}
  textField.backgroundColor = newColor; // expected-error {{incompatible pointer types assigning to 'NSColor *__strong' from 'CGColorRef1' (aka 'struct CGColor1 *')}}
  return newColor; // expected-error {{incompatible pointer types returning 'CGColorRef1' (aka 'struct CGColor1 *') from a function with result type 'NSColor *'}}
}
CGColorRef Test3(NSTextField *textField, CGColorRef newColor) {
  newColor = textField.backgroundColor; // expected-error {{'NSColor *' must be explicitly converted to 'CGColorRef' (aka 'struct CGColor *'); use '-CGColor' method for this conversion}}
  return textField.backgroundColor; // expected-error {{'NSColor *' must be explicitly converted to 'CGColorRef' (aka 'struct CGColor *'); use '-CGColor' method for this conversion}}
}
CGColorRef2 Test4(NSTextField *textField, CGColorRef2 newColor) {
  newColor = textField.backgroundColor; // expected-error {{incompatible pointer types assigning}}
  return textField.backgroundColor; // expected-error {{incompatible pointer types returning}}
}
