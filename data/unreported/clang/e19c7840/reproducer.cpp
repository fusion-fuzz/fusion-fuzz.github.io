
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: CheckCompletedCoroutineBody
// EXPECT-CRASH-ASSERT: isInvalidDecl
// EXPECT-CRASH-ASSERT: declarations

class C {};

// RUN: %clang -### --target=arm64-apple-darwin %s 2>&1 | FileCheck %s
// CHECK: -demangle
C Foo() : bar { co_await ({}) }
// On Darwin, -demangle is passed to the linker of HOST_LINK_VERSION
// is high enough. It is assumed to be high enough on systems where
// this test gets run.

// RUN: %clang -### --target=arm64-apple-darwin %s 2>&1 | FileCheck %s
// CHECK: -demangle
