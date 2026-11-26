void use(void *, char *);
void test(int n) {
  int t;
  char buf[n];
  use(&t, buf);
}
