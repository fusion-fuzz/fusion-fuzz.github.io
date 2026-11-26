_Float16 var;
void store (void)
{
  __int128_t v;
  __atomic_store_n (&v, var + 1, __ATOMIC_RELAXED);
}
