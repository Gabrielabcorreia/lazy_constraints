using JuMP
using MathOptInterface
import GLPK
import Plots

function subtour(edges::Vector{Tuple{Int, Int}}, n)
    shortest_subtour, unvisited = collect(1:n), Set(collect(1:n))
    while !isempty(unvisited)
        this_cycle, neighbors = Int[], unvisited
        while !isempty(neighbors)
            current = pop!(neighbors)
            push!(this_cycle, current)
            if length(this_cycle) > 1
                pop!(unvisited, current)
            end
            neighbors = 
                [j for (i, j) in edges if i == current && j in unvisited]
        end
        if length(this_cycle) < length(shortest_subtour)
            shortest_subtour = this_cycle
        end
    end
    return shortest_subtour
end

function selected_edges(x::Matrix{Float64}, n)
    return Tuple{Int, Int}[(i, j) for i in 1:n, j in 1:n if x[i, j] > 0.5]
end

function plot_tour(X, Y, x)
    plot = Plots.plot()
    for (i, j) in selected_edges(x, size(x, 1))
        Plots.plot!([X[i], X[j]], [Y[i], Y[j]]; legend = false)
    end
    display(plot)
    return plot
end

subtour(x::AbstractMatrix{VariableRef}) = subtour(value.(x))
subtour(x::Matrix{Float64}) = subtour(selected_edges(x, size(x, 1)), size(x, 1))

function find_first(tuples::Vector{Tuple{Int, Int}})        # function that finds the first tuple that contains the number "1" in the first element
    for i in 1:length(tuples)
        if tuples[i][1] == 1
            return i
        end
    end
end

function reorganize(tour_edges::Vector{Tuple{Int, Int}})
    
    first_index = find_first(tour_edges)

    tour_edges_re = [tour_edges[first_index]]       # Put the first element on the new tour_edges
    deleteat!(tour_edges, first_index)          # Delete the element of the old tour 

    while !isempty(tour_edges)          
        last = tour_edges_re[end]
        found = false

        for i in eachindex(tour_edges)
            if last[2] == tour_edges[i][1]          # Checks if the second value of the tuple is equal to the first of the other
                push!(tour_edges_re, tour_edges[i])
                deleteat!(tour_edges, i)
                found = true
                break
            end
        end

        if !found
            for i in eachindex(tour_edges)          
                if last[2] == tour_edges[i][2]      # Checks if the second value of the tuple is equal to the second of the other
                    push!(tour_edges_re, reverse(tour_edges[i]))       # Reverse the order
                    deleteat!(tour_edges, i)
                    break
                end
            end
        end
    end
    return tour_edges_re
end

function build_tsp_model(instance)
    
    n = instance.n
    model = Model(GLPK.Optimizer)

    @variable(model, x[1:instance.n, 1:instance.n], Bin, Symmetric)
    @objective(model, Min, sum(instance.d * x) / 2)
    @constraint(model, [i in 1:instance.n], sum(x[i, :]) == 2)
    @constraint(model, [i in 1:instance.n], x[i, i] == 0)

    lazy_model = model
    function subtour_elimination_callback(cb_data)
        status = callback_node_status(cb_data, lazy_model)
        if status != MOI.CALLBACK_NODE_STATUS_INTEGER
            return  # Only run at integer solutions
        end
        cycle = subtour(callback_value.(cb_data, lazy_model[:x]))
        if !(1 < length(cycle) < n)
            return  # Only add a constraint if there is a cycle
        end
        println("Found cycle of length $(length(cycle))")
        S = [(i, j) for (i, j) in Iterators.product(cycle, cycle) if i < j]
        con = @constraint(
            lazy_model, sum(lazy_model[:x][i, j] for (i, j) in S) <= length(cycle) - 1
        )
        MOI.submit(lazy_model, MOI.LazyConstraint(cb_data), con)
        return
    end

    set_attribute(
        lazy_model,
        MOI.LazyConstraintCallback(),
        subtour_elimination_callback
    )

    optimize!(lazy_model)
    
    @assert JuMP.termination_status(lazy_model) == MOI.OPTIMAL "Erro: cannot find the optimal solution"

    tour_edges = selected_edges(value.(lazy_model[:x]), instance.n)  # Vector that stores the solution paths
    visited = []    

    for (i, j) in tour_edges    # Only stores different visited nodes
        if !(i in visited)
            push!(visited, i)
        end

        if !(j in visited)
            push!(visited, j)
        end
    end

    @assert length(visited) == instance.n "Erro: Não passou por todos os pontos."

    tour_edges_sym = Set{Tuple{Int, Int}}()

    for (i, j) in tour_edges
        if i < j
            push!(tour_edges_sym, (i, j))
        elseif j < i
            push!(tour_edges_sym, (j, i))
        end
    end

    plot_tour(instance.X, instance.Y, value.(lazy_model[:x]))

    results = reorganize(collect(tour_edges_sym))       # Turns it into a vector and puts it in the function

    return results, objective_value(lazy_model)
end
