using Revise
using PlasmoData, Graphs
using Statistics, DelimitedFiles
using PlasmoDataPlots

abc = rand(10, 4, 5)

tensor_graph = tensor_to_graph(abc)

set_tensor_node_positions!(tensor_graph, abc)
plot_graph(tensor_graph, linecolor=:gray, nodecolor=:deep, node_z = tensor_graph.node_data.data[:, 1], nodestrokewidth= .1, linewidth = .5, nodesize=8, legend=false)

xyz = rand(128, 48, 48)

tensor_graph1 = tensor_to_graph(abc)
@time tensor_graph1 = tensor_to_graph(abc)
