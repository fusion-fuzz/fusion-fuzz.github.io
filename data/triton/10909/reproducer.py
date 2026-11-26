import torch, triton, triton.language as tl

@triton.jit
def kernel(dst, src, N, BLOCK: tl.constexpr):
    pid = tl.program_id(0)
    offs = pid * BLOCK + tl.arange(0, BLOCK)
    offs = tl.max_contiguous(offs, -7)      # <-- negative hint value
    mask = offs < N
    x = tl.load(src + offs, mask=mask)
    tl.store(dst + offs, x, mask=mask)

N = 1024
src = torch.randn(N, device="cuda")
dst = torch.empty(N, device="cuda")
kernel[(triton.cdiv(N, 1024),)](dst, src, N, BLOCK=1024)  # process aborts here
print("unreached")
