struct B { B (); ~B (); };
void f () { B bs[2] = { B () }; }
