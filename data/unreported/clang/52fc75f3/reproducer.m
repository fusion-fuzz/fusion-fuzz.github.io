
// RUN: %clang_cc1 -fsyntax-only -Wno-everything -Wobjc-literal-compare "-Dnil=((id)0)" -verify %s
// RUN: %clang_cc1 -fsyntax-only -Wno-everything -Wobjc-literal-compare "-Dnil=(id)0" -verify %s
// RUN: %clang_cc1 -fsyntax-only -Wno-everything -Wobjc-literal-compare "-Dnil=0" -verify %s

// RUN: %clang_cc1 -fsyntax-only -Wno-everything -Wobjc-literal-compare -fobjc-arc "-Dnil=((id)0)" -verify %s
// RUN: %clang_cc1 -fsyntax-only -Wno-everything -Wobjc-literal-compare -fobjc-arc "-Dnil=(id)0" -verify %s
// RUN: %clang_cc1 -fsyntax-only -Wno-everything -Wobjc-literal-compare -fobjc-arc "-Dnil=0" -verify %s

// (test the warning flag as well)

typedef signed char BOOL;

@interface BaseObject
+ (instancetype)new;
@end

@interface NSObject : BaseObject
- (BOOL)isEqual:(id)other;
@end

@interface NSNumber : NSObject
+ (NSNumber *)numberWithInt:(int)value;
+ (NSNumber *)numberWithDouble:(double)value;
+ (NSNumber *)numberWithBool:(BOOL)value;
@end

@interface NSArray : NSObject
+ (id)arrayWithObjects:(const id [])objects count:(unsigned long)cnt;
@end

@interface NSDictionary : NSObject
+ (id)dictionaryWithObjects:(const id [])objects forKeys:(const id [])keys count:(unsigned long)cnt;
@end

@interface NSString : NSObject
@end

void testComparisonsWithFixits(id obj) {
  if (obj == @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (obj != @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@"" == obj) return; // expected-warning{{direct comparison of a string literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@"" == @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}

  if (@[] == obj) return; // expected-warning{{direct comparison of an array literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@{} == obj) return; // expected-warning{{direct comparison of a dictionary literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@12 == obj) return; // expected-warning{{direct comparison of a numeric literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@1.0 == obj) return; // expected-warning{{direct comparison of a numeric literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@__objc_yes == obj) return; // expected-warning{{direct comparison of a numeric literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@(1+1) == obj) return; // expected-warning{{direct comparison of a boxed expression has undefined behavior}} expected-note{{use 'isEqual:' instead}}
}


@interface BadEqualReturnString : NSString
- (void)isEqual:(id)other;
@end

@interface BadEqualArgString : NSString
- (BOOL)isEqual:(int)other;
@end



  __builtin_va_end(arg_list);
  return ret;
void testComparisonsWithoutFixits() {
  if ([BaseObject new] == @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}}

  if ([BadEqualReturnString new] == @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}}
  if ([BadEqualArgString new] == @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}}

  if (@"" < @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}}
  if (@"" > @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}}
  if (@"" <= @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}}
  if (@"" >= @"") return; // expected-warning{{direct comparison of a string literal has undefined behavior}}
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-string-compare"

void testWarningFlags(id obj) {
  if (obj == @"") return; // no-warning
  if (@"" == obj) return; // no-warning

  if (obj == @1) return; // expected-warning{{direct comparison of a numeric literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
  if (@1 == obj) return; // expected-warning{{direct comparison of a numeric literal has undefined behavior}} expected-note{{use 'isEqual:' instead}}
}

#pragma clang diagnostic pop


void testNilComparison() {
  // Don't warn when comparing to nil in a macro.
#define RETURN_IF_NIL(x) if (x == nil || nil == x) return
  RETURN_IF_NIL(@"");
  RETURN_IF_NIL(@1);
  RETURN_IF_NIL(@1.0);
  RETURN_IF_NIL(@[]);
  RETURN_IF_NIL(@{});
  RETURN_IF_NIL(@__objc_yes);
  RETURN_IF_NIL(@(1+1));
}

void PR15257(Class c) {
  return c == @""; // expected-warning{{direct comparison of a string literal has undefined behavior}}
}
// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc-unknown-aix -emit-llvm -target-feature +altivec -target-cpu pwr7 -o - %s | FileCheck %s --check-prefixes=CHECK,AIX32
// RUN: %clang_cc1 -triple powerpc64-unknown-aix -emit-llvm -target-feature +altivec -target-cpu pwr7 -o - %s | FileCheck %s --check-prefixes=CHECK,AIX64

vector double vector_varargs(int count, ...) {
  __builtin_va_list arg_list;
  __builtin_va_start(arg_list, count);

  vector double ret;

  for (int i = 0; i != count; ++i) {
    ret = __builtin_va_arg(arg_list, vector double);
  }

  __builtin_va_end(arg_list);
  return ret;
}

// CHECK:         %arg_list = alloca ptr
// CHECK:         call void @llvm.va_start.p0(ptr %arg_list)

// AIX32:       for.body:
// AIX32-NEXT:    %argp.cur = load ptr, ptr %arg_list, align 4
// AIX32-NEXT:    %2 = getelementptr inbounds i8, ptr %argp.cur, i32 15
// AIX32-NEXT:    %argp.cur.aligned = call ptr @llvm.ptrmask.p0.i32(ptr %2, i32 -16)
// AIX32-NEXT:    %argp.next = getelementptr inbounds i8, ptr %argp.cur.aligned, i32 16
// AIX32-NEXT:    store ptr %argp.next, ptr %arg_list, align 4
// AIX32-NEXT:    %3 = load <2 x double>, ptr %argp.cur.aligned, align 16
// AIX32-NEXT:    store <2 x double> %3, ptr %ret, align 16
// AIX32-NEXT:    br label %for.inc

// AIX64:       for.body:
// AIX64-NEXT:    %argp.cur = load ptr, ptr %arg_list, align 8
// AIX64-NEXT:    %2 = getelementptr inbounds i8, ptr %argp.cur, i32 15
// AIX64-NEXT:    %argp.cur.aligned = call ptr @llvm.ptrmask.p0.i64(ptr %2, i64 -16)
// AIX64-NEXT:    %argp.next = getelementptr inbounds i8, ptr %argp.cur.aligned, i64 16
// AIX64-NEXT:    store ptr %argp.next, ptr %arg_list, align 8
// AIX64-NEXT:    %3 = load <2 x double>, ptr %argp.cur.aligned, align 16
// AIX64-NEXT:    store <2 x double> %3, ptr %ret, align 16
// AIX64-NEXT:    br label %for.inc


// CHECK:      for.end:
// CHECK:        call void @llvm.va_end.p0(ptr %arg_list)
