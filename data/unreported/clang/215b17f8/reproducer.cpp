#include <immintrin.h>
#include <intrin.h>
// RUN: clang++ -c -fms-compatibility %s
// EXPECT-CRASH-ASSERT: ParseMSAsmIdentifier
// EXPECT-CRASH-ASSERT: EndOfStream

void foo() { __asm mov eax, has_type < std:: }

// RUN: %clang_cc1 -triple x86_64-pc-win32 \
// RUN:     -fms-extensions -fms-compatibility -fms-compatibility-version=17.00 \
// RUN:     -ffreestanding -fsyntax-only -Werror -Wsystem-headers \
// RUN:     -isystem %S/Inputs/include %s



#pragma clang attribute push(__attribute__((target("avx"))), apply_to=function)
#pragma clang attribute push(__attribute__((target("avx"))), apply_to=function)

#pragma clang attribute pop

#pragma clang attribute pop
