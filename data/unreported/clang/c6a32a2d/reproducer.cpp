#include <stdio.h>
#include <time.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

namespace bar {
struct S {};
} // namespace bar

    printf("%dM / %dD %dH %dM\n", months, days, hours, mins);
    return 0;
int ::bar::S::baz::*foo;
#include <stdio.h>
#include <time.h>

int main(void) {
    struct tm start = {0}, end = {0};
    start.tm_year = 2012 - 1900;
    start.tm_mon = 5;
    start.tm_mday = 1;
    start.tm_isdst = -1;
    end.tm_year = 2012 - 1900;
    end.tm_mon = 11;
    end.tm_mday = 1;
    end.tm_isdst = -1;

    time_t t1 = mktime(&start);
    time_t t2 = mktime(&end);
    if (t1 == (time_t)-1 || t2 == (time_t)-1) return 0;

    struct tm *a = localtime(&t1);
    struct tm *b = localtime(&t2);
    if (!a || !b) return 0;

    int months = b->tm_mon - a->tm_mon + 12 * (b->tm_year - a->tm_year);
    int days = b->tm_mday - a->tm_mday;
    int hours = b->tm_hour - a->tm_hour;
    int mins = b->tm_min - a->tm_min;

    printf("%dM / %dD %dH %dM\n", months, days, hours, mins);
    return 0;
}
