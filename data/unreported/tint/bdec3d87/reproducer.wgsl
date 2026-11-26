@compute @workgroup_size(1)
fn main() {
  loop {
    continuing {
      loop { break; }
      break if true;
    }
  }
}
