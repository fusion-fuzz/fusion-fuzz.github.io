void foo ()
{
  int foo (void) __attribute__ ((target ("sse")));
  int foo (void) __attribute__ ((target ("default")));
}
