struct S {
  int x;
  auto f() { return [this](this auto) { return this->x; }; }
};
void g() { S s; s.f(); }
