#include <meta>
static union { int d; long e; };
using V = typename [: parent_of (^^e) :];
V foo (V v)
{
  return v;
}
