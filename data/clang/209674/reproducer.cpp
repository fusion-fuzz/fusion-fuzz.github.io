@interface B
@property B1 b1;
void testB1(B *b) {
  b.b1 += { b_makeInt() };
}
