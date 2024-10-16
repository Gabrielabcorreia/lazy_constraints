include("model.jl")
include("instance.jl")

insta = Tsp_model.generate_distance()
tour_edges, cost = build_tsp_model(insta)

open("tsp_solution.txt", "w") do io
    write(io, "Edges traveled:\n")
    for (i, j) in tour_edges
        write(io, "($i, $j)\n")
    end
    write(io, "\nDistance: $cost\n")
end
