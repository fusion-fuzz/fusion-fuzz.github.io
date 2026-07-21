@interface I
@property (atomic) id atomic_prop;
@implementation I
@synthesize atomic_prop, atomic_prop1;
- (id) atomic_prop { return 0; }
- (id) atomic_prop;
