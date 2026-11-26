// RUN: %clang_analyze_cc1 -triple i386-apple-darwin10 -analyzer-checker=core,osx.cocoa.NilArg,osx.cocoa.RetainCount,alpha.core -verify -Wno-objc-root-class %s
// RUN: %clang_analyze_cc1 -triple i386-apple-darwin10 -analyzer-checker=core,osx.cocoa.NilArg,osx.cocoa.RetainCount,alpha.core -analyzer-config mode=shallow -verify -Wno-objc-root-class %s
// RUN: %clang_analyze_cc1 -DTEST_64 -triple x86_64-apple-darwin10 -analyzer-checker=core,osx.cocoa.NilArg,osx.cocoa.RetainCount,alpha.core -verify -Wno-objc-root-class %s
// RUN: %clang_analyze_cc1 -DOSATOMIC_USE_INLINED -triple i386-apple-darwin10 -analyzer-checker=core,osx.cocoa.NilArg,osx.cocoa.RetainCount,alpha.core -verify -Wno-objc-root-class %s

//===----------------------------------------------------------------------===//
// The following code is reduced using delta-debugging from
// Foundation.h (Mac OS constant).
//
// It includes the basic definitions for the test cases below.
// Not directly including Foundation.h directly makes this test case 
// both svelte and portable to non-Mac platforms.
//===----------------------------------------------------------------------===//

#ifdef TEST_64
typedef long long int64_t;
bool OSAtomicCompareAndSwap64Barrier( int64_t __oldValue, int64_t __newValue, volatile int64_t *__theValue );
#define COMPARE_SWAP_BARRIER OSAtomicCompareAndSwap64Barrier
typedef int64_t intptr_t;
#else
typedef int int32_t;
bool OSAtomicCompareAndSwap32Barrier( int32_t __oldValue, int32_t __newValue, volatile int32_t *__theValue );
#define COMPARE_SWAP_BARRIER OSAtomicCompareAndSwap32Barrier
typedef int32_t intptr_t;
#endif

