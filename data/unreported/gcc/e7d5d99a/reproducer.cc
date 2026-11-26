void g ();

void f ()
{
  #pragma omp dispatch interop (f)
    g ();
}
