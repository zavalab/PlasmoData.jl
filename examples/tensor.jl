using Revise
using DataGraphs, Graphs
using Statistics, DelimitedFiles

abc = rand(10, 5, 4)

tensor_graph = tensor_to_graph(abc)

tensor_graph.edges

include("plots.jl")

plot_graph(tensor_graph)

xyz = rand(128, 48, 48)

tensor_graph1 = tensor_to_graph(abc)
@time tensor_graph1 = tensor_to_graph(abc)

LC_path = (@__DIR__)*"/3D_LC_data.csv"
initial_data_3D = readdlm(LC_path, ',')

data_3d = Array{Float64, 4}(undef, (120, 48, 48, 3))

for i in 1:120
    for j in 1:3
        data_3d[i, :, :, j] = initial_data_3D[(1 + (i - 1) * (48 * 3) + (j - 1) * 48):((i - 1) * (48 * 3) + j * 48), :]
    end
end

data_3d_avg = mean(data_3d, dims=4)[:, :, :, 1]

tensor_graph = tensor_to_graph(data_3d_avg)

thresh =0:.002:.7

ECs = run_EC_on_nodes(tensor_graph, thresh)
@time ECs = run_EC_on_nodes(tensor_graph, thresh)

using Plots; plot(thresh, ECs)
