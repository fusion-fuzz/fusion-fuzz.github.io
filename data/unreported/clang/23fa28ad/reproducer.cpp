// RUN: clang++ -c %s
// EXPECT-CRASH-NOASSERT

struct S1 {
  ~S1() noexcept(foo());
};

struct S2 {
  S1 s1;
  ~S2() {}
};

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
typedef struct Vec3 { float x, y, z; }
Vec3;
typedef struct Mat4 { float m[16]; }
Mat3;
typedef struct CollisionObject CollisionObject;
typedef struct BroadphaseProxy BroadphaseProxy;
typedef float (*AddSingleResultFn)(void* result, bool normalInWorldSpace);
typedef bool (*NeedsCollisionFn)(BroadphaseProxy* proxy);
typedef struct RayResultCallback {
    void* native;
    AddSingleResultFn addSingleResult;
    NeedsCollisionFn needsCollision;
    float closestHitFraction;
    int collisionFilterGroup;
    int collisionFilterMask;
    CollisionObject* collisionObject;
    unsigned int flags;
}
RayResultCallback;
typedef struct LocalRayResult {
    CollisionObject* collisionObject;
    float hitFraction;
    Vec3 hitNormalLocal;
}
LocalRayResult;
static float g_closestHitFraction = 1.0f;
float rayAddSingleResult(void* result, bool normalInWorldSpace) {
    LocalRayResult* r = (LocalRayResult*)result;
    if (r->hitFraction <= g_closestHitFraction) {
        g_closestHitFraction = r->hitFraction;
    }
    return g_closestHitFraction;

struct S2 {
  S1 s1;
  ~S2() {}
};
}
bool rayNeedsCollision(BroadphaseProxy* proxy) {
    (void)proxy;
    return true;
}
RayResultCallback* createRayCallback() {
    RayResultCallback* cb = malloc(sizeof(RayResultCallback));
    cb->addSingleResult = rayAddSingleResult;
    cb->needsCollision = rayNeedsCollision;
    cb->closestHitFraction = 1.0f;
    cb->native = (void*)0x1;
    return cb;
}
void destroyRayCallback(RayResultCallback* cb) {
    free(cb);
}
void rayTest(RayResultCallback* cb, Vec3 from, Vec3 to) {
    (void)from; (void)to;
    LocalRayResult result = { .collisionObject = NULL, .hitFraction = 0.5f, .hitNormalLocal = {0,1,0} };
    cb->addSingleResult(&result, true);
}
int main() {
    RayResultCallback* cb = createRayCallback();
    Vec3 from = {0,0,0}, to = {10,0,0};
    rayTest(cb, from, to);
    destroyRayCallback(cb);
    rayTest(cb, from, to);
    return 0;
}
