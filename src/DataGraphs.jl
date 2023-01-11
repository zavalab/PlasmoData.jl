module DataGraphs

using Graphs
using SparseArrays
using Statistics
using GeometryBasics
using LinearAlgebra
using NamedArrays

export DataGraph, DataDiGraph, add_node!, add_node_data!, add_edge_data!, adjacency_matrix
export get_EC, matrix_to_graph, symmetric_matrix_to_graph, mvts_to_graph, tensor_to_graph
export filter_nodes, filter_edges, run_EC_on_nodes, run_EC_on_edges, aggregate, average_degree
export get_node_data, get_edge_data, ne, nn, nv

abstract type AbstractDataGraph{T} <: Graphs.AbstractGraph{T} end

"""
    DataGraph{T, T1, T2, M1, M2}

Object for building and storing undirected graphs that contain numerical data on nodes and/or edges.

DataGraphs have the following attributes:
 `g`: Graphs.SimpleGraph Object
 `nodes`: Vector of node names; node names are of type 'String'
 `edges`: Vector of edges; edges are tuples of integers
 `node_data`: `NamedArray` for storing node data
 `edge_data`: `NamedArray` for storing edge data
 `node_positions`: x-y coordinates for node positions; defaults to an empty Vector
"""
mutable struct DataGraph{T, T1, T2, M1, M2} <: AbstractDataGraph{T}
    g::Graphs.SimpleGraph{T}

    nodes::Vector{String}
    edges::Vector{Tuple{T, T}}

    node_data::NamedArray{T1}#, 2, M1}
    edge_data::NamedArray{T2}#, 2, M2}

    node_attributes::Vector{String}
    edge_attributes::Vector{String}

    node_positions::Array{Union{GeometryBasics.Point{2,Float64}, Array{Float64, 2}}, 1}
end

"""
    DataDiGraph{T, T1, T2, M1, M2}

Object for building and storing directed graphs that contain numerical data on nodes and/or edges.

DataDiGraphs have the following attributes:
 `g`: Graphs.SimpleDiGraph Object
 `nodes`: Vector of node names; node names are of type `String`
 `edges`: Vector of edges; edges are tuples of integers
 `node_data`: `NamedArray` for storing node data
 `edge_data`: `NamedArray` for storing edge data
 `node_positions`: x-y coordinates for node positions; defaults to an empty Vector
"""
mutable struct DataDiGraph{T, T1, T2, M1, M2} <: AbstractDataGraph{T}
    g::Graphs.SimpleDiGraph{T}

    nodes::Vector{String}
    edges::Vector{Tuple{T, T}}

    node_data::NamedArray{T1}#, 2, M1}
    edge_data::NamedArray{T2}#, 2, M2}

    node_attributes::Vector{String}
    edge_attributes::Vector{String}

    node_positions::Array{Union{GeometryBasics.Point{2,Float64}, Array{Float64, 2}},1}
end

"""
    DataGraphUnion

Data type that is a union of DataGraph and DataDiGraph; used for functions that apply to
both data types
"""
DataGraphUnion = Union{DataGraph, DataDiGraph}

include("datagraphs/core.jl")
include("datadigraphs/core.jl")
include("datagraphs/interface.jl")
include("datagraphs/utils.jl")
include("functions.jl")

end
