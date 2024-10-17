include("model.jl")
include("instance.jl")

println("What you want to do (1 - Open archive) (2 - Make a random) (3 - Create a random archive) ?: ")     # The third is just for practice
assistant = parse(Int, readline())

if assistant == 1
    println("Put the name of the archive(put '.txt'): ")
    name = readline()

    insta = Tsp_model.load_instance(name)
    tour_edges, cost = build_tsp_model(insta)

elseif assistant == 2

    insta = Tsp_model.generate_distance()
    tour_edges, cost = build_tsp_model(insta)

elseif assistant == 3

    println("Put the name of the archive(put '.txt'): ")
    name = readline()

    Tsp_model.create_instance(name)
    insta = Tsp_model.load_instance(name)
    tour_edges, cost = build_tsp_model(insta)

else
    println("Please enter a valid option")
end


open("tsp_solution.txt", "w") do io
    write(io, "Edges traveled:\n")
    for (i, j) in tour_edges
        write(io, "($i, $j)\n")
    end
    write(io, "\nDistance: $cost\n")
end
