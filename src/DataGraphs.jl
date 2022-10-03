module DataGraphs

using Graphs
using SparseArrays
using Statistics
using GeometryBasics
using LinearAlgebra

export DataGraph, DataDiGraph, add_node!, add_node_data!, add_edge_data!, adjacency_matrix
export get_EC, matrix_to_graph, symmetric_matrix_to_graph, mvts_to_graph, tensor_to_graph
export filter_nodes, filter_edges, run_EC_on_nodes, run_EC_on_edges, aggregate, average_degree
export get_node_data, get_edge_data

abstract type AbstractDataGraph{T} <: Graphs.AbstractGraph{T} end

mutable struct NodeData{T, M}
    attributes::Vector{String}
    attribute_map::Dict{String, Int}
    data::M
end

mutable struct EdgeData{T, M}
    attributes::Vector{String}
    attribute_map::Dict{String, Int}
    data::M
end

mutable struct DataGraph{T, T1, T2, M1, M2} <: AbstractDataGraph{T}
    g::Graphs.SimpleGraph{T}

    nodes::Vector{Any}
    edges::Vector{Tuple{T, T}}
    node_map::Dict{Any, T}
    edge_map::Dict{Tuple{T, T}, T}

    node_data::NodeData{T1, M1}
    edge_data::EdgeData{T2, M2}

    node_positions::Array{Union{GeometryBasics.Point{2,Float64}, Array{Float64, 2}},1}
end


mutable struct DataDiGraph{T, T1, T2, M1, M2} <: AbstractDataGraph{T}
    g::Graphs.SimpleDiGraph{T}

    nodes::Vector{Any}
    edges::Vector{Tuple{T, T}}
    node_map::Dict{Any, T}
    edge_map::Dict{Tuple{T, T}, T}

    node_data::NodeData{T1, M1}
    edge_data::EdgeData{T2, M2}

    node_positions::Array{Union{GeometryBasics.Point{2,Float64}, Array{Float64, 2}},1}
end

DataGraphUnion = Union{DataGraph, DataDiGraph}

include("datagraphs/core.jl")
include("datadigraphs/core.jl")
include("datagraphs/interface.jl")
include("datagraphs/utils.jl")
include("functions.jl")

end
