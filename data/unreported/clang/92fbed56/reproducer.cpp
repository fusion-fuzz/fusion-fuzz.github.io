
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: UpdateAlignment
// EXPECT-CRASH-ASSERT: isPowerOf2_64
// EXPECT-CRASH-ASSERT: not

#pragma ms_struct on

struct S {
// DWARFv5-O: DW_AT_dwo_name ("{{.*}}.file.dwo")
// DWARFv5-O-NOT: DW_TAG_subprogram
// DWARFv5-DWO: DW_TAG_subprogram

int main(void) {}
  _BitInt(129) x : 128;
};

static_assert(sizeof(S), "");
