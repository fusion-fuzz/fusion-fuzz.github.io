using Test
using Serialization
import Base.MPFR
import Base.MPFR: clear_flags, had_underflow, had_overflow, had_divbyzero, had_nan, had_inexact_exception, had_range_exception
const FFLD = Base.Ref(Base.UInt64(0)); fflv(fflx) = (try; FFLD[] = Base.hash(Base.sprint(fflo -> Base.show(Base.IOContext(fflo, :limit => true, :displaysize => (6, 80)), fflx)), FFLD[]); catch; FFLD[] = Base.hash(Base.string(Base.typeof(fflx)), FFLD[]); end; fflx); fflw() = (for fflk in Base.names(Main; all=true); ffls = Base.string(fflk); (Base.startswith(ffls, "#") || Base.startswith(ffls, "ffl") || ffls in ("Main", "Base", "Core", "ans", "eval", "include", "FFLD")) && continue; try; fflu = Base.getglobal(Main, fflk); (fflu isa Base.Module || fflu isa Base.Function || fflu isa Base.DataType) || fflv(fflu); catch; end; end); Base.atexit(() -> try; fflw(); Base.println("ffl-", Base.String([Base.Char(103 + fflk) for fflk in Base.digits(FFLD[], base=20, pad=13)])); catch; end)
using SparseArrays
using SparseArrays: nonzeroinds, getcolptr
using LinearAlgebra
using Random


fflv(convert(BigFloat, 1//2) == parse(BigFloat,"0.5"))
fflv(typeof(convert(BigFloat, 1//2)) == BigFloat)
fflv(convert(BigFloat, 0.5) == parse(BigFloat,"0.5"))
fflv(typeof(convert(BigFloat, 0.5)) == BigFloat)
fflv(convert(BigFloat, 40) == parse(BigFloat,"40"))
fflv(typeof(convert(BigFloat, 40)) == BigFloat)
fflv(convert(BigFloat, Float32(0.5)) == parse(BigFloat,"0.5"))
fflv(typeof(convert(BigFloat, Float32(0.5))) == BigFloat)
fflv(convert(BigFloat, parse(BigInt,"9223372036854775808")) == parse(BigFloat,"9223372036854775808"))
fflv(typeof(convert(BigFloat, parse(BigInt,"9223372036854775808"))) == BigFloat)
fflv(convert(AbstractFloat, parse(BigInt,"9223372036854775808")) == parse(BigFloat,"9223372036854775808"))
fflv(typeof(convert(AbstractFloat, parse(BigInt,"9223372036854775808"))) == BigFloat)

fflv(signbit(BigFloat(NaN)) == 0)

A = SparseVector(2, [1,2], Union{Int, Missing}[1, missing])
for fun in (+, -, *, min, max)
    if fun in (+, -)
        fflv(collect(skipmissing(Array(fun(A, A)))) == collect(skipmissing(Array(fun(Array(A), Array(A))))))
    end
    fflv(collect(skipmissing(Array(map(fun, A, A)))) == collect(skipmissing(map(fun, Array(A), Array(A)))))
    fflv(collect(skipmissing(Array(broadcast(fun, A, A)))) == collect(skipmissing(broadcast(fun, Array(A), Array(A)))))
end
b = convert(SparseVector{Union{Float64, Missing}}, sprandn(Float64, 10, 0.2)); b[rand(1:10, 3)] .= missing
C = convert(SparseVector{Union{Float64, Missing}}, sprandn(Float64, 10, 0.9)); C[rand(1:10, 3)] .= missing
CA = Array(C)
D = convert(SparseVector{Union{Float64, Missing}}, spzeros(Float64, 10)); D[rand(1:10, 3)] .= missing
E = convert(SparseVector{Union{Float64, Missing}}, spzeros(Float64, 10))
for B in (b, C, D, E), fun in (+, -, *, min, max)
    BA = Array(B)
    # reverse order for opposite nonzeroinds-structure
    if fun in (+, -)
        fflv(collect(skipmissing(Array(fun(B, C)))) == collect(skipmissing(Array(fun(BA, CA)))))
        fflv(collect(skipmissing(Array(fun(C, B)))) == collect(skipmissing(Array(fun(CA, BA)))))
    end
    fflv(collect(skipmissing(Array(map(fun, B, C)))) == collect(skipmissing(map(fun, BA, CA))))
    fflv(collect(skipmissing(Array(map(fun, C, B)))) == collect(skipmissing(map(fun, CA, BA))))
    fflv(collect(skipmissing(Array(broadcast(fun, B, C)))) == collect(skipmissing(broadcast(fun, BA, CA))))
    fflv(collect(skipmissing(Array(broadcast(fun, C, B)))) == collect(skipmissing(broadcast(fun, CA, BA))))
end
fflv(signbit(BigFloat(-NaN)) == 1)


A = SparseVector(2, [1,2], Union{Int, Missing}[1, missing])
for fun in (+, -, *, min, max)
    if fun in (+, -)
        fflv(collect(skipmissing(Array(fun(A, A)))) == collect(skipmissing(Array(fun(Array(A), Array(A))))))
    end
    fflv(collect(skipmissing(Array(map(fun, A, A)))) == collect(skipmissing(map(fun, Array(A), Array(A)))))
    fflv(collect(skipmissing(Array(broadcast(fun, A, A)))) == collect(skipmissing(broadcast(fun, Array(A), Array(A)))))
end
b = convert(SparseVector{Union{Float64, Missing}}, sprandn(Float64, 10, 0.2)); b[rand(1:10, 3)] .= missing
C = convert(SparseVector{Union{Float64, Missing}}, sprandn(Float64, 10, 0.9)); C[rand(1:10, 3)] .= missing
CA = Array(C)
D = convert(SparseVector{Union{Float64, Missing}}, spzeros(Float64, 10)); D[rand(1:10, 3)] .= missing
E = convert(SparseVector{Union{Float64, Missing}}, spzeros(Float64, 10))
for B in (b, C, D, A), fun in (+, -, *, min, max)
    BA = Array(B)
    # reverse order for opposite nonzeroinds-structure
    if fun in (+, -)
        fflv(collect(skipmissing(Array(fun(B, C)))) == collect(skipmissing(Array(fun(BA, CA)))))
        fflv(collect(skipmissing(Array(fun(C, B)))) == collect(skipmissing(Array(fun(CA, BA)))))
    end
    fflv(collect(skipmissing(Array(map(fun, B, C)))) == collect(skipmissing(map(fun, BA, CA))))
    fflv(collect(skipmissing(Array(map(fun, C, B)))) == collect(skipmissing(map(fun, CA, BA))))
    fflv(collect(skipmissing(Array(broadcast(fun, B, C)))) == collect(skipmissing(broadcast(fun, BA, CA))))
    fflv(collect(skipmissing(Array(broadcast(fun, C, B)))) == collect(skipmissing(broadcast(fun, CA, BA))))
end

try; GC.gc(false); GC.safepoint(); catch; end
