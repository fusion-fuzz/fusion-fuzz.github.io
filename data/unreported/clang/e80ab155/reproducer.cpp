#pragma weak _Z3baxv
auto lambdat = [](int handle __attribute__((use_handle("Fuchsia"))))
    __attribute__((acquire_handle("Fuchsia"))) -> int { return 0; }
