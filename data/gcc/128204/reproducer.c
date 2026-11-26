struct A { char *a; };
struct A strlen (char *);

int f (char *p)
{
  struct A r = strlen (p);
  return r.a != 0;
}
