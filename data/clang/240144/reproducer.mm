struct S1 {
  ~S1() noexcept(false);
};
@interface C
- (void)set:(S1)s;
@end
void test(C *c) { [c set:S1()]; }
