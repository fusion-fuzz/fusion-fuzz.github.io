struct S { ~S (); };
void __builtin_unreachable ();
void foo ()
{
  S a;
  __builtin_unreachable ();
}
