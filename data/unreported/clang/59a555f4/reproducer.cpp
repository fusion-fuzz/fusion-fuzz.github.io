#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: adjustDeclContextForDeclaratorDecl
// EXPECT-CRASH-ASSERT: InEnclosingNamespaceSetOf
// EXPECT-CRASH-ASSERT: redeclaration

extern "C" {
extern int strcmp(const char *s, const char *t) throw();

namespace A {

int A::strcmp(const char *s, const char *t) { return strcmp(s, t); }
} // namespace A
}





typedef enum { TYPE_INT, TYPE_FLOAT, TYPE_STRING } PropType;

typedef struct {
    PropType type;
    union { int i; float f; char *s; } value;
} ParsedValue;

typedef struct {
    int op;
    char *prop_name;
    char *refval_str;
    ParsedValue *cache;
    PropType cached_type;
} TriggerCondition;

PropType find_prop_type(const char *name) {
    if (strcmp(name, "width") == 0) return TYPE_INT;
    if (strcmp(name, "opacity") == 0) return TYPE_FLOAT;
    if (strcmp(name, "title") == 0) return TYPE_STRING;
    return TYPE_INT;
}

ParsedValue *parse_value(const char *str, PropType type) {
    ParsedValue *v = malloc(sizeof(ParsedValue));
    v->type = type;
    switch (type) {
        case TYPE_INT: v->value.i = atoi(str); break;
        case TYPE_FLOAT: v->value.f = atof(str); break;
        case TYPE_STRING: v->value.s = strdup(str); break;
    }
    return v;
}

int compare(TriggerCondition *tc, void *prop_value) {
    PropType actual_type = find_prop_type(tc->prop_name);
    
    if (!tc->cache || tc->cached_type != actual_type) {
        free(tc->cache);
        tc->cache = parse_value(tc->refval_str, actual_type);
        tc->cached_type = actual_type;
    }
    
    switch (actual_type) {
        case TYPE_INT:
            return *(int*)prop_value == tc->cache->value.i;
        case TYPE_FLOAT:
            return *(float*)prop_value == tc->cache->value.f;
        case TYPE_STRING:
            return strcmp((char*)prop_value, tc->cache->value.s) == 0;
    }
    return 0;
}

int main() {
    TriggerCondition tc = { .op = 0, .prop_name = "width", .refval_str = "100", .cache = NULL, .cached_type = TYPE_INT };
    int val1 = 100;
    printf("%d\n", compare(&tc, &val1));
    
    tc.prop_name = "opacity";
    float val2 = 0.5f;
    printf("%d\n", compare(&tc, &val2));
    
    tc.prop_name = "width";
    int val3 = 200;
    printf("%d\n", compare(&tc, &val3));
    
    free(tc.cache);
    return 0;
    return 0;
}
