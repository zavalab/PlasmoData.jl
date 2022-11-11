using Revise
using DataGraphs, Graphs
using JLD, LinearAlgebra
using Plots, Statistics
using DataGraphPlots

# Data for this example comes from Alex Smith's paper on the Euler Characteristic:
# https://doi.org/10.1016/j.compchemeng.2021.107463

# Load in data; data contains 30 examples with the first 6 being developed brains and the last 24 being underdeveloped
data = JLD.load((@__DIR__)*"/brain.jld")["data"]
thresh = 0:.0002:.2

# Define array to contain the EC for each data example
ECs = Array{Any,2}(undef, length(thresh), 30)

# Get the Euler characteristic by building the graph from a symmetric matrix
for i in 1:30
    mat = abs.(data[i,:,:]) - I
    h = symmetric_matrix_to_graph(mat[:,:])
    println("built graph")
    EC_vals = run_EC_on_edges(h, thresh, scale = true)
    println("Running EC")
    ECs[:,i] .= EC_vals
    println(i)
end

# Get the Euler characteristic by building the graph manually
for i in 1:30
    dg = DataGraph()
    datai = (abs.(data[i,:,:]) - I)

    for j in 1:39
        for k in 1:39
            DataGraphs.add_edge!(dg, k, j)
            add_edge_data!(dg, k, j, datai[k,j], "weight")
        end
    end

    println("built graph")
    EC_vals = run_EC_on_edges(dg, thresh)
    ECs[:,i] .= EC_vals
end

adult = mean(ECs[:,1:6], dims=2)
child = mean(ECs[:,7:30], dims=2)

# Plot the resulting data
plt = plot(thresh, adult, label="Developed")
plot!(thresh, child, label="Underdeveloped")

plt = plot(thresh, ECs[:, 1], label = "Class 1", color = :blue, linewidth = 1, linestyle = :dash)
plot!(thresh, ECs[:, 7], label = "Class 2", color =:red, linewidth = 1)
for i in 2:6
    plot!(thresh, ECs[:, i], label = :none, color = :blue, linewidth = 1, linestyle = :dash)
end
for i in 8:30
    plot!(thresh, ECs[:, i], label = :none, color = :red, linewidth = 1)
end
xlabel!("Filtration Threshold")
ylabel!("Scaled Euler Characteristic")
display(plt)
