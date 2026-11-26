// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: checkForConstantInitialization
// EXPECT-CRASH-ASSERT: WasEvaluated
// EXPECT-CRASH-ASSERT: already

__thread const int m = reinterpret_cast<T>(m)

#include <stdio.h>
#include <stdlib.h>

#define TYPE_EXCEPTION 0
#define TYPE_ERROR 1

int main() {
    struct BaseException {
        int type;
        struct BaseException *previous;
    };

    // Build original chain: Exception -> Error
    struct BaseException *inner = malloc(sizeof(struct BaseException));
    inner->type = TYPE_ERROR;
    inner->previous = NULL;

    struct BaseException *outer = malloc(sizeof(struct BaseException));
    outer->type = TYPE_EXCEPTION;
    outer->previous = inner;

    // Print before
    printf("before: outer type=%s, previous type=%s\n",
           outer->type == TYPE_EXCEPTION ? "Exception" : "Error",
           outer->previous->type == TYPE_EXCEPTION ? "Exception" : "Error");

    // Serialize: write outer type, then inner type, then NULL sentinel
    unsigned char buffer[256];
    int pos = 0;
    buffer[pos++] = (unsigned char)outer->type;
    buffer[pos++] = (unsigned char)outer->previous->type;
    buffer[pos++] = 0xFF; // null terminator for inner's previous

    // Buggy deserialize: ignore inner type and always set it to Exception
    int outer_type = buffer[0];
    struct BaseException *outer2 = malloc(sizeof(struct BaseException));
    outer2->type = outer_type;

    // bug: inner type from buffer[1] is ignored
    struct BaseException *inner2 = malloc(sizeof(struct BaseException));
    inner2->type = TYPE_EXCEPTION; // always Exception, loses original Error
    inner2->previous = NULL;
    outer2->previous = inner2;

    // Print after
    printf("after : outer type=%s, previous type=%s\n",
           outer2->type == TYPE_EXCEPTION ? "Exception" : "Error",
           outer2->previous->type == TYPE_EXCEPTION ? "Exception" : "Error");

    // Cleanup (not required for fuzzing, but good practice)
    free(inner);
    free(outer);
    free(inner2);
    free(outer2);

    return 0;
}
