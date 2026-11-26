// RUN: export LSAN_OPTIONS=detect_leaks=0
// RUN: rm -rf %t
// RUN: mkdir %t
// RUN: env CINDEXTEST_INVOCATION_EMISSION_PATH=%t not c-index-test -test-load-source all %s
// RUN: %clang -cc1gen-reproducer %t/libclang-* -v | FileCheck %s

// Invocation file must be removed by clang:
// RUN: ls %t | count 0

// RUN: rm -rf %t
// RUN: mkdir %t
// RUN: env CINDEXTEST_INVOCATION_EMISSION_PATH=%t not c-index-test -test-load-source all "-remap-file=%s,%S/Inputs/record-parsing-invocation-remap.c" %s
// RUN: %clang -cc1gen-reproducer %t/libclang-* -v | FileCheck %s

#pragma clang __debug parser_crash

// CHECK: REPRODUCER METAINFO: {"libclang.operation": "parse", "libclang.opts": "1"}

// CHECK: REPRODUCER:
// CHECK-NEXT: {
// CHECK-NEXT: "files":["{{.*}}.c","{{.*}}.sh"]
// CHECK-NEXT: }

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    volatile int sink = 0;
    const char *names[] = {"AAA::$a", "AAA::XXX", "AAA::foo()", "unset(AAA::$a)", "isset(AAAA::$a)", "a()"};
    for (size_t i = 0; i < sizeof(names) / sizeof(names[0]); i++) {
        size_t n = strlen(names[i]);
        char *p = (char *)malloc(n + 1);
        if (!p) return 1;
        memcpy(p, names[i], n + 1);
        sink += (unsigned char)p[0];
        free(p);
    }
    if (sink == 0x7fffffff) puts("");
    puts("okey");
    return 0;
}
