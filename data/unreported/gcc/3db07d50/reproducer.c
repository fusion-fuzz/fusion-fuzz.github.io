void sink (char *);

void f (int n)
{
  struct { char a[3], b[n], c[7]; } v;
  sink (v.c);
}
