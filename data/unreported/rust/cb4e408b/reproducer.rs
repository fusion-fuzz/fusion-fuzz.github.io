#![no_std]
#![no_core]
#![feature(no_core, pin_ergonomics, lang_items)]
#![allow(incomplete_features)]

// Seed A (non-inlined items)

// This checks that calling `Drop::pin_drop` and `Drop::drop` explicitly is unsafe
// and requires unsafe block.
// Note that this tiny-`core` library ignores `Unpin` related stuffs as we don't care about that,
// and thus the `Pin` type is just simply a wrapper around a pointer.

#[lang = "drop"]
trait Drop {
    fn drop(&mut self) {
        Self::pin_drop(Pin { pointer: self });
        //~^ ERROR call `Drop::pin_drop` explicitly is unsafe and requires unsafe block
        unsafe { Self::pin_drop(Pin { pointer: self }) }; // ok
    }

    fn pin_drop(self: Pin<&mut Self>) {
        Self::drop(self.pointer);
        //~^ ERROR call `Drop::drop` explicitly is unsafe and requires unsafe block
        unsafe { Self::drop(self.pointer) }; // ok
    }
}

#[lang = "pin"]
struct Vec3 { x: f64, y: f64, z: f64 }
struct BoundingBox { minimum: Vec3, maximum: Vec3 }
struct Entity { position: Vec3, bounding_box: BoundingBox, height: f32, width: f32, experience: i16 }
struct WorldManager;
impl WorldManager { fn get_chunk(&self, _: UniversalCoords) -> Option<()> { None } }
struct UniversalCoords;
impl UniversalCoords { fn from_abs_world(_: Vec3) -> Self { UniversalCoords } }
struct AbsWorldCoords(f64, f64, f64);

fn push_out_of_blocks(_: AbsWorldCoords) {}

fn main_17d81fba() {
    let mut entity = Entity {
        position: Vec3 { x: 0.0, y: 0.0, z: 0.0 },
        bounding_box: BoundingBox { minimum: Vec3 { x: 0.0, y: 0.0, z: 0.0 }, maximum: Vec3 { x: 1.0, y: 1.0, z: 1.0 } },
        height: 0.5,
        width: 0.5,
        experience: 100,
    };
    let world = WorldManager;

    let mid_y = (entity.bounding_box.minimum.y + entity.bounding_box.maximum.y) / 2.0;
    push_out_of_blocks(AbsWorldCoords(entity.position.x, mid_y, entity.position.z));
    let chunk = world.get_chunk(UniversalCoords::from_abs_world(entity.position));
    if chunk.is_none() { return; }
}
// This is a dummy `Pin` type that is just simply a wrapper around a pointer.
struct Pin<T> {
    pointer: T,
}

#[lang = "deref"]
trait Deref: PointeeSized {
    #[lang = "deref_target"]
    type Target: PointeeSized;

    fn deref(&self) -> &Self::Target;
}

#[lang = "deref_mut"]
trait DerefMut: Deref + PointeeSized {
    fn deref_mut(&mut self) -> &mut Self::Target;
}

impl<Ptr: Deref> Deref for Pin<Ptr> {
    type Target = Ptr::Target;

    fn deref(&self) -> &Self::Target {
        &*self.pointer
    }
}

// skip the `Unpin` check, as this test doesn't care about that.
impl<Ptr: DerefMut> DerefMut for Pin<Ptr> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut *self.pointer
    }
}

impl<T: PointeeSized> Deref for &mut T {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        self
    }
}


#[lang = "copy"]
trait Copy {}

#[lang = "sized"]
trait Sized: MetaSized {}

#[lang = "meta_sized"]
trait MetaSized: PointeeSized {}

#[lang = "pointee_sized"]
trait PointeeSized {}

#[lang = "legacy_receiver"]
trait LegacyReceiver: PointeeSized {}

impl<T: PointeeSized> LegacyReceiver for &T {}
impl<T: PointeeSized> LegacyReceiver for &mut T {}
impl<Ptr: LegacyReceiver> LegacyReceiver for Pin<Ptr> {}

fn main_a23e7783() {}


// Seed B (non-inlined items)
struct Vec3_b17d81f { x: f64, y: f64, z: f64 }
struct BoundingBox_b17d81f { minimum: Vec3_b17d81f, maximum: Vec3_b17d81f }
struct Entity_b17d81f { position: Vec3_b17d81f, bounding_box: BoundingBox_b17d81f, height: f32, width: f32, experience: i16 }
struct WorldManager_b17d81f;
impl WorldManager_b17d81f { fn get_chunk(&self, _: UniversalCoords_b17d81f) -> Option<()> { None } }
struct UniversalCoords_b17d81f;
impl UniversalCoords_b17d81f { fn from_abs_world(_: Vec3_b17d81f) -> Self { UniversalCoords_b17d81f } }
struct AbsWorldCoords_b17d81f(f64, f64, f64);

fn push_out_of_blocks_b17d81f(_: AbsWorldCoords_b17d81f) {}

fn main_17d81fba_b17d81f() {
    let mut entity = Entity_b17d81f {
        position: Vec3_b17d81f { x: 0.0, y: 0.0, z: 0.0 },
        bounding_box: BoundingBox_b17d81f { minimum: Vec3_b17d81f { x: 0.0, y: 0.0, z: 0.0 }, maximum: Vec3_b17d81f { x: 1.0, y: 1.0, z: 1.0 } },
        height: 0.5,
        width: 0.5,
        experience: 100,
    };
    let world = WorldManager_b17d81f;

    let mid_y = (entity.bounding_box.minimum.y + entity.bounding_box.maximum.y) / 2.0;
    push_out_of_blocks_b17d81f(AbsWorldCoords_b17d81f(entity.position.x, mid_y, entity.position.z));
    let chunk = world.get_chunk(UniversalCoords_b17d81f::from_abs_world(entity.position));
    if chunk.is_none() { return; }
}

fn main() {

    println!("FFL Fusion Done");
}
