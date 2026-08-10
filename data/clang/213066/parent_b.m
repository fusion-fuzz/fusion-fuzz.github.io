#include <stdio.h>

typedef struct Class {
    int id;
    struct Class *parent;
    void (*hello)(struct Class *);
} Class;

void hello(Class *self) {
    printf("%d\n", self->id);
    if (self->parent) {
        self->parent->hello(self->parent);
    }
}

int main() {
    Class parent = {1, NULL, hello};
    Class child = {2, &parent, hello};
    child.hello(&child);
    return 0;
}