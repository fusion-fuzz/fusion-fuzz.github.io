function foo(index, do_throw)
    arr = Any[1.5, nothing]
    undef = arr[index]
    try
        if do_throw
            throw("lol")
        end
        undef = 42
        if false
            throw("lol")
        end
    catch
        return undef
    end
end

function main()
    foo(1, false)
    foo(1, true)
    foo(1, true)
end

main()

function main()
    x = foo(0, 33)
    s = 0
    @inbounds for i in 1:33
        s += x[i]
    end
    nothing
end

main()

try; deepcopy(foo); code_typed(identity, (typeof(foo),); optimize=true); catch; end
