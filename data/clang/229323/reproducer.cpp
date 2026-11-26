struct test { int func(); int (^block)() = ^{ return func(); }; };
void g() { test t{}; }
