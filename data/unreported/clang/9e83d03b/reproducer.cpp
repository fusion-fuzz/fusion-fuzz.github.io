#include <stdio.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: LookupSpecialMember
// EXPECT-CRASH-ASSERT: CanDeclareSpecialMemberFunction
// EXPECT-CRASH-ASSERT: doing

struct S {
  constexpr int p() : a {};
  static S (&r)[1] = {2, 3};
  strcat(out, iface);
  (void)strstr(out, "include");
  (void)strstr(out, iface);
  return 0;
}
#include <stdio.h>
#include <string.h>

int main(void) {
    char out[128];
    const char *iface = "someInterface";
    strcpy(out, "include");
    strcat(out, iface);
    (void)strstr(out, "include");
    (void)strstr(out, iface);
    return 0;
}
