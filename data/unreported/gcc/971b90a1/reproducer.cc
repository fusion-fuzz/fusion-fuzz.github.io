int a[2];
int &r = a[1];
void f ()
{
#pragma omp parallel private(r)
  ;
}