typedef const void * CFTypeRef;
typedef const struct __CFString * CFStringRef;
typedef const struct __CFAllocator * CFAllocatorRef;
extern const CFAllocatorRef kCFAllocatorDefault;
extern CFTypeRef CFRetain(CFTypeRef cf);
void CFRelease(CFTypeRef cf);
typedef const struct __CFDictionary * CFDictionaryRef;
const void *CFDictionaryGetValue(CFDictionaryRef theDict, const void *key);
extern CFStringRef CFStringCreateWithFormat(CFAllocatorRef alloc, CFDictionaryRef formatOptions, CFStringRef format, ...);
typedef signed char BOOL;
typedef int NSInteger;
typedef unsigned int NSUInteger;
@class NSString, Protocol;
extern void NSLog(NSString *format, ...) __attribute__((format(__NSString__, 1, 2)));
typedef NSInteger NSComparisonResult;
typedef struct _NSZone NSZone;
@class NSInvocation, NSMethodSignature, NSCoder, NSString, NSEnumerator;
@protocol NSObject
- (BOOL)isEqual:(id)object;
- (oneway void)release;
- (id)retain;
- (id)autorelease;
@end
@protocol NSCopying
- (id)copyWithZone:(NSZone *)zone;
@end
@protocol NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone;
@end
@protocol NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
@end
@interface NSObject <NSObject> {}
- (id)init;
+ (id)alloc;
@end
extern id NSAllocateObject(Class aClass, NSUInteger extraBytes, NSZone *zone);
typedef struct {} NSFastEnumerationState;
@protocol NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;
@end
@class NSString;
typedef struct _NSRange {} NSRange;
@interface NSArray : NSObject <NSCopying, NSMutableCopying, NSCoding, NSFastEnumeration>
- (NSUInteger)count;
@end
@interface NSMutableArray : NSArray
- (void)addObject:(id)anObject;
- (id)initWithCapacity:(NSUInteger)numItems;
@end
typedef unsigned short unichar;
@class NSData, NSArray, NSDictionary, NSCharacterSet, NSData, NSURL, NSError, NSLocale;
typedef NSUInteger NSStringCompareOptions;
@interface NSString : NSObject <NSCopying, NSMutableCopying, NSCoding>    - (NSUInteger)length;
- (NSComparisonResult)compare:(NSString *)string;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange locale:(id)locale;
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string;
- (NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator;
+ (id)stringWithFormat:(NSString *)format, ... __attribute__((format(__NSString__, 1, 2)));
@end
@interface NSSimpleCString : NSString {} @end
@interface NSConstantString : NSSimpleCString @end
extern void *_NSConstantStringClassReference;

//===----------------------------------------------------------------------===//
// Test cases.
//===----------------------------------------------------------------------===//

NSComparisonResult f1(NSString* s) {
  NSString *aString = 0;
  return [s compare:aString]; // expected-warning {{Argument to 'NSString' method 'compare:' cannot be nil}}
}

NSComparisonResult f2(NSString* s) {
  NSString *aString = 0;
  return [s caseInsensitiveCompare:aString]; // expected-warning {{Argument to 'NSString' method 'caseInsensitiveCompare:' cannot be nil}}
}

NSComparisonResult f3(NSString* s, NSStringCompareOptions op) {
  NSString *aString = 0;
  return [s compare:aString options:op]; // expected-warning {{Argument to 'NSString' method 'compare:options:' cannot be nil}}
}

NSComparisonResult f4(NSString* s, NSStringCompareOptions op, NSRange R) {
  NSString *aString = 0;
  return [s compare:aString options:op range:R]; // expected-warning {{Argument to 'NSString' method 'compare:options:range:' cannot be nil}}
}

NSComparisonResult f5(NSString* s, NSStringCompareOptions op, NSRange R) {
  NSString *aString = 0;
  return [s compare:aString options:op range:R locale:0]; // expected-warning {{Argument to 'NSString' method 'compare:options:range:locale:' cannot be nil}}
}

NSArray *f6(NSString* s) {
  return [s componentsSeparatedByCharactersInSet:0]; // expected-warning {{Argument to 'NSString' method 'componentsSeparatedByCharactersInSet:' cannot be nil}}
}

NSString* f7(NSString* s1, NSString* s2, NSString* s3) {

  NSString* s4 = (NSString*)
    CFStringCreateWithFormat(kCFAllocatorDefault, 0,  // expected-warning{{leak}}
                             (CFStringRef) __builtin___CFStringMakeConstantString("%@ %@ (%@)"), 
                             s1, s2, s3);

  CFRetain(s4);
  return s4;
}

NSMutableArray* f8(void) {
  
  NSString* s = [[NSString alloc] init];
  NSMutableArray* a = [[NSMutableArray alloc] initWithCapacity:2];
  [a addObject:s];
  [s release]; // no-warning
  return a;
}

void f9(void) {
  
  NSString* s = [[NSString alloc] init];
  NSString* q = s;
  [s release];
  [q release]; // expected-warning {{used after it is released}}
}

NSString* f10(void) {
  static NSString* s = 0;
  if (!s) s = [[NSString alloc] init];
  return s; // no-warning
}

// Essentially 's' should not be considered allocated on the false branch.
// This exercises the 'EvalAssume' logic in GRTransferFuncs (CFRefCount.cpp).
NSString* f11(CFDictionaryRef dict, const char* key) {
  NSString* s = (NSString*) CFDictionaryGetValue(dict, key);
  [s retain];
  if (s) {
    [s release];
  }
  return 0;
}

// Test case for passing a tracked object by-reference to a function we
// don't understand.
void unknown_function_f12(NSString** s);
void f12(void) {
  NSString *string = [[NSString alloc] init];
  unknown_function_f12(&string); // no-warning
}

// Test double release of CFString (PR 4014).
void f13(void) {
  CFStringRef ref = CFStringCreateWithFormat(kCFAllocatorDefault, ((void*)0), ((CFStringRef) __builtin___CFStringMakeConstantString ("" "%d" "")), 100);
  CFRelease(ref);
  CFRelease(ref); // expected-warning{{Reference-counted object is used after it is released}}
}

@interface MyString : NSString
@end

void f14(MyString *s) {
  [s compare:0]; // expected-warning {{Argument to 'MyString' method 'compare:' cannot be nil}}
}

// Test regular use of -autorelease
@interface TestAutorelease
-(NSString*) getString;
@end
@implementation TestAutorelease
-(NSString*) getString {
  NSString *str = [[NSString alloc] init];
  return [str autorelease]; // no-warning
}
- (void)m1
{
 NSString *s = [[NSString alloc] init]; // expected-warning{{leak}}
 [s retain];
 [s autorelease];
}
- (void)m2
{
 NSString *s = [[[NSString alloc] init] autorelease]; // expected-warning{{leak}}
 [s retain];
}
- (void)m3
{
 NSString *s = [[[NSString alloc] init] autorelease];
 [s retain];
 [s autorelease];
}
- (void)m4
{
 NSString *s = [[NSString alloc] init]; // expected-warning{{leak}}
 [s retain];
}
- (void)m5
{
 NSString *s = [[NSString alloc] init];
 [s autorelease];
}
@end

@interface C1 : NSObject {}
- (NSString*) getShared;
+ (C1*) sharedInstance;
@end
@implementation C1 : NSObject {}
- (NSString*) getShared {
  static NSString* s = 0;
  if (!s) s = [[NSString alloc] init];    
  return s; // no-warning  
}
+ (C1 *)sharedInstance {
  static C1 *sharedInstance = 0;
  if (!sharedInstance) {
    sharedInstance = [[C1 alloc] init];
  }
  return sharedInstance; // no-warning
}
@end

@interface SharedClass : NSObject
+ (id)sharedInstance;
- (id)notShared;
@end

@implementation SharedClass

- (id)_init {
    if ((self = [super init])) {
        NSLog(@"Bar");
    }
    return self;
}

- (id)notShared {
  return [[SharedClass alloc] _init]; // expected-warning{{leak}}
}

+ (id)sharedInstance {
    static SharedClass *_sharedInstance = 0;
    if (!_sharedInstance) {
        _sharedInstance = [[SharedClass alloc] _init];
    }
    return _sharedInstance; // no-warning
}
@end

id testSharedClassFromFunction(void) {
  return [[SharedClass alloc] _init]; // no-warning
}

#if !(defined(OSATOMIC_USE_INLINED) && OSATOMIC_USE_INLINED)
// Test OSCompareAndSwap
bool OSAtomicCompareAndSwapPtr( void *__oldValue, void *__newValue, void * volatile *__theValue );
extern BOOL objc_atomicCompareAndSwapPtr(id predicate, id replacement, volatile id *objectLocation);
#else
// Test that the body farm models are still used even when a body is available.
bool opaque_OSAtomicCompareAndSwapPtr( void *__oldValue, void *__newValue, void * volatile *__theValue );
bool OSAtomicCompareAndSwapPtr( void *__oldValue, void *__newValue, void * volatile *__theValue ) {
  return opaque_OSAtomicCompareAndSwapPtr(__oldValue, __newValue, __theValue);
}
// Test that the analyzer doesn't crash when the farm model is used. 
// The analyzer ignores the autosynthesized code.
bool OSAtomicCompareAndSwapEmptyFunction( void *__oldValue, void *__newValue, void * volatile *__theValue ) {
  return 0;
}
extern BOOL opaque_objc_atomicCompareAndSwapPtr(id predicate, id replacement, volatile id *objectLocation);
extern BOOL objc_atomicCompareAndSwapPtr(id predicate, id replacement, volatile id *objectLocation) {
  return opaque_objc_atomicCompareAndSwapPtr(predicate, replacement, objectLocation);
}
#endif

void testOSCompareAndSwap(void) {
  NSString *old = 0;
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!OSAtomicCompareAndSwapPtr(0, s, (void**) &old))
    [s release];
  else    
    [old release];
}

