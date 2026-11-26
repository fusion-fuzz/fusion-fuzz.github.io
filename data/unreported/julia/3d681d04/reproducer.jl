using Test
using LinearAlgebra, Random
using LinearAlgebra: BlasFloat, BlasComplex
const FFLD = Base.Ref(Base.UInt64(0)); fflv(fflx) = (try; FFLD[] = Base.hash(Base.sprint(fflo -> Base.show(Base.IOContext(fflo, :limit => true, :displaysize => (6, 80)), fflx)), FFLD[]); catch; FFLD[] = Base.hash(Base.string(Base.typeof(fflx)), FFLD[]); end; fflx); fflw() = (for fflk in Base.names(Main; all=true); ffls = Base.string(fflk); (Base.startswith(ffls, "#") || Base.startswith(ffls, "ffl") || ffls in ("Main", "Base", "Core", "ans", "eval", "include", "FFLD")) && continue; try; fflu = Base.getglobal(Main, fflk); (fflu isa Base.Module || fflu isa Base.Function || fflu isa Base.DataType) || fflv(fflu); catch; end; end); Base.atexit(() -> try; fflw(); Base.println("ffl-", Base.String([Base.Char(103 + fflk) for fflk in Base.digits(FFLD[], base=20, pad=13)])); catch; end)
using Random, LinearAlgebra
using Base: typed_hvncat

A = rand(3,3)
for trans in (identity, adjoint, transpose)
    fflv(ldiv!(trans(I(3)), A) == A)
    fflv(rdiv!(A, trans(I(3))) == A)
end


a = [1:6;]
fflv(a === keepat!(a, 1:5))
fflv(a == 1:5)
fflv(keepat!(a, [2, 4]) == [2, 4])
fflv(isempty(keepat!(a, [])))

a = [1:6;]
try; fflv(keepat!(a, 1:10)); catch e; fflv(typeof(e)); end  # make sure this is not a no-op
try; fflv(keepat!(a, 2:10)); catch e; fflv(typeof(e)); end
try; fflv(keepat!(a, [2, 4, 3])); catch e; fflv(typeof(e)); end

b = BitVector([1, 1, 1, 0, 0])
fflv(b === keepat!(b, 1:5))
fflv(b == [1, 1, 1, 0, 0])
fflv(keepat!(b, 2:4) == [1, 1, 0])
try; fflv(keepat!(a, -1:10)); catch e; fflv(typeof(e)); end
try; fflv(keepat!(a, [2, 1])); catch e; fflv(typeof(e)); end
fflv(isempty(keepat!(a, [])))


A = rand(3,3)
for trans in (identity, adjoint, transpose)
    fflv(ldiv!(trans(I(3)), a) == A)
    fflv(rdiv!(A, trans(I(3))) == A)
end

try; GC.gc(false); GC.safepoint(); catch; end
