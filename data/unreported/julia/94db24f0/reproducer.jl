const FFLD = Base.Ref(Base.UInt64(0)); fflv(fflx) = (try; FFLD[] = Base.hash(Base.sprint(fflo -> Base.show(Base.IOContext(fflo, :limit => true, :displaysize => (6, 80)), fflx)), FFLD[]); catch; FFLD[] = Base.hash(Base.string(Base.typeof(fflx)), FFLD[]); end; fflx); fflw() = (for fflk in Base.names(Main; all=true); ffls = Base.string(fflk); (Base.startswith(ffls, "#") || Base.startswith(ffls, "ffl") || ffls in ("Main", "Base", "Core", "ans", "eval", "include", "FFLD")) && continue; try; fflu = Base.getglobal(Main, fflk); (fflu isa Base.Module || fflu isa Base.Function || fflu isa Base.DataType) || fflv(fflu); catch; end; end); Base.atexit(() -> try; fflw(); Base.println("ffl-", Base.String([Base.Char(103 + fflk) for fflk in Base.digits(FFLD[], base=20, pad=13)])); catch; end)

function main()
    r = Vector{UInt64}(undef, 8)
    d = UInt32(0x80000000)
    n = Int(d ÷ 32)
    for i in 1:n
        r[i] = 0
    end
    println(n)
end

main()


main([])
isempty([1 2 3])