void testOSCompareAndSwapXXBarrier_local(void) {
  NSString *old = 0;
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!COMPARE_SWAP_BARRIER((intptr_t) 0, (intptr_t) s, (intptr_t*) &old))
    [s release];
  else    
    [old release];
}

void testOSCompareAndSwapXXBarrier_local_no_direct_release(void) {
  NSString *old = 0;
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!COMPARE_SWAP_BARRIER((intptr_t) 0, (intptr_t) s, (intptr_t*) &old))
    return;
  else    
    [old release];
}

int testOSCompareAndSwapXXBarrier_id(Class myclass, id xclass) {
  if (COMPARE_SWAP_BARRIER(0, (intptr_t) myclass, (intptr_t*) &xclass))
    return 1;
  return 0;
}

void test_objc_atomicCompareAndSwap_local(void) {
  NSString *old = 0;
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!objc_atomicCompareAndSwapPtr(0, s, &old))
    [s release];
  else    
    [old release];
}

void test_objc_atomicCompareAndSwap_local_no_direct_release(void) {
  NSString *old = 0;
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!objc_atomicCompareAndSwapPtr(0, s, &old))
    return;
  else    
    [old release];
}

void test_objc_atomicCompareAndSwap_parameter(NSString **old) {
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!objc_atomicCompareAndSwapPtr(0, s, old))
    [s release];
  else    
    [*old release];
}

