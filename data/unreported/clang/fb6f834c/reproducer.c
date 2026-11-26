
// RUN: %clang -### -S -fwrapv -fno-wrapv -fwrapv -Werror %s 2>&1 | FileCheck -check-prefix=CHECK1 %s
// CHECK1: "-fwrapv"

// RUN: %clang -### -S -fwrapv-pointer -fno-wrapv-pointer -fwrapv-pointer -Werror %s 2>&1 | FileCheck -check-prefix=CHECK1-POINTER %s
// CHECK1-POINTER: "-fwrapv-pointer"

// RUN: %clang -### -S -fstrict-overflow -fno-strict-overflow -Werror %s 2>&1 | FileCheck -check-prefix=CHECK2 %s
// CHECK2: "-fwrapv"{{.*}}"-fwrapv-pointer"

// RUN: %clang -### -S -fwrapv -fstrict-overflow -Werror -Werror %s 2>&1 | FileCheck -check-prefix=CHECK3 %s --implicit-check-not="-fwrapv-pointer"
// CHECK3-NOT: "-fwrapv"

// RUN: %clang -### -S -fwrapv-pointer -fstrict-overflow -Werror %s 2>&1 | FileCheck -check-prefix=CHECK3-POINTER %s --implicit-check-not="-fwrapv"
// CHECK3-POINTER-NOT: "-fwrapv-pointer"

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/other-kinds.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/other-kinds.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/duplicate.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/duplicate.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/raw-string-literal.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/raw-string-literal.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/concat-escape.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/concat-escape.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/u8-literal.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/u8-literal.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/wide-literal.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/wide-literal.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/utf16-literal.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/utf16-literal.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/utf32-literal.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/utf32-literal.c

//--- unsupported.c
// pragma comment kinds not supported on this target.
#pragma comment(copyright, "copyright")            // expected-warning {{'#pragma comment copyright' ignored}}
#pragma comment(compiler)                          // expected-warning {{'#pragma comment compiler' ignored}}
#pragma comment(exestr, "foo")                     // expected-warning {{'#pragma comment exestr' ignored}}
#pragma comment(user, "foo\abar\nbaz\tsomething")  // expected-warning {{'#pragma comment user' ignored}}
#pragma comment(timestamp)                         // expected-error {{unknown kind of pragma comment}}
#pragma comment(date)                              // expected-error {{unknown kind of pragma comment}}

//--- copyright.c
// Copyright pragma is accepted without diagnostics.
#pragma comment(copyright, "copyright") // expected-no-diagnostics

//--- empty-copyright.c
// An empty copyright string is accepted without diagnostics.
#pragma comment(copyright, "") // expected-no-diagnostics

//--- other-kinds.c
// Non-copyright comment kinds produce warnings/errors.
#pragma comment(lib, "m")                          // expected-warning {{'#pragma comment lib' ignored}}
#pragma comment(linker, "foo")                     // expected-warning {{'#pragma comment linker' ignored}}
#pragma comment(compiler)                          // expected-warning {{'#pragma comment compiler' ignored}}
#pragma comment(exestr, "foo")                     // expected-warning {{'#pragma comment exestr' ignored}}
#pragma comment(user, "foo\abar\nbaz\tsomething")  // expected-warning {{'#pragma comment user' ignored}}
#pragma comment(timestamp)                         // expected-error {{unknown kind of pragma comment}}
#pragma comment(date)                              // expected-error {{unknown kind of pragma comment}}

//--- duplicate.c
// A second copyright pragma in the same translation unit warns.
#pragma comment(copyright, "@(#) Copyright")
#pragma comment(copyright, "Duplicate Copyright") // expected-warning {{'#pragma comment copyright' ignored: it can be specified only once per translation unit}}

//--- raw-string-literal.c
// Raw string literals are accepted.
#pragma comment(copyright, R"foo(printf("Hello (world)");)foo")  // expected-no-diagnostics

//--- concat-escape.c
// Concatenated ordinary string literals and escapes are accepted.
#pragma comment(copyright, "@(#) Hello, " "world\n\t\"@(#) quoted\"") // expected-no-diagnostics

//--- u8-literal.c
// UTF-8-prefixed string literals are rejected.
#pragma comment(copyright, u8"@(#) Hello unicode") // expected-error {{expected string literal in pragma comment}}

//--- wide-literal.c
// Wide string literals are rejected.
#pragma comment(copyright, L"@(#) Hello wide") // expected-error {{expected string literal in pragma comment}}

//--- utf16-literal.c
// UTF-16-prefixed string literals are rejected.
#pragma comment(copyright, u"@(#) Hello utf16") // expected-error {{expected string literal in pragma comment}}

//--- utf32-literal.c
// UTF-32-prefixed string literals are rejected.
#pragma comment(copyright, U"@(#) Hello utf32") // expected-error {{expected string literal in pragma comment}}
// RUN: %clang -### -S -fno-wrapv -fno-strict-overflow -fno-wrapv-pointer -Werror %s 2>&1 | FileCheck -check-prefix=CHECK4 %s --implicit-check-not="-fwrapv-pointer"
// CHECK4: "-fwrapv"

// RUN: %clang -### -S -fno-wrapv-pointer -fno-strict-overflow -fno-wrapv -Werror %s 2>&1 | FileCheck -check-prefix=CHECK4-POINTER %s --implicit-check-not="-fwrapv"
// CHECK4-POINTER: "-fwrapv-pointer"

// RUN: %clang -### -S --target=x86_64-windows-msvc -Werror %s 2>&1 | FileCheck -check-prefix=CHECK5 %s
// CHECK5: "-fwrapv"

// RUN: %clang -### -S -fno-wrapv --target=x86_64-windows-msvc -Werror %s 2>&1 | FileCheck -check-prefix=CHECK6 %s
// CHECK6: "-fno-wrapv"
