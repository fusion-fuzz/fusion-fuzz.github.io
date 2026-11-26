using Test
using Base.Threads
import Base: copy
const FFLD = Base.Ref(Base.UInt64(0)); fflv(fflx) = (try; FFLD[] = Base.hash(Base.sprint(fflo -> Base.show(Base.IOContext(fflo, :limit => true, :displaysize => (6, 80)), fflx)), FFLD[]); catch; FFLD[] = Base.hash(Base.string(Base.typeof(fflx)), FFLD[]); end; fflx); fflw() = (for fflk in Base.names(Main; all=true); ffls = Base.string(fflk); (Base.startswith(ffls, "#") || Base.startswith(ffls, "ffl") || ffls in ("Main", "Base", "Core", "ans", "eval", "include", "FFLD")) && continue; try; fflu = Base.getglobal(Main, fflk); (fflu isa Base.Module || fflu isa Base.Function || fflu isa Base.DataType) || fflv(fflu); catch; end; end); Base.atexit(() -> try; fflw(); Base.println("ffl-", Base.String([Base.Char(103 + fflk) for fflk in Base.digits(FFLD[], base=20, pad=13)])); catch; end)
function main()
    foo = 1.4
    for _ in 1:3
        g = 0.1
        if g != nothing
        end
    end
end

for (T, value) in Any[(Any, "value"), (Float32, 1.0f0)]
    mem = AtomicMemory{T}(undef, 3)
    ref = memoryref(mem, 2)
    for order in [:unordered, :monotonic, :release, :sequentially_consistent]
        # Unset the ref
        @atomic :monotonic mem[2] = value
        fflv(isassigned(ref) == isassigned(mem, 2) == true)
        fflv(Base.unsetindex_atomic!(ref, order) === ref)
        if T === Any
            fflv(isassigned(ref) == isassigned(mem, 2) == false)
            try; fflv(ref[]); catch e; fflv(typeof(e)); end
            try; fflv(@atomic :monotonic mem[2]); catch e; fflv(typeof(e)); end
        else
            fflv(isassigned(ref) == isassigned(mem, 2) == true)
            fflv(ref[] isa T)
            fflv(((@atomic :monotonic mem[2]) isa T))
        end

        # Unset the mem
        @atomic :monotonic mem[2] = value
        fflv(isassigned(ref) == isassigned(mem, 2) == true)
        fflv(Base.unsetindex_atomic!(mem, order, 2) === mem)
        if T === Any
            fflv(isassigned(ref) == isassigned(mem, 2) == false)
            try; fflv(ref[]); catch e; fflv(typeof(e)); end
            try; fflv(@atomic :monotonic mem[2]); catch e; fflv(typeof(e)); end
        else
            fflv(isassigned(ref) == isassigned(mem, 2) == true)
            fflv(ref[] isa T)
            fflv(((@atomic :monotonic mem[2]) isa T))
        end
    end
end

mem = AtomicMemory{Any}(undef, 1)
@atomic :monotonic mem[1] = "value"
ref = memoryref(mem, 1)
try; fflv(Base.unsetindex_atomic!(ref, :acquire)); catch e; fflv(typeof(e)); end
try; fflv(Base.unsetindex_atomic!(ref, :acquire_release)); catch e; fflv(typeof(e)); end
try; fflv(Base.unsetindex_atomic!(ref, :not_atomic)); catch e; fflv(typeof(e)); end
try; fflv(Base.unsetindex_atomic!(mem, :acquire, 1)); catch e; fflv(typeof(e)); end
try; fflv(Base.unsetindex_atomic!(mem, :acquire_release, 1)); catch e; fflv(typeof(e)); end
try; fflv(Base.unsetindex_atomic!(mem, :not_atomic, 1)); catch e; fflv(typeof(e)); end
try; fflv(Base.unsetindex_atomic!(mem, :release, 0)); catch e; fflv(typeof(e)); end

main()