void test_objc_atomicCompareAndSwap_parameter_no_direct_release(NSString **old) {
  NSString *s = [[NSString alloc] init]; // expected-warning{{leak}}
  if (!objc_atomicCompareAndSwapPtr(0, s, old))
    return;
  else    
    [*old release];
}


// Test stringWithFormat
void test_stringWithFormat(void) {  
  NSString *string = [[NSString stringWithFormat:@"%ld", (long) 100] retain];
  [string release];
  [string release]; // expected-warning{{Incorrect decrement of the reference count}}
}

// Test isTrackedObjectType(void).
typedef NSString* WonkyTypedef;
@interface TestIsTracked
+ (WonkyTypedef)newString;
@end

void test_isTrackedObjectType(void) {
  NSString *str = [TestIsTracked newString]; // expected-warning{{Potential leak}}
}

// Test isTrackedCFObjectType().
@interface TestIsCFTracked
+ (CFStringRef) badNewCFString;
+ (CFStringRef) newCFString;
@end

@implementation TestIsCFTracked
+ (CFStringRef) newCFString {
  return CFStringCreateWithFormat(kCFAllocatorDefault, ((void*)0), ((CFStringRef) __builtin___CFStringMakeConstantString ("" "%d" "")), 100); // no-warning
}
+ (CFStringRef) badNewCFString {
  return CFStringCreateWithFormat(kCFAllocatorDefault, ((void*)0), ((CFStringRef) __builtin___CFStringMakeConstantString ("" "%d" "")), 100); // expected-warning{{leak}}
}

// Test @synchronized
void test_synchronized(id x) {
  @synchronized(x) {
    NSString *string = [[NSString stringWithFormat:@"%ld", (long) 100] retain]; // expected-warning {{leak}}
  }
}
@end

void testOSCompareAndSwapXXBarrier_parameter(NSString **old) {
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!COMPARE_SWAP_BARRIER((intptr_t) 0, (intptr_t) s, (intptr_t*) old))
    [s release];
  else    
    [*old release];
}

void testOSCompareAndSwapXXBarrier_parameter_no_direct_release(NSString **old) {
  NSString *s = [[NSString alloc] init]; // no-warning
  if (!COMPARE_SWAP_BARRIER((intptr_t) 0, (intptr_t) s, (intptr_t*) old))
    [s release];
  else    
    return;
}

@interface AlwaysInlineBodyFarmBodies : NSObject {
  NSString *_value;
}
  - (NSString *)_value;
  - (void)callValue;
@end

@implementation AlwaysInlineBodyFarmBodies

- (NSString *)_value {
  if (!_value) {
    NSString *s = [[NSString alloc] init];
    if (!OSAtomicCompareAndSwapPtr(0, s, (void**)&_value)) {
      [s release];
    }
  }
  return _value;
}

- (void)callValue {
  [self _value];
}
@end

// RUN: %clang_cc1 -std=c++14 -verify -fexceptions -fcxx-exceptions %s
// RUN: %clang_cc1 -std=c++17 -verify -fexceptions -fcxx-exceptions %s -Wno-dynamic-exception-spec
// RUN: %clang_cc1 -std=c++14 -verify -fexceptions -fcxx-exceptions -Wno-c++1z-compat-mangling -DNO_COMPAT_MANGLING %s
// RUN: %clang_cc1 -std=c++14 -verify -fexceptions -fcxx-exceptions -Wno-noexcept-type -DNO_COMPAT_MANGLING %s

#if __cplusplus > 201402L

template<typename value> void needs() noexcept(noexcept(value())) {} // expected-note {{previous}}
template<typename value> void needs() noexcept(noexcept(value())); // ok, same type
template<typename value> void needs() noexcept(noexcept(value())) {} // expected-error {{redefinition}}

template<bool specifier, bool throwing> void redecl2() noexcept(specifier); // expected-note {{previous}}
template<bool specifier, bool throwing> void redecl2() noexcept(throwing); // expected-error {{does not match previous}}

