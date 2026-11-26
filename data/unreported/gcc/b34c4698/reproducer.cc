struct __attribute__((transaction_callable)) B { };
struct R : B { R (int); R (const R &); };
R r (1);
