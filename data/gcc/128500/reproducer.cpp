void *g;
template <class T>
int f1 (T t)
{
  return [t] { return g (t); } ();
}
