@interface I
@end

@implementation I
void f(auto) { [](auto) {}(0); }
void g() { f(0); }
@end
