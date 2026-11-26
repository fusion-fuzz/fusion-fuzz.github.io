depth = 0

function f3(x)
    global depth
    args = Any[x]
    args[1001] = 123
    depth += 1
    if depth > 2200
        return
    end
    let args = args
        f4() = (args[1] += 1; f3(0.5))
        f4()
    end
end
struct Foo{A}
    inner::A
end

f3(0.5)

function main()
    x = Foo{Float32}(1.5f0)
    y = Foo{Int}(1)
    z = Foo{String}("a")
    return nothing
end

main()
