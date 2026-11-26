// RUN: c-index-test core -print-source-symbols -- %s | FileCheck %s

// Linkage decls are skipped in USRs for enclosed items.
// Linkage decls themselves don't have USRs (no lines between ns and X).
// CHECK: {{[0-9]+}}:11 | namespace/C++ | ns | c:@N@ns |
// CHECK-NEXT: {{[0-9]+}}:33 | variable/C | ffl_fusion | c:@N@ns@X |
namespace ns { extern "C" { int X; } }

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: ResolveAddressOfOverloadedFunction
// EXPECT-CRASH-ASSERT: AddressOfExpr
// EXPECT-CRASH-ASSERT: OverloadTy

template <typename T> struct S {
  using type = T;
  void foo{};
};

template <typename T> T &&bar(typename S<T>::type &x) { return x; }

struct SS {};
SS && (&baz) = bar<SS>;

static long ffl_fusion = (long)(S);
