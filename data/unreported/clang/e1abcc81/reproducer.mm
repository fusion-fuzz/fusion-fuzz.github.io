#pragma STDC FENV_ACCESS ON
@protocol NSObject @end
@interface NSObject @end
@protocol ProtocolX <NSObject>
@end
@protocol ProtocolY <NSObject>
@end
@interface ClassA : NSObject
@end
@interface ClassB : ClassA <ProtocolY, ProtocolX>
@end
@interface OtherClass : NSObject
@property (nonatomic, copy) ClassB<ProtocolX> *aProperty;
@end
@implementation OtherClass
- (ClassA<ProtocolY> *)aMethod {
    return (ClassB *)self.aProperty;
}
@end
