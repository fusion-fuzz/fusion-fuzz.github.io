#!/usr/bin/env python3
"""
Minimal Triton FP4 tl.dot_scaled code-growth reproducer.

Cold-cache examples:
  python3 poc.py
  timeout 10m python3 poc.py --block-m 256
  python3 poc.py --save-asm asm-128
"""

from __future__ import annotations

import argparse
import hashlib
import os
import platform
import sys
import tempfile
import time
from pathlib import Path

# Make each invocation a cold compile unless the caller supplies a cache.
os.environ.setdefault("TRITON_CACHE_DIR", tempfile.mkdtemp(prefix="triton-fp4-poc-"))

import torch
import triton
import triton.language as tl
from triton.tools.mxfp import MXFP4Tensor, MXScaleTensor


@triton.jit
def fp4_dot_scaled_once(
    a_ptr,
    b_ptr,
    c_ptr,
    a_scale_ptr,
    b_scale_ptr,
    stride_am,
    stride_ak,
    stride_bk,
    stride_bn,
    stride_cm,
    stride_cn,
    stride_asm,
    stride_ask,
    stride_bsm,
    stride_bsk,
    BLOCK_M: tl.constexpr,
    BLOCK_N: tl.constexpr,
    BLOCK_K: tl.constexpr,
    VEC_SIZE: tl.constexpr,
):
    # Exactly one output tile and one K tile: no program IDs, loop, or masks.
    m = tl.arange(0, BLOCK_M)
    n = tl.arange(0, BLOCK_N)
    k_packed = tl.arange(0, BLOCK_K // 2)
    k_scale = tl.arange(0, BLOCK_K // VEC_SIZE)

    a = tl.load(a_ptr + m[:, None] * stride_am + k_packed[None, :] * stride_ak)
    b = tl.load(b_ptr + k_packed[:, None] * stride_bk + n[None, :] * stride_bn)
    scale_a = tl.load(
        a_scale_ptr + m[:, None] * stride_asm + k_scale[None, :] * stride_ask
    )
    scale_b = tl.load(
        b_scale_ptr + n[:, None] * stride_bsm + k_scale[None, :] * stride_bsk
    )

    acc = tl.zeros((BLOCK_M, BLOCK_N), tl.float32)
    acc = tl.dot_scaled(
        a,
        scale_a,
        "e2m1",
        b,
        scale_b,
        "e2m1",
        acc,
        lhs_k_pack=True,
        rhs_k_pack=True,
    )
    tl.store(c_ptr + m[:, None] * stride_cm + n[None, :] * stride_cn, acc)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--block-m", type=int, default=128)
    p.add_argument("--block-n", type=int, default=128)
    p.add_argument("--block-k", type=int, default=128)
    p.add_argument("--vec-size", type=int, default=32)
    p.add_argument("--save-asm", type=Path)
    return p.parse_args()


def check_args(args: argparse.Namespace) -> None:
    for name in ("block_m", "block_n", "block_k"):
        value = getattr(args, name)
        if value <= 0 or value & (value - 1):
            raise ValueError(f"--{name.replace('_', '-')} must be a power of two")
    if args.block_k % 2 or args.block_k % args.vec_size:
        raise ValueError("BLOCK_K must be divisible by both 2 and VEC_SIZE")


def text_stats(text: str) -> str:
    digest = hashlib.sha256(text.encode()).hexdigest()[:12]
    return (
        f"{len(text.encode()):,} bytes, "
        f"{text.count(chr(10)):,} lines, sha256={digest}"
    )


def report_asm(compiled, save_dir: Path | None) -> None:
    asm = compiled.asm
    print("\nGenerated code:")
    for stage in ("ttir", "ttgir", "llir", "ptx"):
        text = asm.get(stage)
        if isinstance(text, str):
            print(f"  {stage:5s}: {text_stats(text)}")

    ptx = asm.get("ptx", "")
    if ptx:
        lines = [line.strip() for line in ptx.splitlines()]
        instructions = sum(
            line.endswith(";")
            and not line.startswith((".", "//"))
            for line in lines
        )
        print(
            "  PTX contents: "
            f"{instructions:,} instruction lines, "
            f"{sum(x.startswith('.loc') for x in lines):,} .loc directives, "
            f"{sum(x.startswith('.reg') for x in lines):,} .reg declarations"
        )

    metadata = getattr(compiled, "metadata", None)
    print(
        "  Resources: "
        f"registers={getattr(compiled, 'n_regs', 'unknown')}, "
        f"spills={getattr(compiled, 'n_spills', 'unknown')}, "
        f"shared={getattr(metadata, 'shared', 'unknown')} bytes"
    )

    if save_dir:
        save_dir.mkdir(parents=True, exist_ok=True)
        for stage, text in asm.items():
            if isinstance(text, str):
                (save_dir / f"kernel.{stage}").write_text(text)
        print(f"  Saved assembly to {save_dir.resolve()}")


def main() -> None:
    args = parse_args()
    check_args(args)

    if not torch.cuda.is_available():
        raise RuntimeError("CUDA is unavailable")

    torch.manual_seed(0)
    m, n, k, vec = args.block_m, args.block_n, args.block_k, args.vec_size
    props = torch.cuda.get_device_properties(torch.cuda.current_device())
    cc = torch.cuda.get_device_capability()

    print("Environment:")
    print(f"  Python {sys.version.split()[0]}, Triton {triton.__version__}, PyTorch {torch.__version__}")
    print(f"  OS: {platform.platform()}")
    print(f"  CUDA used by PyTorch: {torch.version.cuda}")
    print(f"  GPU: {props.name}, capability {cc[0]}.{cc[1]}, {props.total_memory / 2**30:.1f} GiB")
    print(f"  Triton cache: {os.environ['TRITON_CACHE_DIR']}")
    print(f"  Tile: M={m}, N={n}, K={k}, VEC_SIZE={vec}, grid=(1,)")

    # Exact tile sizes avoid boundary handling and multiple program instances.
    a = MXFP4Tensor(size=(m, k), device="cuda").random().to_packed_tensor(dim=1)
    b = MXFP4Tensor(size=(n, k), device="cuda").random().to_packed_tensor(dim=1).T
    scale_a = MXScaleTensor(torch.rand((m, k // vec), device="cuda")).data
    scale_b = MXScaleTensor(torch.rand((n, k // vec), device="cuda")).data
    c = torch.empty((m, n), device="cuda", dtype=torch.float32)

    print("Compiling and launching...", flush=True)
    start = time.perf_counter()
    compiled = fp4_dot_scaled_once[(1,)](
        a,
        b,
        c,
        scale_a,
        scale_b,
        *a.stride(),
        *b.stride(),
        *c.stride(),
        *scale_a.stride(),
        *scale_b.stride(),
        BLOCK_M=m,
        BLOCK_N=n,
        BLOCK_K=k,
        VEC_SIZE=vec,
    )
    launch_time = time.perf_counter() - start

    torch.cuda.synchronize()
    total_time = time.perf_counter() - start

    print(f"Launch returned in {launch_time:.3f}s; synchronized in {total_time:.3f}s")
    print(
        f"Output: finite={bool(torch.isfinite(c).all())}, "
        f"mean={c.mean().item():.6g}, max_abs={c.abs().max().item():.6g}"
    )
    report_asm(compiled, args.save_asm)


if __name__ == "__main__":
    main()
