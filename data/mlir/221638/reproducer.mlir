module {
  func.func @main() {
    %0 = test.cse_of_single_block_op inputs(%a, %b) {
  }
}
