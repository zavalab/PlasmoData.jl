module DataGraphs

using Graphs
using SparseArrays
using Statistics
using GeometryBasics

export DataGraph, add_node!, add_node_data!, add_edge_data!, adjacency_matrix
export get_EC, matrix_to_graph, symmetric_matrix_to_graph, mvts_to_graph, tensor_to_graph
export filter_nodes, filter_edges, run_EC_on_nodes, run_EC_on_edges, aggregate, average_degree
export get_node_data, get_edge_data

include("core.jl")
include("interface.jl")
include("utils.jl")
include("functions.jl")

end
