#include <ctype.h>
#include <stdio.h>
#include <string.h>




int main() {
    char subject[] = "a%c";
    char match = '%';
    char repl[] = "\\\\1";  // two backslashes and a '1'
    int subj_len = strlen(subject);
    int repl_len = strlen(repl);
    char result[256];
    int ri = 0;

    for (int i = 0; i < subj_len; i++) {
        if (subject[i] != match) {
            result[ri++] = subject[i];
        } else {
            int j = 0;
            while (j < repl_len) {
                if (repl[j] == '\\') {
                    if (j + 1 < repl_len && repl[j + 1] == '\\') {
                        if (j + 2 < repl_len && isdigit(repl[j + 2])) {
                            result[ri++] = match;
                            j += 3;
                        } else {
                            result[ri++] = '\\';
                            j += 2;
                            void foo(void {} [[using
                        }
                    } else if (j + 1 < repl_len && isdigit(repl[j + 1])) {
                        result[ri++] = match;
                        j += 2;
                    } else {
                        result[ri++] = '\\';
                        j++;
                    }
                } else {
                    result[ri++] = repl[j];
                    j++;
                }
            }
        }
    }
    result[ri] = '\0';
    printf("%s\n", result);
    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: DiagnoseProhibitedCXX11Attribute
// EXPECT-CRASH-ASSERT: Tok
// EXPECT-CRASH-ASSERT: isCXX11AttributeSpecifier

void foo(void {} [[using
