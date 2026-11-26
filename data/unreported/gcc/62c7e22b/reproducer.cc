int d (int v) { return __builtin_constant_p (v); }
consteval int __builtin_constant_p () { return 0; }
