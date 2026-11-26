void foo (_Atomic int x)
{
  struct S { int i[x]; unsigned int b : 1; } s;
}
