include("../src/DataGraphs.jl")
#include("matrix_test.jl")
dg = DataGraphs.DataGraph()

DataGraphs.add_node!(dg, 1)
DataGraphs.add_node!(dg, 2)
DataGraphs.add_node!(dg, 3)
DataGraphs.add_node!(dg, "node4")
DataGraphs.add_node!(dg, :node5)

DataGraphs.add_node_data!(dg, 1, 7, "weight")
DataGraphs.add_node_data!(dg, 2, 3.4, "weight")
DataGraphs.add_node_data!(dg, 3, 2, "weight")
DataGraphs.add_node_data!(dg, "node4", 4, "weight")
DataGraphs.add_node_data!(dg, :node5, 1, "weight")

DataGraphs.add_edge!(dg, 1, 2)
DataGraphs.add_edge!(dg, 2, 3)
DataGraphs.add_edge!(dg, "node4", 1)
DataGraphs.add_edge!(dg, :node5, 2)
DataGraphs.add_edge!(dg, 3, "node4")

DataGraphs.add_edge_data!(dg, 1, 2, 17.4, "weight")
DataGraphs.add_edge_data!(dg, 2, 3, 4.2, "weight")
DataGraphs.add_edge_data!(dg, "node4", 1, 1.0, "weight")
DataGraphs.add_edge_data!(dg, :node5, 2, -.00001, "weight")
DataGraphs.add_edge_data!(dg, 3, "node4", 1, "weight")

DataGraphs.plot_graph(dg; xdim = 400, ydim = 400)
