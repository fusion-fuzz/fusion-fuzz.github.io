int x;
void *f (void *h) { return __builtin_coro_promise (h, (__SIZE_TYPE__) &x, true); }
