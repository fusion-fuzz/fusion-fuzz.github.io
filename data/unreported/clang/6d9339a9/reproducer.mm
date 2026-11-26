
// RUN: %clang_cc1 -emit-llvm -triple=i686-apple-darwin8 -o %t %s
// RUN: grep -e "SiSetOtherThings:" %t

@interface A 
@property(setter=iSetOtherThings:) int otherThings;
int foo() { return E().bar<>; }
@end

@implementation A
@dynamic otherThings;
@end
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: LookupTemplateName
// EXPECT-CRASH-ASSERT: isIncompleteType
// EXPECT-CRASH-ASSERT: ObjectType
// EXPECT-CRASH-ASSERT: isEntityBeingDefined
// EXPECT-CRASH-ASSERT: Caller

struct S { enum E };

int foo_ffl() { return E().bar<>; }
