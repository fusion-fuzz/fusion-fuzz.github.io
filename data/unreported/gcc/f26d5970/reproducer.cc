#include <meta>

struct A { union { int a; }; };
using U = typename [: parent_of (^^A::a) :];

U foo () {}
