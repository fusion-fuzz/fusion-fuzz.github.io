#define F(...) g(__VA_ARGS__)
int g(int, ...);
int x = F (42,
#embed __FILE__ limit (128)
);
