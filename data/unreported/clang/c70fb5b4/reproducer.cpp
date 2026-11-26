#include <stdio.h>
#include <setjmp.h>
#include <stdlib.h>
#include <string.h>

typedef struct Exception {
    char *message;
    struct Exception *previous;
} Exception;

Exception *current_exception = NULL;
jmp_buf outer_env, inner_env;
int in_inner = 0;

void throw_exception(Exception *e) {
    current_exception = e;
    if (in_inner) longjmp(inner_env, 1);
    else longjmp(outer_env, 1);
}

Exception* create_exception(const char *msg, Exception *prev) {
    Exception *e = malloc(sizeof(Exception));
    e->message = malloc(strlen(msg) + 1);
    strcpy(e->message, msg);
    e->previous = prev;
    return e;
}

int main() {
    Exception *e1 = create_exception("Foo", NULL);
    if (setjmp(outer_env) == 0) {
        if (setjmp(inner_env) == 0) {
            in_inner = 1;
            throw_exception(create_exception("Bar", e1));
        }
        in_inner = 0;
        throw_exception(e1);
    } else {
        printf("%s", current_exception->message);
        if (current_exception->previous) printf("; %s", current_exception->previous->message);
        printf("\n");
    }

    e1 = create_exception("Foo", NULL);
    if (setjmp(outer_env) == 0) {
        if (setjmp(inner_env) == 0) {
            in_inner = 1;
            throw_exception(create_exception("Bar", e1));
        }
        in_inner = 0;
        throw_exception(create_exception("Dummy", e1));
    } else {
        printf("%s", current_exception->message);
        if (current_exception->previous) printf("; %s", current_exception->previous->message);
        printf("\n");
    }

    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: SubstFunctionType
// EXPECT-CRASH-ASSERT: OldTInfo
// EXPECT-CRASH-ASSERT: substituting

template <class T> struct S {
  template <class U>
  using type1 = decltype([] {
    struct B {};
    B b;
  });

  void foo() { using T1 = S<int>::type1<int>; }
}
#include <stdio.h>
#include <setjmp.h>
#include <stdlib.h>
#include <string.h>

typedef struct Exception_ffl {
    char *message;
    struct Exception_ffl *previous;
} Exception_ffl;

Exception_ffl *current_exception = NULL;
jmp_buf outer_env, inner_env;
int in_inner = 0;

void throw_exception_ffl(Exception_ffl *e) {
    current_exception = e;
    if (in_inner) longjmp(inner_env, 1);
    else longjmp(outer_env, 1);
}

Exception_ffl* create_exception_ffl(const char *msg, Exception_ffl *prev) {
    Exception_ffl *e = malloc(sizeof(Exception_ffl));
    e->message = malloc(strlen(msg) + 1);
    strcpy(e->message, msg);
    e->previous = prev;
    return e;
}

int main_ffl() {
    Exception_ffl *e1 = create_exception_ffl("Foo", NULL);
    if (setjmp(outer_env) == 0) {
        if (setjmp(inner_env) == 0) {
            in_inner = 1;
            throw_exception_ffl(create_exception_ffl("Bar", e1));
        }
        in_inner = 0;
        throw_exception_ffl(e1);
    } else {
        printf("%s", current_exception->message);
        if (current_exception->previous) printf("; %s", current_exception->previous->message);
        printf("\n");
    }

    e1 = create_exception_ffl("Foo", NULL);
    if (setjmp(outer_env) == 0) {
        if (setjmp(inner_env) == 0) {
            in_inner = 1;
            throw_exception_ffl(create_exception_ffl("Bar", e1));
        }
        in_inner = 0;
        throw_exception_ffl(create_exception_ffl("Dummy", e1));
    } else {
        printf("%s", current_exception->message);
        if (current_exception->previous) printf("; %s", current_exception->previous->message);
        printf("\n");
    }

    return 0;
}
