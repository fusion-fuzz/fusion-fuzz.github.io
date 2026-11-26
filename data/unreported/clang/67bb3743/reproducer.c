typedef float float4 __attribute__((ext_vector_type(4)));
float4 f(void (^b)(void)) { return (float4)b; }
