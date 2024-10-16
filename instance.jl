module Tsp_model

using Random

struct distance_matrix 
    X::Vector{Float64}
    Y::Vector{Float64}
    d::Matrix{Float64}
    n::Int64
end

function create_instance(name)
    
    n1 = 5
    rng = Random.MersenneTwister(1)
    X1 = 5 * rand(rng, n1)
    Y1 = 5 * rand(rng, n1)
    d1 = [sqrt((X1[i] - X1[j])^2 + (Y1[i] - Y1[j])^2) for i in 1:n1, j in 1:n1]

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
