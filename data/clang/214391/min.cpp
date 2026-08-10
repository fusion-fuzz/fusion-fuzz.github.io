struct Base {
  char a;
};
struct Derived_1 : virtual Base
{
  char b;
};
#pragma pack(1)
struct Derived_2 : Derived_1 {
};
struct __attribute__((aligned(4))) Empty {}
empty;
struct Char { char a; }
cbase;
struct D : virtual Char, public Derived_2 {
  [[no_unique_address]] Empty e0;
  [[no_unique_address]] Empty e1;
  unsigned a : 24; // keep as 24bits
}
d;
