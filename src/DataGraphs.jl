module DataGraphs

using Graphs
using SparseArrays
using Statistics
using GeometryBasics

export DataGraph, add_node!, add_node_data!, add_edge_data!, create_adj_mat
export get_EC, matrix_to_graph, symmetric_matrix_to_graph, mvts_to_graph
export filter_nodes, filter_edges, run_EC_on_nodes, run_EC_on_edges, aggregate, average_degree

include("core.jl")
include("interface.jl")
include("utils.jl")
include("functions.jl")

end
