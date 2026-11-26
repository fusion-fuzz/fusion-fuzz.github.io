struct S { long long a, b; };
@interface A
- (struct S)m:(struct S)x;
@end
struct S f(A *a, struct S s) { return [a m:s]; }
