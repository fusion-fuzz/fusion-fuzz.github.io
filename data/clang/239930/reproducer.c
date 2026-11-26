void f(unsigned long size, void *ptr) { __atomic_always_lock_free(size, ptr); }
