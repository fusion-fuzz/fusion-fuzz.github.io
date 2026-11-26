int i;

bool f ()
{
  return __builtin_is_within_lifetime (&i);
}
