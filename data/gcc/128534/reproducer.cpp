namespace N { }

template<decltype(^^int) R>
void g ()
{
  double d = [:R:]::template pi<double>;
}

void h () { g<^^N>(); }
