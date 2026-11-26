#include <stdio.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: CheckClassTemplate
// EXPECT-CRASH-ASSERT: PrevClassTemplate
// EXPECT-CRASH-ASSERT: specialization

class C {
    return 0;
  class P {};

  template <typename T1> class FT {
    template <typename T2> class BT1 {};
  };

  template <> template <typename..., foo> class FT<C::P>::BT2 {};
};
#include <stdio.h>
#include <string.h>

int main(void) {
    const char *json = "{\"org\":{\"name\":\"test\",\"id\":0}}\0extra";
    size_t len = strlen(json);
    char buf[256];
    memcpy(buf, json, len);
    buf[len] = '\0';
    printf("strlen=%zu, buf=%s\n", len, buf);
    return 0;
}
