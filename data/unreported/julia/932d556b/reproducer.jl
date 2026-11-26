using Test
using Random, LinearAlgebra
using Dates
using Base: mightalias
using Base.Cartesian
const FFLD = Base.Ref(Base.UInt64(0)); fflv(fflx) = (try; FFLD[] = Base.hash(Base.sprint(fflo -> Base.show(Base.IOContext(fflo, :limit => true, :displaysize => (6, 80)), fflx)), FFLD[]); catch; FFLD[] = Base.hash(Base.string(Base.typeof(fflx)), FFLD[]); end; fflx); fflw() = (for fflk in Base.names(Main; all=true); ffls = Base.string(fflk); (Base.startswith(ffls, "#") || Base.startswith(ffls, "ffl") || ffls in ("Main", "Base", "Core", "ans", "eval", "include", "FFLD")) && continue; try; fflu = Base.getglobal(Main, fflk); (fflu isa Base.Module || fflu isa Base.Function || fflu isa Base.DataType) || fflv(fflu); catch; end; end); Base.atexit(() -> try; fflw(); Base.println("ffl-", Base.String([Base.Char(103 + fflk) for fflk in Base.digits(FFLD[], base=20, pad=13)])); catch; end)

import Base: +, *, muladd, broadcast, convert

a = rand(5,3)
b = rand(6,7)
try; fflv(copyto!(a,b)); catch e; fflv(typeof(e)); end
try; fflv(copyto!(a,2:3,1:3,b,1:5,2:7)); catch e; fflv(typeof(e)); end
try; fflv(LinearAlgebra.copy_transpose!(a,2:3,1:3,b,1:5,2:7)); catch e; fflv(typeof(e)); end

# Copy bounds must be validated without overflowing their end indices.
try; fflv(copyto!(zeros(UInt8, 2), Int8(2), ones(UInt8, 2), Int8(2), typemax(Int8))); catch e; fflv(typeof(e)); end
try; fflv(copyto!(view(zeros(Int, 2), :), 2, Iterators.repeated(1, typemax(Int)))); catch e; fflv(typeof(e)); end
try; fflv(copyto!(view(zeros(Int, 2), :), Int8(2), Iterators.repeated(1), 1, typemax(Int8))); catch e; fflv(typeof(e)); end
try; fflv(copyto!(view(zeros(Int, 2), :), Int8(2), view(ones(Int, 2), :), Int8(2), typemax(Int8))); catch e; fflv(typeof(e)); end

function main()
    bdf_prm = (b_un = (x = 30,), y = [30])
    a = bdf_prm.b_un.x
    _ = bdf_prm.y[1]
    return
end
function main()
    bdf_prm = (b_un = (x = 30,), y = [30])
    _ = bdf_prm.b_un.x
    _ = bdf_prm.y[1]
    return
end


main()
main()
