@interface Dummies
- (void)inBase;
@end

@interface Base
- (void)inBase __attribute__((objc_direct));
@end

@implementation Derived (Cat)
- (void)test1 {
  (void)@selector(inBase);
}
@end