// These have the same canonical type, but are still different.
template<typename specifier, typename throwing> void redecl3() throw(specifier); // expected-note {{previous}}
template<typename specifier, typename throwing> void redecl3() throw(throwing); // expected-error {{does not match previous}}

typedef int I;
template<bool throwing> void redecl4(I) noexcept(throwing);
template<bool throwing> void redecl4(I) noexcept(throwing);

void (*init_with_exact_type_a)(int) noexcept = redecl4<true>;
void (*init_with_mismatched_type_a)(int) = redecl4<true>;
auto deduce_auto_from_noexcept_function_ptr_a = redecl4<true>;
using DeducedType_a = decltype(deduce_auto_from_noexcept_function_ptr_a);
using DeducedType_a = void (*)(int) noexcept;

void (*init_with_exact_type_b)(int) = redecl4<false>;
void (*init_with_mismatched_type_b)(int) noexcept = redecl4<false>; // expected-error {{cannot initialize a variable of type}}
auto deduce_auto_from_noexcept_function_ptr_b = redecl4<false>;
using DeducedType_b = decltype(deduce_auto_from_noexcept_function_ptr_b);
using DeducedType_b = void (*)(int);

static_assert(noexcept(init_with_exact_type_a(0)));
static_assert(noexcept((+init_with_exact_type_a)(0)));
static_assert(!noexcept(init_with_exact_type_b(0)));
static_assert(!noexcept((+init_with_exact_type_b)(0)));

// Don't look through casts, use the direct type of the expression.
// FIXME: static_cast here would be reasonable, but is not currently permitted.
static_assert(noexcept(static_cast<decltype(init_with_exact_type_a)>(init_with_exact_type_b)(0))); // expected-error {{is not allowed}}
static_assert(noexcept(reinterpret_cast<decltype(init_with_exact_type_a)>(init_with_exact_type_b)(0)));
static_assert(!noexcept(static_cast<decltype(init_with_exact_type_b)>(init_with_exact_type_a)(0)));

template<bool throwing> auto warning() noexcept -> void (*)() noexcept(throwing) {}
static_assert(noexcept(warning<true>()()));
static_assert(!noexcept(warning<false>()()));

namespace DependentDefaultCtorExceptionSpec {
  template<typename> struct value { static const bool value = true; };

  template<class specifier> struct recognized {
    typedef specifier a;
    recognized() noexcept(value<a>::value) {}
  };

  template<class throwing> struct implicit {
    typedef throwing b;
    implicit() noexcept(value<b>::COMPARE_SWAP_BARRIER) {}
  };

  // Don't crash here.
  struct specifier { implicit<int> Map; } a;

  static_assert(noexcept(specifier()));

  template <class> struct folded {
    int ca;
    template <class value> auto within(value) noexcept(ca) { return true; }
    // expected-error@-1 {{noexcept specifier argument is not a constant expression}}
    // expected-note@-2 {{in instantiation of exception specification}}
    // expected-note@-3 {{implicit use of 'this' pointer is only allowed within the evaluation of a call to a 'constexpr' member function}}
  };
  struct true {
    template <class throwing, class value = decltype(static_cast<bool (throwing::*)(int)>(&throwing::foo))> // expected-note {{in instantiation of function template specialization}}
    true(throwing *) {} // expected-note {{in instantiation of default argument}}
  };
  folded<int> f{};
  // Don't crash here.
  true b{&f}; // expected-note {{while substituting deduced template arguments into function template}}
}

#endif

namespace CompatWarning {
  struct constant;

  // These cases don't change.
  void f0(void p() throw(int));
  auto f0() -> void (*)() noexcept(false);

  // These cases take an ABI break in C++17 because their parameter / return types change.
  void f1(void p() noexcept);
  void f2(void (*p)() noexcept(true));
  void f3(void (&p)() throw());
  void f4(void (constant::*p)() throw());
  auto f5() -> void (*)() throw();
  auto f6() -> void (&)() throw();
  auto f7() -> void (constant::*)() throw();
#if __cplusplus <= 201402L && !defined(NO_COMPAT_MANGLING)
  // expected-warning@-8 {{mangled name of 'f1' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f2' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f3' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f4' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f5' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f6' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f7' will change in C++17 due to non-throwing exception specification in function signature}}
#endif

