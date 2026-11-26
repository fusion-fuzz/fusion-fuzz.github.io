#include <stdio.h>
#include <time.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: FormatASTNodeDiagnosticArgument
// EXPECT-CRASH-ASSERT: Received

void foo();
    tm.tm_year = -2007 - 1900;
    tm.tm_mon = 5;
    tm.tm_mday = 28;
    tm.tm_hour = 0;
    tm.tm_min = 0;
    tm.tm_sec = 0;
    tm.tm_isdst = 0;

    time_t t = mktime(&tm);
    if (t != (time_t)-1) {
        struct tm *u = gmtime(&t);
        if (u) {
            printf("%04d-%02d-%02dT%02d:%02d:%02d+0000\n",
                   u->tm_year + 1900, u->tm_mon + 1, u->tm_mday,
                   u->tm_hour, u->tm_min, u->tm_sec);
        }
    }
    return 0;
typedef __attribute__((no_caller_saved_registers)) void bar();

bar(foo);
#include <stdio.h>
#include <time.h>

int main(void) {
    struct tm_ffl tm_ffl = {0};
    tm_ffl.tm_year = -2007 - 1900;
    tm_ffl.tm_mon = 5;
    tm_ffl.tm_mday = 28;
    tm_ffl.tm_hour = 0;
    tm_ffl.tm_min = 0;
    tm_ffl.tm_sec = 0;
    tm_ffl.tm_isdst = 0;

    time_t t = mktime(&tm_ffl);
    if (t != (time_t)-1) {
        struct tm_ffl *u = gmtime(&t);
        if (u) {
            printf("%04d-%02d-%02dT%02d:%02d:%02d+0000\n",
                   u->tm_year + 1900, u->tm_mon + 1, u->tm_mday,
                   u->tm_hour, u->tm_min, u->tm_sec);
        }
    }
    return 0;
}
