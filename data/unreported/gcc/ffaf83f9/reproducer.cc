struct arg { decltype (^^int) name; bool none = true; };
void f () { arg a = arg (); }