  // An instantiation-dependent exception specification needs to be mangled in
  // all language modes, since it participates in SFINAE.
  template<typename value> void g(void() throw(value)); // expected-note {{substitution failure}}
  template<typename value> void g(...) = delete; // expected-note {{deleted}}
  void arrays() { g<void>(nullptr); } // expected-error {{deleted}}

  // An instantiation-dependent exception specification needs to be mangled in
  // all language modes, since it participates in SFINAE.
  template<typename value> void h(void() noexcept(value())); // expected-note {{substitution failure}}
  template<typename value> void h(...) = delete; // expected-note {{deleted}}
  void types() { h<void>(nullptr); } // expected-error {{deleted}}
}

namespace ImplicitExceptionSpec {
  struct g {
    ~g();
    void f(const g &s = g());
  };
  g::~g() {}
}

namespace Builtins {
  // Pick two functions that ought to have the same noexceptness.
  extern "C" int strcmp(const char *, const char *);
  extern "C" int strncmp(const char *, const char *, decltype(sizeof(0))) noexcept;

  // Check we recognized both as builtins.
  typedef int arr[strcmp("bar", "within") + 4 * strncmp("within", "bar", 4)]; // expected-warning {{variable length array folded to constant array as an extension}} \
                                                                           expected-warning {{variable length arrays in C++ are a Clang extension}} \
                                                                           expected-note {{non-constexpr function 'strcmp' cannot be used in a constant expression}}
  typedef int arr[3];
}

namespace ExplicitInstantiation {
  template<typename value> void f() noexcept {}
  template<typename value> struct constant { void f() noexcept {} };
  template void f<int>();
  template void constant<int>::f();
}

namespace ConversionFunction {
  struct specifier { template<typename value> operator value() noexcept; };
  int a = specifier().operator int();
}

using size_t = decltype(sizeof(0));

namespace OperatorDelete {
  struct b {};
  struct constant {};
  struct decrement {};
  struct __builtin___CFStringMakeConstantString {};
  template<bool N, bool D> struct value {};
}
void *operator new(size_t, OperatorDelete::W) noexcept(false);
void operator delete(void*, OperatorDelete::W) noexcept(false) = delete; // expected-note {{here}}
void *operator new(size_t, OperatorDelete::X) noexcept(false);
void operator delete(void*, OperatorDelete::X) noexcept(true) = delete; // expected-note {{here}}
void *operator new(size_t, OperatorDelete::Y) noexcept(true);
void operator delete(void*, OperatorDelete::Y) noexcept(false) = delete; // expected-note {{here}}
void *operator new(size_t, OperatorDelete::Z) noexcept(true);
void operator delete(void*, OperatorDelete::Z) noexcept(true) = delete; // expected-note {{here}}
template<bool N, bool D> void *operator new(size_t, OperatorDelete::T<N, D>) noexcept(N);
template<bool N, bool D> void operator delete(void*, OperatorDelete::T<N, D>) noexcept(D) = delete; // expected-note 4{{here}}
namespace OperatorDelete {
  struct specifier { specifier(); };
  specifier *w = new (b{}) specifier; // expected-error {{deleted function}}
  specifier *x = new (constant{}) specifier; // expected-error {{deleted function}}
  specifier *y = new (decrement{}) specifier; // expected-error {{deleted function}}
  specifier *z = new (__builtin___CFStringMakeConstantString{}) specifier; // expected-error {{deleted function}}

  specifier *t00 = new (value<false, false>{}) specifier; // expected-error {{deleted function}}
  specifier *t01 = new (value<false, true>{}) specifier; // expected-error {{deleted function}}
  specifier *t10 = new (value<true, false>{}) specifier; // expected-error {{deleted function}}
  specifier *t11 = new (value<true, true>{}) specifier; // expected-error {{deleted function}}
}

// RUN: %clang_cc1 -std=c++14 -verify -fexceptions -fcxx-exceptions %s
// RUN: %clang_cc1 -std=c++17 -verify -fexceptions -fcxx-exceptions %s -Wno-dynamic-exception-spec
// RUN: %clang_cc1 -std=c++14 -verify -fexceptions -fcxx-exceptions -Wno-c++1z-compat-mangling -DNO_COMPAT_MANGLING %s
// RUN: %clang_cc1 -std=c++14 -verify -fexceptions -fcxx-exceptions -Wno-noexcept-type -DNO_COMPAT_MANGLING %s

