@implementation Blocky {
    int _a;
}
- (int)doAThing {
    ^{
        char self;
        return _a;
    }();
}
@end
