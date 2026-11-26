#include <stdio.h>
#include <arpa/inet.h>

int main(void) {
    const char *s[] = {
        "FC00::1","FC00::1","::","::","::1","::1","fe80:5:6::1","fe80:5:6::1",
        "2001:0db8::1","2001:0db8::1","2001:0010::1","2001:0010::1",
        "240b:0010::1","240b:0010::1","5f::1","5f::1","3ff3::1","3ff3::1"
    };
    for (int i = 0; i < 18; i++) {
        struct in6_addr a;
        if (inet_pton(AF_INET6, s[i], &a) == 1) printf("valid\n");
        else printf("invalid\n");
    }
    return 0;
}
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: EmitCXXMemberOrOperatorMemberCallExpr
// EXPECT-CRASH-ASSERT: mayInsertExtraPadding
// EXPECT-CRASH-ASSERT: unknown

union A {
  bool operator==(const A &) const = default;
}
;
bool foo() { return A() == A(); }
