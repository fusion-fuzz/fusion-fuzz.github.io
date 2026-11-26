// REQUIRES: x86-registered-target

// This verifies that hotpatch function attributes are correctly propagated when compiling directly to OBJ,
// and that name mangling works as expected.
//
// RUN: %clang_cl -c --target=x86_64-windows-msvc -O2 /Z7 -fms-secure-hotpatch-functions-list=?this_gets_hotpatched@@YAHXZ /Fo%t.obj -- %s
// RUN: llvm-readobj --codeview %t.obj | FileCheck %s

void this_might_have_side_effects();

int __declspec(noinline) this_gets_hotpatched() {
    this_might_have_side_effects();
    return 42;
}

// CHECK: Kind: S_HOTPATCHFUNC (0x1169)
// CHECK-NEXT: Function: this_gets_hotpatched
// CHECK-NEXT: Name: ?this_gets_hotpatched@@YAHXZ

extern "C" int __declspec(noinline) this_does_not_get_hotpatched() {
    return this_gets_hotpatched() + 100;
}

// CHECK-NOT: S_HOTPATCHFUNC

static long ffl_fusion = (long)(__declspec);

// RUN: clang++ -c -fms-compatibility %s
// EXPECT-CRASH-ASSERT: FindCompositePointerType
// EXPECT-CRASH-ASSERT: isNullPtrType
// EXPECT-CRASH-ASSERT: nullptr_t

typedef decltype(nullptr) nullptr_t;

struct X1 {
  operator int *();
};
struct X2 {
  operator const nullptr_t &();
};

int ffl_fusion() { return X1() != X2(bar<int>()); }
