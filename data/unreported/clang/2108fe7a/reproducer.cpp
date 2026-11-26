
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ActOnBlockArguments
// EXPECT-CRASH-ASSERT: isFunctionType
// EXPECT-CRASH-ASSERT: GetTypeForDeclarator

#define VS(N) __attribute__((__vector_size__(N)))
v vt = {1, 2, 3, 4};

void (^foo)(char *) = ^(char *)VS(64){
};
// RUN: %clang_cc1 -emit-llvm %s -o -
// 
typedef int __attribute__((vector_size(16))) v;
v vt = {1, 2, 3, 4};
