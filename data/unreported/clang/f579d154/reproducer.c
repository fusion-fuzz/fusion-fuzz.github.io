#include <stdio.h>
#include <string.h>



typedef struct {
    const char *name;
    int has_prop;
    const char *decl;
    const char *parent;
} ClassInfo;

int main(void) {
    ClassInfo classes[] = {
        {"A", 0, NULL, NULL},
        {"B", 1, "B", "A"},
        {"C", 1, "C", "B"},
        {"D", 0, NULL, "C"},
        {"E", 0, NULL, "D"},
        {"F", 1, "F", "E"}
    };

    for (size_t i = 0; i < sizeof(classes) / sizeof(classes[0]); i++) {
        const char *decl = "N/A";
        for (size_t j = i; ; ) {
            if (classes[j].has_prop) {
                decl = classes[j].decl;
                break;
            }
            if (!classes[j].parent) break;
            for (size_t k = 0; k < sizeof(classes) / sizeof(classes[0]); k++) {
                if (strcmp(classes[k].name, classes[j].parent) == 0) {
                    j = k;
                    break;
                }
            }
            if (strcmp(classes[j].name, classes[i].name) == 0) break;
        }
        printf("%s => %s\n", classes[i].name, decl);
    }

    return 0;
}
