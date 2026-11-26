@protocol P
- (void)m;
@end
@interface A <P>
- (void)m;
@end
@protocol P
@end
@interface A <P>
@end
void f(A *a) { [a m]; }
