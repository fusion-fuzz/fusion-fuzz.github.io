@interface Foo {
    id __autoreleasing z; // expected-error {{instance variables cannot have __autoreleasing ownership}}
}
@end
@implementation Foo
@end
