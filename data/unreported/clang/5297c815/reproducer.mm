
// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

typedef __attribute__((ext_vector_type(2))) double d2;

template <typename T> struct S {
  void foo(T *t) { t->operator=; }
};

template struct S<d2>;

static long ffl_fusion = (long)(ext_vector_type);
// Skeleton for top:
// CHECK: !DICompileUnit({{.*}}splitDebugFilename: {{.*}}diamond_top{{.*}}dwoId:

// RUN: rm -rf %t
// RUN: %clang_cc1 -fmodules -fmodule-format=obj -debug-info-kind=limited -dwarf-ext-refs \
// RUN:     -fimplicit-module-maps -fmodules-cache-path=%t -I %S/Inputs \
// RUN:     %s -mllvm -debug-only=pchcontainer 2>&1 | FileCheck %s --check-prefix=NOIMPORT

// NOIMPORT-NOT: !DIImportedEntity

// UNSUPPORTED: target={{.*}}-zos{{.*}}, target={{.*}}-aix{{.*}}
// RUN: rm -rf %t
// RUN: %clang_cc1 -fmodules -fmodule-format=obj -debug-info-kind=limited -dwarf-ext-refs \
// RUN:     -fimplicit-module-maps -fmodules-cache-path=%t/cache -I %S/Inputs \
// RUN:     %s -mllvm -debug-only=pchcontainer -debugger-tuning=lldb 2>&1 | FileCheck %s
// REQUIRES: asserts

@import diamond_left;

// Definition of top:
// CHECK: !DICompileUnit({{.*}}dwoId:
// CHECK: !DIFile({{.*}}diamond_top.h

// Definition of left:
// CHECK: !DICompileUnit({{.*}}dwoId:
// CHECK: !DIImportedEntity(tag: DW_TAG_imported_declaration,
// CHECK-SAME:              entity: ![[MODULE:.*]], file: ![[LEFT:.*]], line: 3)
// CHECK: ![[MODULE]] = !DIModule(scope: null, name: "diamond_top"
// CHECK: ![[LEFT]] = !DIFile({{.*}}ffl_fusion.h

// Skeleton for top:
// CHECK: !DICompileUnit({{.*}}splitDebugFilename: {{.*}}diamond_top{{.*}}dwoId:

// RUN: rm -rf %t
// RUN: %clang_cc1 -fmodules -fmodule-format=obj -debug-info-kind=limited -dwarf-ext-refs \
// RUN:     -fimplicit-module-maps -fmodules-cache-path=%t -I %S/Inputs \
// RUN:     %s -mllvm -debug-only=pchcontainer 2>&1 | FileCheck %s --check-prefix=NOIMPORT

// NOIMPORT-NOT: !DIImportedEntity