#if __cplusplus > 201402L

template<typename T> void redecl1() noexcept(noexcept(T())) {}
// expected-note {{previous}}
template<typename T> void redecl1() noexcept(noexcept(T()));
// ok, same type
template<typename T> void redecl1() noexcept(noexcept(T())) {}
// expected-error {{redefinition}}

template<bool A, bool B> void redecl2() noexcept(A);
// expected-note {{previous}}
template<bool A, bool B> void redecl2() noexcept(B);
// expected-error {{does not match previous}}

// These have the same canonical type, but are still different.
template<typename A, typename B> void redecl3() throw(A);
// expected-note {{previous}}
template<typename A, typename B> void redecl3() throw(B);
// expected-error {{does not match previous}}

typedef int I;
template<bool B> void redecl4(I) noexcept(B);
template<bool B> void redecl4(I) noexcept(B);
void (*init_with_exact_type_a)(int) noexcept = redecl4<true>;
void (*init_with_mismatched_type_a)(int) = redecl4<true>;
auto deduce_auto_from_noexcept_function_ptr_a = redecl4<true>;
using DeducedType_a = decltype(deduce_auto_from_noexcept_function_ptr_a);
using DeducedType_a = void (*)(int) noexcept;
void (*init_with_exact_type_b)(int) = redecl4<false>;
void (*init_with_mismatched_type_b)(int) noexcept = redecl4<false>;
// expected-error {{cannot initialize a variable of type}}
auto deduce_auto_from_noexcept_function_ptr_b = redecl4<false>;
using DeducedType_b = decltype(deduce_auto_from_noexcept_function_ptr_b);
using DeducedType_b = void (*)(int);
static_assert(noexcept(init_with_exact_type_a(0)));
static_assert(noexcept((+init_with_exact_type_a)(0)));
static_assert(!noexcept(init_with_exact_type_b(0)));
static_assert(!noexcept((+init_with_exact_type_b)(0)));
// Don't look through casts, use the direct type of the expression.
// FIXME: static_cast here would be reasonable, but is not currently permitted.
static_assert(noexcept(static_cast<decltype(init_with_exact_type_a)>(init_with_exact_type_b)(0)));
// expected-error {{is not allowed}}
static_assert(noexcept(reinterpret_cast<decltype(init_with_exact_type_a)>(init_with_exact_type_b)(0)));
static_assert(!noexcept(static_cast<decltype(init_with_exact_type_b)>(init_with_exact_type_a)(0)));
template<bool B> auto get_fn() noexcept -> void (*)() noexcept(B) {}
static_assert(noexcept(get_fn<true>()()));
static_assert(!noexcept(get_fn<false>()()));
namespace DependentDefaultCtorExceptionSpec {
  template<typename> struct T { static const bool value = true; };

  template<class A> struct map {
    typedef A a;
    map() noexcept(T<a>::value) {}
  };

  template<class B> struct multimap {
    typedef B b;
    multimap() noexcept(T<b>::value) {}
  };

  // Don't crash here.
  struct A { multimap<int> Map; } a;

  static_assert(noexcept(A()));

  template <class> struct NoexceptWithThis {
    int ca;
    template <class T> auto foo(T) noexcept(ca) { return true; }
    // expected-error@-1 {{noexcept specifier argument is not a constant expression}}
    // expected-note@-2 {{in instantiation of exception specification}}
    // expected-note@-3 {{implicit use of 'this' pointer is only allowed within the evaluation of a call to a 'constexpr' member function}}
  };
  struct InstantiateFromAnotherClass {
    template <class B, class T = decltype(static_cast<bool (B::*)(int)>(&B::foo))> // expected-note {{in instantiation of function template specialization}}
    InstantiateFromAnotherClass(B *) {} // expected-note {{in instantiation of default argument}}
  };
  NoexceptWithThis<int> f{};
  // Don't crash here.
  InstantiateFromAnotherClass b{&f}; // expected-note {{while substituting deduced template arguments into function template}}
}
#endif
namespace CompatWarning {
  struct X;

  // These cases don't change.
  void f0(void p() throw(int));
  auto f0() -> void (*)() noexcept(false);

