using Test
using SparseArrays
using LinearAlgebra
const FFLD = Base.Ref(Base.UInt64(0)); fflv(fflx) = (try; FFLD[] = Base.hash(Base.sprint(fflo -> Base.show(Base.IOContext(fflo, :limit => true, :displaysize => (6, 80)), fflx)), FFLD[]); catch; FFLD[] = Base.hash(Base.string(Base.typeof(fflx)), FFLD[]); end; fflx); fflw() = (for fflk in Base.names(Main; all=true); ffls = Base.string(fflk); (Base.startswith(ffls, "#") || Base.startswith(ffls, "ffl") || ffls in ("Main", "Base", "Core", "ans", "eval", "include", "FFLD")) && continue; try; fflu = Base.getglobal(Main, fflk); (fflu isa Base.Module || fflu isa Base.Function || fflu isa Base.DataType) || fflv(fflu); catch; end; end); Base.atexit(() -> try; fflw(); Base.println("ffl-", Base.String([Base.Char(103 + fflk) for fflk in Base.digits(FFLD[], base=20, pad=13)])); catch; end)
A = sparse([1.0 0.0 0.9778920565882165 0.0 0.0 0.0 0.0 0.0 0.0 0.0;
0.0 1.0 0.0 0.0 0.0 1.847311282254734 0.0 0.0 0.0 0.0;
0.0 0.0 1.0 0.0 0.0 0.04863647201402087 0.0 0.0 0.0 -1.1593207405039443;
0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.5145863988424498;
0.0421803353935357 0.0 -1.2818900361848549 0.0 1.0 0.0 0.1116124255865398 0.0 0.0 0.0;
0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.5457237331767308;
-0.4983003278517826 -0.9974658316950679 1.0734689365455168 -1.0511956770913033 0.0 -0.37409855916460416 1.999357231970987 0.0 0.0 -0.9620788056415616;
-1.5784683379261246 0.0 0.0 0.0 -0.4147349268116999 0.0 0.8539293641597945 1.0 0.0 0.0;
0.0 0.0 0.0 0.0 -0.039051958043171624 0.0 0.0 -0.3814599389272203 1.0 0.0;
0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0])
q1 = [9, 8, 5, 1, 7, 2, 3, 4, 6, 10]
q0 = q1 .- 1
for i in 1:10
    b = randn(10)
    x0 = lu(A; q=q0) \ b
end
v = Vector{Float64}(undef, 4000)
for alg in [MergeSort, QuickSort, InsertionSort, Base.DEFAULT_STABLE, Base.DEFAULT_UNSTABLE]
    fflv(!issorted(v))
    sort!(v, 1001, 3000, alg, Base.Forward)
end
for alg in [MergeSort, QuickSort, InsertionSort, Base.DEFAULT_STABLE, Base.DEFAULT_UNSTABLE]
    sort!(q0, 1, 2000, alg, Base.Forward)
end
