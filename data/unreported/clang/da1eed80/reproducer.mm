// RUN: %clang_cc1 -fsyntax-only -verify -triple x86_64-linux-gnu %s

#define NODEREF __attribute__((noderef))

void Func() {
  int NODEREF i; // expected-warning{{'noderef' can only be used on an array or pointer type}}
  int NODEREF *i_ptr;

  // There should be no difference whether a macro defined type is used or not.
  auto __attribute__((noderef)) *auto_i_ptr = i_ptr;
  auto __attribute__((noderef)) auto_i = i; // expected-warning{{'noderef' can only be used on an array or pointer type}}

  auto NODEREF *auto_i_ptr2 = i_ptr;
  auto NODEREF auto_i2 = i; // expected-warning{{'noderef' can only be used on an array or pointer type}}
}

// Added test for fix for P41835
#define _LIBCPP_FLOAT_ABI __attribute__((pcs("aapcs")))
struct A {
  _LIBCPP_FLOAT_ABI int operator()() throw(); // expected-warning{{'pcs' calling convention is not supported for this target}}
};

// Added test for fix for PR43315
#define a __attribute__((__cdecl__, __regparm__(0)))
int(a b)();

// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -emit-llvm -fblocks -fobjc-arc -debug-info-kind=limited -triple x86_64-apple-darwin10 %s -o - | FileCheck %s


#define nil ((void*) 0)
#define YES             ((BOOL)1)
#define NO              ((BOOL)0)




@interface NSString (NSStringExtensionMethods)
- (void)_LIBCPP_FLOAT_ABI:(void (^)(NSString *line, BOOL *stop))block;
@end








// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -emit-llvm -fblocks -fobjc-arc -debug-info-kind=limited -triple x86_64-apple-darwin10 %s -o - | FileCheck %s

typedef unsigned int NSUInteger;
typedef long NSInteger;
typedef signed char BOOL;
#define nil ((void*) 0)
#define YES             ((BOOL)1)
#define NO              ((BOOL)0)
@interface NSObject
- (id)init;
@end

@interface NSError : NSObject
@end

@interface NSString : NSObject
@end

@interface NSString (NSStringExtensionMethods)
- (void)enumerateLinesUsingBlock:(void (^)(NSString *line, BOOL *stop))block;
@end

@interface NSData : NSObject
@end

@interface NSData (ASBase64)
- (NSString *)encodedString:(NSInteger)position;
- (NSData *)compressedData;
@end

typedef void (^TDataCompletionBlock)(NSData *data, NSError *error);
@interface TMap : NSObject
- (NSString *)identifier;
- (NSString *)name;
+ (TMap *)mapForID:(NSString *)identifier;
- (void)dataWithCompletionBlock:(TDataCompletionBlock)block;
@end

typedef enum : NSUInteger {
    TOK                = 100,
    TError = 125,
}
TResponseCode;
// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -emit-llvm -fblocks -fobjc-arc -debug-info-kind=limited -triple x86_64-apple-darwin10 %s -o - | FileCheck %s


#define nil ((void*) 0)
#define YES             ((BOOL)1)
#define NO              ((BOOL)0)





@interface TConnection : NSObject
- (void)sendString:(NSString *)string;
- (void)sendFormat:(NSString *)format, ...;
- (void)sendResponseCode:(TResponseCode)responseCode dataFollows:(BOOL)flag
                         format:(NSString *)format, ...;
@end

@interface TServer : NSObject
@end

@implementation TServer
- (void)serverConnection:(TConnection *)connection getCommand:(NSString *)str
{
    NSString    *mapID = nil;
    TMap       *map = [TMap mapForID:mapID];
// Make sure we do not map code generated for the block to the above line.
// CHECK: define internal void @"__39-[TServer serverConnection:getCommand:]_block_invoke"
// CHECK: call void @llvm.objc.storeStrong(ptr [[CONNECTION_ADDR:%.*]], ptr [[ONE:%.*]]) [[NUW:#[0-9]+]]
// CHECK: call void @llvm.objc.storeStrong(ptr [[STR_ADDR:%.*]], ptr [[THREE:%.*]]) [[NUW]]
// CHECK: call {{.*}}@objc_msgSend{{.*}}, !dbg ![[LINE_ABOVE:[0-9]+]]
// CHECK: getelementptr
// CHECK-NOT: !dbg, ![[LINE_ABOVE]]
// CHECK: call void @llvm.objc.storeStrong(ptr [[STR_ADDR]], ptr null) [[NUW]]
// CHECK-NEXT: call void @llvm.objc.storeStrong(ptr [[CONNECTION_ADDR]], ptr null) [[NUW]]
// CHECK-NEXT: ret
// CHECK: attributes [[NUW]] = { nounwind }
    [map dataWithCompletionBlock:^(NSData *data, NSError *error) {
        if (data) {
            NSString    *encoded = [[data compressedData] encodedString:18];
            [connection sendResponseCode:TOK dataFollows:YES
                format:@"Sending \"%@\" (%@)", [map name], [map identifier]];
            [encoded enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [connection sendFormat:@"%@\r\n", line];
            }];
            [connection sendString:@".\r\n"];
        } else {
            [connection sendResponseCode:TError dataFollows:NO
                format:@"Failed \"%@\" (%@)", [map name], [map identifier]];
        }
    }];
}
@end



typedef enum : NSUInteger {
    TOK                = 100,
    TError = 125,
} TResponseCode;
