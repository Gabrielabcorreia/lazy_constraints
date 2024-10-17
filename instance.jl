module Tsp_model

using Random

struct distance_matrix 
    X::Vector{Float64}
    Y::Vector{Float64}
    d::Matrix{Float64}
    n::Int64
end

function verify_instance(instance, name)
    open(name, "r") do file 
        n2 = parse(Int, readline(file))

        X2 = [parse(Float64, readline(file)) for i in 1:n2]
        Y2 = [parse(Float64, readline(file)) for i in 1:n2]

        d2 = [parse(Float64, readline(file)) for i in 1:(n2 * n2)]
        d2 = reshape(d2, n2, n2)

        if (instance.X != X2) || (instance.Y != Y2) || (instance.d != d2)
            return false
        else
            return true
        end
    end
end

function create_instance(name)
    
    n1 = 5
    rng = Random.MersenneTwister(3)
    X1 = 5 * rand(rng, n1)
    Y1 = 5 * rand(rng, n1)
    d1 = [sqrt((X1[i] - X1[j])^2 + (Y1[i] - Y1[j])^2) for i in 1:n1, j in 1:n1]
    instance = distance_matrix(X1, Y1, d1, n1)

    open(name, "w") do io
        println(io, n1)
        for i in X1
            println(io, i)
        end
        for j in Y1
            println(io, j)
        end

        for i in 1:n1
            for j in 1:n1
                println(io, d1[i, j])
            end
        end
    end

    #   Verification from file
    @assert verify_instance(instance, name) == true "Erro: was not stored correctly"
end

function load_instance(name)
    open(name, "r") do file 
        n1 = parse(Int, readline(file))

        X1 = [parse(Float64, readline(file)) for i in 1:n1]
        Y1 = [parse(Float64, readline(file)) for i in 1:n1]

        d1 = [parse(Float64, readline(file)) for i in 1:(n1 * n1)]
        d1 = reshape(d1, n1, n1)

        return distance_matrix(X1, Y1, d1, n1)
    end
end
function generate_distance()
    
    n1 = 5
    rng = Random.MersenneTwister(1)
    X1 = 20 * rand(rng, n1)
    Y1 = 20 * rand(rng, n1)
    d1 = [sqrt((X1[i] - X1[j])^2 + (Y1[i] - Y1[j])^2) for i in 1:n1, j in 1:n1]

    return distance_matrix(X1, Y1, d1, n1)
end

end
