enable chromium_experimental_resource_table;
const kHouseTexture = 4u;
@fragment fn fs() {
    let tex = hasResource<texture_2d<i32>>(kHouseTexture);
}
@group(0) @binding(0)
var tex : texture_storage_2d<rgba8unorm, read_write>;
