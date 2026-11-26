struct W { int n; int m = n; };
struct A : W { int x; int y = x; operator int (); };
struct C { int x; int b = A{x}; };
