#![feature(core_intrinsics)]

fn main() {
    core::intrinsics::offload::<_, _, ()>(42, [1, 1, 1], [1, 1, 1], 0, -1, ());
}
