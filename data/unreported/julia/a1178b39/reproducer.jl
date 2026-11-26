a = Ref{Int}(0)
b = Vector{Float32}(undef, 16)
c = Vector{Float32}(undef, 16)
e = Vector{UInt8}(undef, 1)

while a[] != 0
    a[] += 1
    if e[1] != 0
        c[1] = b[1]
        c[2] = b[2]
        c[3] = b[3]
        c[4] = b[4]
    end
end

function main()
    A = reshape(Float16.(1:1024), 32, 32)
    B = similar(A)
    @inbounds for j in 1:32, i in 1:32
        B[i, j] = A[i, j]
    end
    C = Matrix{Float16}(undef, 32, 32)
    @inbounds for j in 1:32, i in 1:32
        e[i, j] = B[i, j]
    end
    s = zero(Float16)
    @inbounds for j in 1:32, i in 1:32
        s += e[i, j]
    end
    s
end

main()

a = Ref{Int}(0)
b = Vector{Float32}(undef, 16)
c = Vector{Float32}(undef, 16)
e = Vector{UInt8}(undef, 1)

while a[] != 0
    a[] += 1
    if e[1] != 0
        c[1] = b[1]
        c[2] = b[2]
        c[3] = b[3]
        c[4] = b[4]
    end
end
try; GC.gc(false); GC.safepoint(); typeof(c); Base.summarysize(c); GC.gc(true); catch; end
