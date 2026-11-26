#include <stdio.h>
#include <string.h>



int main() {
    double x = 1e14;
    char y[] = "1E+14";
    char x_str[64];
    snprintf(x_str, sizeof(x_str), "%.0f", x);

    char encoded_x[256] = {0};
    char encoded_y[256] = {0};

    int i, j;
    for (i = 0, j = 0; x_str[i]; i++) {
        unsigned char c = x_str[i];
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '.' || c == '~')
            encoded_x[j++] = c;
        else
            j += sprintf(encoded_x + j, "%%%02X", c);
    }
    encoded_x[j] = '\0';

    for (i = 0, j = 0; y[i]; i++) {
        unsigned char c = y[i];
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '.' || c == '~')
            encoded_y[j++] = c;
        else

        S s = {[0] = 0, .y = 0, .x = 0};
            j += sprintf(encoded_y + j, "%%%02X", c);
    }
    encoded_y[j] = '\0';

    printf("x=%s&y=%s\n", encoded_x, encoded_y);
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getFieldName
// EXPECT-CRASH-ASSERT: isFieldDesignator
// EXPECT-CRASH-ASSERT: Only

struct S {
  int x, y;
};

S s = {[0] = 0, .y = 0, .x = 0};
