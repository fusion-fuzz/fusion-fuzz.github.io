mutable struct A
    a
end

function test(a...)
    nothing
end

function main()
    T = fieldtype(A, 1)
    println(T)
    println(typeof((a...)->nothing))
    println(Any)
    println(string(T))
    println(string(typeof((a...)->nothing)))
    println(string(Any))
end
mutable struct A
end

function f0(::A)
    while true
    end
end

function bar(self::A)
    f0(self).f0
end

mutable struct NSSize
    width::Float32
    height::Float32
end

mutable struct AnObject
    size::NSSize
end

function f()
    obj = AnObject(NSSize(0.0f0, 0.0f0))
    (obj.size).width
end

function test3(obj::AnObject)
    obj.size
    (obj.size)
    nothing
end

main()

function main()
    a = A()
    obj = AnObject(NSSize(1.0f0, 2.0f0))
    try
        f()
    catch
    end
    try
        test3(obj)
    catch
    end
    try
        bar(a)
    catch
    end
end

main()
