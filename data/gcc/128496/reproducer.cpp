int q;
struct A
{
  typedef int T;
#pragma omp declare reduction (x : T : omp_out += omp_in + [] (){ return q; }()) initializer (omp_priv = [](){ return 0; }())
};
void test ()
{
#pragma omp declare reduction (x : int : omp_out += omp_in + [] (){ return q; }()) initializer (omp_priv = [](){ return 0; }())
}
