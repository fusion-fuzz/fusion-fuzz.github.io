struct A { virtual ~A (); };
struct D : virtual A { };
typedef struct : D { } S;
void f () { S s; }
