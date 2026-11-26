#include <stdio.h>
#include <string.h>



int main(void) {
    const char *request =
        "GET / HTTP/1.1\r\n"
        "cookie: foo=bar\r\n"
        "foo: bar\r\n"
        "\r\n";

    const char *headers = request;
    char line[256];
    char cookie[128] = "";
    char foo[128] = "";
    int saw_cookie = 0, saw_foo = 0;

    while (*headers) {
        const char *eol = strstr(headers, "\r\n");
        size_t len = eol ? (size_t)(eol - headers) : strlen(headers);
        if (len == 0) break;

        if (len >= 7 && strncasecmp(headers, "cookie:", 7) == 0) {
            const char *v = headers + 7;
            while (*v == ' ' || *v == '\t') v++;
            snprintf(cookie, sizeof(cookie), "%.*s", (int)(len - (size_t)(v - headers)), v);
            saw_cookie = 1;
        } else if (len >= 4 && strncasecmp(headers, "foo:", 4) == 0) {
            const char *v = headers + 4;
            while (*v == ' ' || *v == '\t') v++;
            snprintf(foo, sizeof(foo), "%.*s", (int)(len - (size_t)(v - headers)), v);
            saw_foo = 1;
        }

        headers = eol ? eol + 2 : headers + len;
    }

    snprintf(line, sizeof(line), "{cookie=%s, foo=%s}\n", saw_cookie ? cookie : "", saw_foo ? foo : "");
    fputs(line, stdout);
    return 0;
}
// RUN: clang++ -c -std=c++14 %s
// EXPECT-CRASH-ASSERT: EvaluateAsRValue
// EXPECT-CRASH-ASSERT: isValueDependent
// EXPECT-CRASH-ASSERT: evaluator

template <int (*F)(int)> class bar {};

struct S {
  int foo(int a = (char *c)) { return bar<foo>::baz; }
}
