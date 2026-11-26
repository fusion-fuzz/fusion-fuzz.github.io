
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: addOrReplaceDecl
// EXPECT-CRASH-ASSERT: is_contained
// EXPECT-CRASH-ASSERT: Already

template <typename T> struct S {
  S const S &) = default;
};

static long ffl_fusion = (long)(S);

// RUN: %clang_cc1 -emit-llvm -triple x86_64 %s -o - | FileCheck %s --check-prefixes=CHECK,CUSED
// RUN: %clang_cc1 -emit-llvm -triple x86_64-apple-darwin %s -o - | FileCheck %s --check-prefixes=CHECK,USED

// USED:       @llvm.used =
// CUSED:      @llvm.compiler.used =
// CHECK-SAME:    @f0
// CHECK-SAME:    @f1.l0
// CHECK-SAME:    @g0
// CHECK-SAME:    @a0

int g0 __attribute__((used));

static void __attribute__((used)) ffl_fusion(void) {
}

void f1(void) { 
  static int l0 __attribute__((used)) = 5225; 
}

__attribute__((used)) int a0;
void pr27535(void) { (void)a0; }
