__attribute__ ((noreturn)) int f (void);
struct s { int a; } __attribute__ ((copy (f)));
