template <class T>
  requires (sizeof (T) > 0)
void f (T) {}

void g () { f (1); }
