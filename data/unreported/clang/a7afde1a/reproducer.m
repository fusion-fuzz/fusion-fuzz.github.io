
// RUN: not %clang_cc1 -fsyntax-only -triple x86_64-apple-macosx10.6 %s 2>&1 | FileCheck %s --check-prefix NO-TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple x86_64-apple-macosx10.7 %s 2>&1 | FileCheck %s --check-prefix TLS

// RUN: not %clang_cc1 -fsyntax-only -triple arm64-apple-ios7.1 %s 2>&1 | FileCheck %s --check-prefix NO-TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple arm64-apple-ios8.0 %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: not %clang_cc1 -fsyntax-only -triple thumbv7s-apple-ios8.3 %s 2>&1 | FileCheck %s --check-prefix NO-TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple thumbv7s-apple-ios9.0 %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple armv7-apple-ios9.0 %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: not %clang_cc1 -fsyntax-only -triple i386-apple-ios9.0-simulator %s 2>&1 | FileCheck %s --check-prefix NO-TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple i386-apple-ios10.0-simulator %s 2>&1 | FileCheck %s --check-prefix TLS

// RUN: not %clang_cc1 -fsyntax-only -triple thumbv7k-apple-watchos1.0 %s 2>&1 | FileCheck %s --check-prefix NO-TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple thumbv7k-apple-watchos2.0 %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: not %clang_cc1 -fsyntax-only -triple i386-apple-watchos2.0-simulator %s 2>&1 | FileCheck %s --check-prefix NO-TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple i386-apple-watchos3.0-simulator %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple arm64-apple-xros %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple arm64-apple-xros-simulator %s 2>&1 | FileCheck %s --check-prefix TLS

// RUN: not %clang_cc1 -fsyntax-only -triple thumbv6m-apple-firmware %s 2>&1 | FileCheck %s --check-prefix NO-TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple thumbv7-apple-firmware %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple armv7k-apple-firmware %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple thumbv7m-apple-firmware %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple thumbv7em-apple-firmware %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple arm64-apple-firmware %s 2>&1 | FileCheck %s --check-prefix TLS
// RUN: %clang_cc1 -fsyntax-only -Wno-error=implicit-int -triple arm64e-apple-firmware %s 2>&1 | FileCheck %s --check-prefix TLS


__thread int a;

// NO-TLS: thread-local storage is not supported for the current target
// TLS-NOT: thread-local storage is not supported for the current target

// CHECK-LABEL: TypedefDecl {{.+}} T5 'int'
// CHECK-NEXT: BuiltinType {{.+}} 'int'
// CHECK-NEXT: TypedefDecl {{.+}} T5 'int'
// CHECK-NEXT: BuiltinType {{.+}} 'int'
// CHECK-NEXT: SwiftNewTypeAttr {{.+}} NK_Struct
// CHECK-NEXT: TypedefDecl {{.+}} T5 'int'
// CHECK-NEXT: BuiltinType {{.+}} 'int'
// CHECK-NEXT: SwiftNewTypeAttr {{.+}} NK_Struct
wibble;
// RUN: %clang_cc1 -ast-dump %s | FileCheck %s

typedef int T1 __attribute__((__swift_newtype__(struct)));
typedef int T2 __attribute__((__swift_newtype__(enum)));

typedef int T3 __attribute__((__swift_wrapper__(struct)));
typedef int T4 __attribute__((__swift_wrapper__(enum)));

typedef int T5;
typedef int T5 __attribute__((__swift_wrapper__(struct)));
typedef int T5;
// CHECK-LABEL: TypedefDecl {{.+}} T5 'int'
// CHECK-NEXT: BuiltinType {{.+}} 'int'
// CHECK-NEXT: TypedefDecl {{.+}} T5 'int'
// CHECK-NEXT: BuiltinType {{.+}} 'int'
// CHECK-NEXT: SwiftNewTypeAttr {{.+}} NK_Struct
// CHECK-NEXT: TypedefDecl {{.+}} T5 'int'
// CHECK-NEXT: BuiltinType {{.+}} 'int'
// CHECK-NEXT: SwiftNewTypeAttr {{.+}} NK_Struct
