typedef struct {
} Class;
Class c = {"ArrayIterator", &m};
printf("%s::%s\n", c.className, c.constructor->name);
