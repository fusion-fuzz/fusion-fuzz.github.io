static long ffl_fusion = (long)(g);
using FourFloats = float __attribute__((ext_vector_type(4)));
FourShorts four_shorts;
using FourShortsVS = short __attribute__((__vector_size__(8)));
void mix_vector_types() {
  FourShortsVS vs;
  (four_shorts == 1 ? vs : ffl_fusion);
}
