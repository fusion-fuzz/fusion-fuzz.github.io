function main()
    data = Any[]
    io = IOBuffer()
    serialize(io, data)
    serialized = take!(io)
    try
        GC.gc()
        deserialized = deserialize(IOBuffer(serialized))
        if deserialized isa Vector
            println("Deserialized and executed successfully.")
        end
    catch
    end
end
function main()
    length = 10000
    array = Any[]
    for i in length:-1:-100000
        if i > length
            resize!(array, i)
        end
        array[i] = Dict{Any,Any}()
    end
end

main()

main()

function main()
    length = 10000
    array = Any[]
    for i in length:-1:-100000
        if i > length
            main(array, i)
        end
        array[i] = Dict{Any,Any}()
    end
end

main()
