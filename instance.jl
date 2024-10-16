module Tsp_model

using Random

struct distance_matrix 
    X::Vector{Float64}
    Y::Vector{Float64}
    d::Matrix{Float64}
    n::Int64
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
