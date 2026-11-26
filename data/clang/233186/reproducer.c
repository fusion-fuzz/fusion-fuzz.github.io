typedef unsigned __int128 v2u128 __attribute__((vector_size(32)));
/* safe variable shift: lanes with an out-of-range amount become 0 */
v2u128 shr_safe(v2u128 x, v2u128 n) {
  v2u128 ok = (v2u128)(n < 128);          /* all-ones where the amount is in range */
  return (x >> n) & ok;
}
