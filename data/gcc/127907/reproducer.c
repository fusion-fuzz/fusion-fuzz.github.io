struct A
{
  int x : 13;
};
int __attribute__ ((noinline))
f (void *p)
{
  return ((struct A *)p)->x != 0;
}
int main ()
{
  int a = 0;
  return f (&a);
}
