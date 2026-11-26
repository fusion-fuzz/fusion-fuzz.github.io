
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: computeDependence
// EXPECT-CRASH-ASSERT: UnexpandedPack

template <typename... Ts> void foo(Ts... a) { {a ?: 0}; }
// RUN: %clang -### --target=powerpc-ibm-aix7.1.0.0 %s -c -o %t.o 2>&1 \
// RUN:   | FileCheck %s
// RUN: %clang -### --target=powerpc64-ibm-aix7.1.0.0 %s -c -o %t.o 2>&1 \
// RUN:   | FileCheck %s
// CHECK: "-fdata-sections"

// Verify -fdata-sections is the default for AIX

// RUN: %clang -### --target=powerpc-ibm-aix7.1.0.0 %s -c -o %t.o 2>&1 \
// RUN:   | FileCheck %s
// RUN: %clang -### --target=powerpc64-ibm-aix7.1.0.0 %s -c -o %t.o 2>&1 \
// RUN:   | FileCheck %s
// CHECK: "-fdata-sections"
