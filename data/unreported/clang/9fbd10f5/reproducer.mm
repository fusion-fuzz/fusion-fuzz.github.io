// RUN: %clang_cc1 -rewrite-objc -fobjc-runtime=macosx-fragile-10.5  %s -o -

@implementation Intf
{
  id ffl_fusion;
  id ivar1[12];

  id **ivar3;

  id (*ivar4) (id, id);
}
@end

// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: IsAccessible
// EXPECT-CRASH-ASSERT: UnprivilegedAccess
// EXPECT-CRASH-ASSERT: best

class A {
public:
  ~A();
};

class B {
  friend class C;

private:
  operator A *();
};

class C : public B {
private:
  using B::operator A *;
};

void foo() { delete C(); }

static long ffl_fusion = (long)(C);
