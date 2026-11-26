struct POD {
  id o;
};

struct D {
  virtual void f();
  POD a[2];
};

void g(D &x, D &y) { x = y; }
