var<private> x: u64 = 5lu;

@compute @workgroup_size(1)
fn main() {
  _ = countLeadingZeros(x);
}
