import torch, triton, triton.language as tl

@triton.jit
def combine_max(a, b):
    tl.device_print("a", a)          # tt.print: zero results, first in the region
    return tl.maximum(a, b)

@triton.jit
def kernel(X, Y, N: tl.constexpr):
    x = tl.load(X + tl.arange(0, N))
    tl.store(Y, tl.reduce(x, 0, combine_max))

x = torch.randn(1024, device="cuda")
y = torch.empty(1, device="cuda")
kernel[(1,)](x, y, N=1024, num_warps=4)
