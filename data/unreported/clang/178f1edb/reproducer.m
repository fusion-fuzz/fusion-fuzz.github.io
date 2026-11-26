@protocol P1
@end
void p(int);
void f(void) { p([@protocol(P1) unknownMethod]); }
