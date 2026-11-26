func test_assert(x: Int, y: Int) -> Int {
  assert(x >= y , "x smaller than y")
  return x + y
}

func test_fatal(x: Int, y: Int) -> Int {
  if x > y {
    return x + y
  }
  preconditionFailure("Human nature ...")
}

func testprecondition_check(x: Int, y: Int) -> Int {
  precondition(x > y, "Test precondition check")
  return x + y
}

func test_partial_safety_check(x: Int, y: Int) -> Int {
  assert(x > y, "Test partial safety check")
  return x + y
}

let __fusion_0 = x + y

func a<each b>(repeat each b, repeat each b)
a(repeat (
