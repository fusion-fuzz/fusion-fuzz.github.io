
// RUN: %clang_cc1 %s -verify -fsyntax-only
// RUN: %clang_cc1 %s -verify -fsyntax-only -DDECLAREIT

// a declaration of NSConstantString is not required.
#ifdef DECLAREIT
@interface NSConstantString;
@end
#endif



// CHECK: "-mdefault-visibility-export-mapping=explicit"

// ERROR: error: unsupported option '-mdefault-visibility-export-mapping=' for target 'powerpc-unknown-linux'
id s = @"123"; // simple
id t = @"123" @"456"; // concat
id u = @"123" @ blah; // expected-error {{unexpected token}}


// RUN: %clang -### -S -mdefault-visibility-export-mapping=explicit --target=powerpc-ibm-aix %s 2>&1 | FileCheck %s
// RUN: not %clang -### -S -mdefault-visibility-export-mapping=explicit --target=powerpc-unknown-linux %s 2>&1 | \
// RUN:   FileCheck -check-prefix=ERROR %s

// CHECK: "-mdefault-visibility-export-mapping=explicit"

// ERROR: error: unsupported option '-mdefault-visibility-export-mapping=' for target 'powerpc-unknown-linux'
