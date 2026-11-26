struct W { int w; W () : w (0) {} W (int x) : w (x) {} };
  template <typename T1, typename T2, typename T3, typename T4, typename T5>
  int foo ()
  {
    #pragma omp declare reduction (foo : T4 : omp_out *= omp_in) initializer (omp_priv (v)) // { dg-error "initializer refers to variable" }
  }
  int x = foo <long int, char, short, _Complex double, W> ();
