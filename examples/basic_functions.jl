using Revise
using DataGraphs, Graphs
include("plots.jl")

dg = DataGraph()

add_node!(dg, 1)
add_node!(dg, 2)
add_node!(dg, 3)
add_node!(dg, "node4")
add_node!(dg, :node5)

add_node_data!(dg, 1, 7, "weight")
add_node_data!(dg, 2, 3.4, "weight")
add_node_data!(dg, 3, 2, "weight")
add_node_data!(dg, "node4", 4, "weight")
add_node_data!(dg, :node5, 1, "weight")

add_edge!(dg, 1, 2)
add_edge!(dg, 2, 3)
add_edge!(dg, "node4", 1)
add_edge!(dg, :node5, 2)
add_edge!(dg, 3, "node4")

add_edge_data!(dg, 1, 2, 17.4, "weight")
add_edge_data!(dg, 2, 3, 4.2, "weight")
add_edge_data!(dg, "node4", 1, 1.0, "weight")
add_edge_data!(dg, :node5, 2, -.00001, "weight")
add_edge_data!(dg, 3, "node4", 1, "weight")

plot_graph(dg; xdim = 400, ydim = 400)
