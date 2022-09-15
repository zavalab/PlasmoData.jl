using Revise
using DataGraphs, Graphs
using JLD, LinearAlgebra
using Plots, Statistics

# Data for this example comes from Alex Smith's paper on the Euler Characteristic:
# https://doi.org/10.1016/j.compchemeng.2021.107463

data = JLD.load("examples/brain.jld")["data"]
thresh = 0:.0002:.2

ECs = Array{Any,2}(undef, length(thresh), 30)

for i in 1:30
    mat = abs.(data[i,:,:]) - I
    h = symmetric_matrix_to_graph(mat[:,:])
    println("built graph")
    EC_vals = run_EC_on_edges(h, thresh)
    println("Running EC")
    ECs[:,i] .= EC_vals
    println(i)
end


for i in 1:30
    dg = DataGraph()
    datai = (abs.(data[i,:,:]) - I)

    for j in 1:39
        for k in 1:39
            add_edge!(dg, k, j)
            add_edge_data!(dg, k, j, datai[k,j], "weight")
        end
    end

    println("built graph")
    EC_vals = run_EC_on_edges(dg, thresh)
    ECs[:,i] .= EC_vals
end

adult = mean(ECs[:,1:6], dims=2)
child = mean(ECs[:,7:30], dims=2)

plt = plot(thresh, adult, label="Developed")
plot!(thresh, child, label="Underdeveloped")


# Optional plotting
include("plots.jl")

h = symmetric_matrix_to_graph(data[1,:,:])
x = DataGraph()
x.nodes = h.nodes
plot_graph(x)
h.node_positions = x.node_positions
plot_graph(h; color=:gray, linealpha=.2, xdim = 400, ydim = 400, save_fig=true, fig_name="full_plot.png")
