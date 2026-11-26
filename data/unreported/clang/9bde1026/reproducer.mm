// RUN: %clang_cc1 -verify -fsyntax-only -Wno-objc-root-class %s

@class I0; // expected-note 2{{forward declaration of class here}}

int g0 = sizeof(I0); // expected-error{{invalid application of 'sizeof' to an incomplete type 'I0'}}

void *g3(I0 *P) {
  P = P+5;        // expected-error {{arithmetic on a pointer to an incomplete type 'I0'}}

  return &P[4];   // expected-error{{expected method to read array element not found on object of type 'I0 *'}}
}



@interface I0 {
@public
  char x[4];
}

@property int p0;
@end

// size == 4
int g1[ sizeof(I0)     // expected-error {{application of 'sizeof' to interface 'I0' is not supported on this architecture and platform}}
       == 4 ? 1 : -1];

@implementation I0
@synthesize p0 = _p0;
@end

// size == 4 (we do not include extended properties in the
// sizeof).
int g2[ sizeof(I0)   // expected-error {{application of 'sizeof' to interface 'I0' is not supported on this architecture and platform}}
       == 4 ? 1 : -1];

@interface I1
@property int p0;
@end

@implementation I1
@synthesize p0 = _p0;
@end

typedef struct { @defs(I1); } I1_defs; // expected-error {{use of @defs is not supported on this architecture and platform}}

// FIXME: This is currently broken due to the way the record layout we
// create is tied to whether we have seen synthesized properties. Ugh.
// int g3[ sizeof(I1) == 0 ? 1 : -1];

int bar(I0 *P) {
  P = P+5;  // expected-error {{arithmetic on pointer to interface 'I0', which is not a constant size for this architecture and platform}}
  P = 5+P;  // expected-error {{arithmetic on pointer to interface 'I0', which is not a constant size for this architecture and platform}}
  P = P-5;  // expected-error {{arithmetic on pointer to interface 'I0', which is not a constant size for this architecture and platform}}
  
  return P[4].x[2];  // expected-error {{expected method to read array element not found on object of type 'I0 *'}}
}


@interface I @end

@interface XCAttributeRunDirectNode
{
    @public
    unsigned long attributeRuns[1024 + sizeof(I)]; // expected-error {{application of 'sizeof' to interface 'I' is not supported on this architecture and platform}}
    int i;
}
@end

@implementation XCAttributeRunDirectNode

- (unsigned long)gatherStats:(id )stats
{
        return attributeRuns[i];
}
@end


@interface Foo @end

int foo(void)
{
  Foo *f;
  
  // Both of these crash clang nicely
  ++f; 	// expected-error {{arithmetic on pointer to interface 'Foo', which is not a constant size for this architecture and platform}}
  --f; 	// expected-error {{arithmetic on pointer to interface 'Foo', which is not a constant size for this architecture and platform}}
}

// RUN: %clang_cc1 -fpass-by-value-is-noalias -triple arm64-apple-iphoneos -emit-llvm -disable-llvm-optzns %s -o - 2>&1 | FileCheck --check-prefix=WITH_NOALIAS %s
// RUN: %clang_cc1 -triple arm64-apple-iphoneos -emit-llvm -disable-llvm-optzns %s -o - 2>&1 | FileCheck --check-prefix=NO_NOALIAS %s

// A trivial struct large enough so it is not passed in registers on ARM64.
struct Foo {
  int a;
  int b;
  int c;
  int d;
  int e;
  int f;
};

// Make sure noalias is added to indirect arguments with trivially copyable types
// if -fpass-by-value-is-noalias is provided.

// WITH_NOALIAS: define{{.*}} void @_Z4take3Foo(ptr noalias nofreeobj noundef align 4 dead_on_return dereferenceable(24) %arg)
// NO_NOALIAS: define{{.*}} void @_Z4take3Foo(ptr nofreeobj noundef align 4 dead_on_return dereferenceable(24) %arg)
void take(Foo arg) {}

int G;

// NonTrivial is not trivially-copyable, because it has a non-trivial copy
// constructor.
struct NonTrivial {
  int a;
  int b;
  int c;
  int d;
  int e;
  int f;

  NonTrivial(const NonTrivial &Other) {
    a = g0 + 10 + Other.a;
  }
};

// Make sure noalias is not added to indirect arguments that are not trivially
// copyable even if -fpass-by-value-is-noalias is provided.

// WITH_NOALIAS: define{{.*}} void @_Z4take10NonTrivial(ptr nofreeobj noundef align 4 dead_on_return dereferenceable(24) %arg)
// NO_NOALIAS:   define{{.*}} void @_Z4take10NonTrivial(ptr nofreeobj noundef align 4 dead_on_return dereferenceable(24) %arg)
void take(NonTrivial arg) {}

// Escape examples. Pointers to the objects passed to take() may escape, depending on whether a temporary copy is created or not (e.g. due to NRVO).
struct A {
  A(A **where) : data{"hello world 1"} {
    *where = this; //Escaped pointer 1 (proposed UB?)
  }

  A() : data{"hello world 2"} {}

  char data[32];
};
A *p;

// WITH_NOALIAS: define{{.*}} void @_Z4take1A(ptr noalias nofreeobj noundef align 1 dead_on_return dereferenceable(32) %arg)
// NO_NOALIAS: define{{.*}} void @_Z4take1A(ptr nofreeobj noundef align 1 dead_on_return dereferenceable(32) %arg)
void take(A arg) {}

// WITH_NOALIAS: define{{.*}} void @_Z7CreateAPP1A(ptr dead_on_unwind noalias writable sret(%struct.A) align 1 %agg.result, ptr noundef %where)
// NO_NOALIAS: define{{.*}} void @_Z7CreateAPP1A(ptr dead_on_unwind noalias writable sret(%struct.A) align 1 %agg.result, ptr noundef %where)
A CreateA(A **where) {
  A justlikethis;
  *where = &justlikethis; //Escaped pointer 2 (should also be UB, then)
  return justlikethis;
}

// elsewhere, perhaps compiled by a smarter compiler that doesn't make a copy here
void test() {
  take({&p});        // 1
  take(CreateA(&p)); // 2
}