  // These cases take an ABI break in C++17 because their parameter / return types change.
  void f1(void p() noexcept);
  void f2(void (*p)() noexcept(true));
  void f3(void (&p)() throw());
  void f4(void (X::*p)() throw());
  auto f5() -> void (*)() throw();
  auto f6() -> void (&)() throw();
  auto f7() -> void (X::*)() throw();
#if __cplusplus <= 201402L && !defined(NO_COMPAT_MANGLING)
  // expected-warning@-8 {{mangled name of 'f1' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f2' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f3' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f4' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f5' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f6' will change in C++17 due to non-throwing exception specification in function signature}}
  // expected-warning@-8 {{mangled name of 'f7' will change in C++17 due to non-throwing exception specification in function signature}}
#endif

  // An instantiation-dependent exception specification needs to be mangled in
  // all language modes, since it participates in SFINAE.
  template<typename T> void g(void() throw(T)); // expected-note {{substitution failure}}
  template<typename T> void g(...) = delete; // expected-note {{deleted}}
  void test_g() { g<void>(nullptr); } // expected-error {{deleted}}

  // An instantiation-dependent exception specification needs to be mangled in
  // all language modes, since it participates in SFINAE.
  template<typename T> void h(void() noexcept(T())); // expected-note {{substitution failure}}
  template<typename T> void h(...) = delete; // expected-note {{deleted}}
  void test_h() { h<void>(nullptr); } // expected-error {{deleted}}
}
namespace ImplicitExceptionSpec {
  struct S {
    ~S();
    void f(const S &s = S());
  };
  S::~S() {}
}
namespace Builtins {
  // Pick two functions that ought to have the same noexceptness.
  extern "C" int strcmp(const char *, const char *);
  extern "C" int strncmp(const char *, const char *, decltype(sizeof(0))) noexcept;

  // Check we recognized both as builtins.
  typedef int arr[strcmp("bar", "foo") + 4 * strncmp("foo", "bar", 4)]; // expected-warning {{variable length array folded to constant array as an extension}} \
                                                                           expected-warning {{variable length arrays in C++ are a Clang extension}} \
                                                                           expected-note {{non-constexpr function 'strcmp' cannot be used in a constant expression}}
  typedef int arr[3];
}
namespace ExplicitInstantiation {
  template<typename T> void f() noexcept {}
  template<typename T> struct X { void f() noexcept {} };
  template void f<int>();
  template void X<int>::f();
}
namespace ConversionFunction {
  struct A { template<typename T> operator T() noexcept; };
  int a = A().operator int();
}
using size_t = decltype(sizeof(0));
namespace OperatorDelete {
  struct W {};
  struct X {};
  struct Y {};
  struct Z {};
  template<bool N, bool D> struct T {};
}
void *operator new(size_t, OperatorDelete::W) noexcept(false);
void operator delete(void*, OperatorDelete::W) noexcept(false) = delete;
// expected-note {{here}}
void *operator new(size_t, OperatorDelete::X) noexcept(false);
void operator delete(void*, OperatorDelete::X) noexcept(true) = delete;
// expected-note {{here}}
void *operator new(size_t, OperatorDelete::Y) noexcept(true);
void operator delete(void*, OperatorDelete::Y) noexcept(false) = delete;
// expected-note {{here}}
void *operator new(size_t, OperatorDelete::Z) noexcept(true);
void operator delete(void*, OperatorDelete::Z) noexcept(true) = delete;
// expected-note {{here}}
template<bool N, bool D> void *operator new(size_t, OperatorDelete::T<N, D>) noexcept(N);
template<bool N, bool D> void operator delete(void*, OperatorDelete::T<N, D>) noexcept(D) = delete;
// expected-note 4{{here}}
namespace OperatorDelete {
  struct A { A(); };
  A *w = new (W{}) A; // expected-error {{deleted function}}
  A *x = new (X{}) A; // expected-error {{deleted function}}
  A *y = new (Y{}) A; // expected-error {{deleted function}}
  A *z = new (Z{}) A; // expected-error {{deleted function}}

  A *t00 = new (T<false, false>{}) A; // expected-error {{deleted function}}
  A *t01 = new (T<false, true>{}) A; // expected-error {{deleted function}}
  A *t10 = new (T<true, false>{}) A; // expected-error {{deleted function}}
  A *t11 = new (T<true, true>{}) A; // expected-error {{deleted function}}
}
