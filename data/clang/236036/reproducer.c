__attribute__((target("default"))) int f(void) { return 0; }
__attribute__((target("cpu=pwr10"))) int f(void) { return 1; }
int g(void) { return f(); }
