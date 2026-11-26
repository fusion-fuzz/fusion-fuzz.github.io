#include <stdio.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: GetSignedVectorType
// EXPECT-CRASH-ASSERT: Context.getTypeSize
// EXPECT-CRASH-ASSERT: Unhandled

using i512x3 = _BitInt(512) __attribute__((ext_vector_type(3)));

i512x3 foo(i512x3 a) { return a > 42; }
#include <stdio.h>
#include <string.h>

typedef void (*method_t)(void);

typedef struct {
    const char *name;
    method_t run;
    method_t say;
    const char *run_alias;
    const char *say_alias;
} ClassInfo;

void trait1_run(void) {}
void trait1_say(void) {}
void trait2_run(void) {}
void trait2_say(void) {}

int main(void) {
    ClassInfo myclass;
    myclass.name = "MyClass";
    myclass.run = trait2_run;
    myclass.say = trait1_say;
    myclass.run_alias = "execute";
    myclass.say_alias = "talk";

    printf("Trait aliases:\n");
    printf("  %s => run\n", myclass.run_alias);
    printf("  %s => say\n", myclass.say_alias);

    printf("Traits:\n");
    printf("  Trait1\n");
    printf("  Trait2\n");

    if (myclass.run) myclass.run();
    if (myclass.say) myclass.say();

    return 0;
}
