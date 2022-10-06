using Revise
using DataGraphs, Graphs
using DataGraphPlots

mat = rand(10, 10)

mat_graph = DataGraphs.matrix_to_graph(mat)

plot_graph(mat_graph, linecolor=:gray, C=1, K=.01, xdim = 400, ydim = 400, node_z = mat_graph.node_data.data, nodecolor = :algae)

agg_mat_graph = aggregate(mat_graph, [(5,8), (6,8), (7,8), (5,7), (6,7)], "agg1")

plot_graph(agg_mat_graph, get_new_positions=false, linecolor=:gray, xdim = 400, ydim = 400)
