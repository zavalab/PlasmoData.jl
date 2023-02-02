using Test
using DataGraphs, SparseArrays, LinearAlgebra, Graphs, Random

function test_map(vector, map)
    for i in 1:length(vector)
        if !(map[vector[i]] == i)
            return false
        end
    end
    return true
end

function test_edge_exists(dg, node1, node2)
    node_map = dg.node_map

    node1_num = node_map[node1]
    node2_num = node_map[node2]

    if node1_num > node2_num
        edge = (node2_num, node1_num)
    else
        edge = (node1_num, node2_num)
    end

    if edge in dg.edges
        return true
    else
        return false
    end
end

include("DataGraph_test.jl")
include("DataGraph_utils_test.jl")
include("DataGraph_interface_test.jl")
include("DataDiGraph_test.jl")
include("DataDiGraph_utils_test.jl")
include("DataDiGraph_interface_test.jl")
