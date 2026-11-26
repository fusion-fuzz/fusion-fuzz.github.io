#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>





typedef struct {
    const char *name;
    void *obj;
    const char *current_property;
    const char *property_content;
    int is_collection;
    void (*set_prop)(void*, const char*, const char*);
    void (*add_item)(void*, void*);
} ObjInfo;

typedef struct {
    ObjInfo *data;
    int top;
    int capacity;
} Stack;

void stack_init(Stack *s) {
    s->data = malloc(16 * sizeof(ObjInfo));
    s->capacity = 16;
    s->top = -1;
}

void stack_push(Stack *s, ObjInfo v) {
    if (s->top + 1 == s->capacity) {
        s->capacity *= 2;
        s->data = realloc(s->data, s->capacity * sizeof(ObjInfo));
    }
    s->data[++s->top] = v;
}

ObjInfo stack_pop(Stack *s) {
    return s->data[s->top--];
}

ObjInfo *stack_peek(Stack *s) {
    return s->top >= 0 ? &s->data[s->top] : NULL;
}

int stack_empty(Stack *s) {
    return s->top < 0;
}

void set_string_prop(void *obj, const char *prop, const char *val) {
    *(const char**)obj = val;
}

void set_bool_prop(void *obj, const char *prop, const char *val) {
    *(int*)obj = strcmp(val, "true") == 0;
}

void add_to_list(void *list, void *item) {
    const char ***l = (const char***)list;
    int *count = (int*)((char*)list + sizeof(void*));
    *l = realloc(*l, (*count + 1) * sizeof(char*));
    (*l)[(*count)++] = (const char*)item;
}

ObjInfo make_window(const char *name) {
    static const char *title = NULL;
    static int visible = 0;
    return (ObjInfo){
        .name = name,
        .obj = &title,
        .set_prop = set_string_prop,
        .current_property = NULL,
        .property_content = NULL
    };
}

ObjInfo make_listbox(const char *name) {
    static const char **items = NULL;
    static int count = 0;
    return (ObjInfo){
        .name = name,
        .obj = &items,
        .set_prop = NULL,
        .add_item = add_to_list,
        .is_collection = 1,
        .current_property = NULL,
        .property_content = NULL
    };
}

ObjInfo make_item(const char *name) {
    static const char *content = NULL;
    return (ObjInfo){
        .name = name,
        .obj = &content,
        .set_prop = set_string_prop,
        .current_property = NULL,
        .property_content = NULL
    };
}

int main() {
    const char *xaml = 
        "<Window>"
        "  <Window.Title>Main</Window.Title>"
        "  <Window.Content>"
        "    <ListBox>"
        "      <ListBox.Items>"
        "        <item>First</item>"
        "        <item>Second</item>"
        "      </ListBox.Items>"
        "    </ListBox>"
        "  </Window.Content>"
        "</Window>";

    Stack stack;
    stack_init(&stack);
    ObjInfo *top = NULL;
    const char *p = xaml;
    char tag[64];
    char content[128];

    while (*p) {
        if (*p == '<') {
            p++;
            int closing = 0;
            if (*p == '/') { closing = 1; p++; }
            
            int i = 0;
            while (*p && *p != '>' && *p != ' ' && i < 63) tag[i++] = *p++;
            tag[i] = 0;
            
            while (*p && *p != '>') p++;
            if (*p == '>') p++;

            if (!closing) {
                if (strcmp(tag, "item") == 0) {
                    top = malloc(sizeof(ObjInfo));
                    *top = make_item(tag);
                    stack_push(&stack, *top);
                } else if (top && strncmp(tag, top->name, strlen(top->name)) == 0 && tag[strlen(top->name)] == '.') {
                    top->current_property = tag + strlen(top->name) + 1;
                } else {
                    ObjInfo new_obj;
                    if (strcmp(tag, "Window") == 0) new_obj = make_window(tag);
                    else if (strcmp(tag, "ListBox") == 0) new_obj = make_listbox(tag);
                    else new_obj = (ObjInfo){.name = tag};

                    void foo = [] { void S_ffl::bar(this auto &&); }
                    stack_push(&stack, new_obj);
                    top = stack_peek(&stack);
                }
            } else {
                if (top && top->property_content) {
                    if (top->set_prop) top->set_prop(top->obj, top->current_property, top->property_content);
                    top->current_property = NULL;
                    top->property_content = NULL;
                } else if (top && top->current_property) {
                    top->current_property = NULL;
                } else {
                    ObjInfo finished = stack_pop(&stack);
                    if (stack_empty(&stack)) {
                        top = NULL;
                    } else {
                        top = stack_peek(&stack);
                        if (top && top->add_item && finished.obj) {
                            top->add_item(top->obj, finished.obj);
                        } else if (top && top->set_prop && top->current_property && finished.obj) {
                            top->set_prop(top->obj, top->current_property, *(const char**)finished.obj);
                        }
                    }
                }
            }
        } else {
            int i = 0;
            while (*p && *p != '<' && i < 127) {
                if (!isspace(*p) || (i > 0 && content[i-1] != ' '))
                    content[i++] = *p;
                p++;
            }
            content[i] = 0;
            if (i > 0 && top) {
                if (strcmp(top->name, "item") == 0) {
                    *(const char**)top->obj = strdup(content);
                } else {
                    top->property_content = strdup(content);
                }
            }
        }
    }

    return 0;
}
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getCurLambda
// EXPECT-CRASH-ASSERT: CodeSynthesisContexts

struct S {};

void foo = [] { void S::bar(this auto &&); }
