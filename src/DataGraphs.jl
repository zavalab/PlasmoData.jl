module DataGraphs

using Graphs
using SparseArrays
using Statistics
using LinearAlgebra

export DataGraph, DataDiGraph, add_node!, add_node_data!, add_edge_data!, adjacency_matrix
export get_EC, matrix_to_graph, symmetric_matrix_to_graph, mvts_to_graph, tensor_to_graph
export filter_nodes, filter_edges, run_EC_on_nodes, run_EC_on_edges, aggregate
export get_node_data, get_edge_data, ne, nn, nv, remove_node!, remove_edge!
export add_node_attribute!, add_edge_attribute!, has_edge, has_node, has_pathG
export get_node_attributes, get_edge_attributes, get_path
export nodes_to_index, index_to_nodes, average_degree
export rename_node_attribute!, rename_edge_attribute!, add_node_dataset!, add_edge_dataset!

abstract type AbstractDataGraph{T} <: Graphs.AbstractGraph{T} end

"""
    NodeData{T, T1, M1}

Object for building and storing data corresponding to the nodes of a graph. Data is stored
in a matrix, but columns of the matrix have attribute names stored in this struct

NodeData have the following attributes:
 `attributes`: vector of strings with length equal to the number of columns of `data`. Each
 entry is the name of the attribute of that column of data
 `attribute_map`: dictionary with keys matching the entries of `attributes`. Maps the key
 to the corresponding column index
 `data`: Matrix with the number of rows corresponding to the number of nodes in the graph
 and with a column for each attribute in `attributes`
"""
mutable struct NodeData{T, T1, M1}
    attributes::Vector{String}
    attribute_map::Dict{String, T}
    data::AbstractMatrix{T1}
end

"""
    EdgeData{T, T2, M2}

Object for building and storing data corresponding to the edges of a graph. Data is stored
in a matrix, but columns of the matrix have attribute names stored in this struct

EdgeData have the following attributes:
 `attributes`: vector of strings with length equal to the number of columns of `data`. Each
 entry is the name of the attribute of that column of data
 `attribute_map`: dictionary with keys matching the entries of `attributes`. Maps the key
 to the corresponding column index
 `data`: Matrix with the number of rows corresponding to the number of edgess in the graph
 and with a column for each attribute in `attributes`
"""
mutable struct EdgeData{T, T2, M2}
    attributes::Vector{String}
    attribute_map::Dict{String, T}
    data::AbstractMatrix{T2}
end

"""
    NodeData(attributes = Vector{String}(),
        attribute_map = Dict{String, Int}(),
        data = Array{Float64}(undef, (0, 0))
    )

Constructor for building NodeData{T, T1, M1}
"""
function NodeData(
    attributes::Vector{String} = Vector{String}(),
    attribute_map::Dict{String, T} = Dict{String, Int}(),
    data::M1 = Array{Float64}(undef, (0, 0))
) where {T <: Real, T1, M1 <: AbstractMatrix{T1}}
    NodeData{T, T1, M1}(
        attributes,
        attribute_map,
        data
    )
end

"""
    EdgeData(attributes = Vector{String}(),
        attribute_map = Dict{String, Int}(),
        data = Array{Float64}(undef, (0, 0))
    )

Constructor for building EdgeData{T, T2, M2}
"""
function EdgeData(
    attributes::Vector{String} = Vector{String}(),
    attribute_map::Dict{String, T} = Dict{String, Int}(),
    data::M2 = NamedArray{Float64}(undef, (0, 0))
) where {T <: Real, T2, M2 <: AbstractMatrix{T2}}
    EdgeData{T, T2, M2}(
        attributes,
        attribute_map,
        data
    )
end

"""
    DataGraph{T, T1, T2, M1, M2}

Object for building and storing undirected graphs that contain numerical data on nodes and/or edges.

DataGraphs have the following attributes:
 `g`: Graphs.SimpleGraph Object
 `nodes`: Vector of node names; node names are of type `Any`
 `edges`: Vector of edges; edges are tuples of integers
 `node_map`: dictionary pointing node name to node number
 `edge_map`: dictionary pointing tuple (node_name1, node_name2) to (node_number1, node_number2)
 `node_data`: NodeData object with attributes and data
 `edge_data`: EdgeData object with attributes and data
 `node_positions`: x-y coordinates for node positions; defaults to an empty Vector
"""
mutable struct DataGraph{T, T1, T2, M1, M2} <: AbstractDataGraph{T}
    g::Graphs.SimpleGraph{T}

    nodes::Vector{Any}
    edges::Vector{Tuple{T, T}}
    node_map::Dict{Any, T}
    edge_map::Dict{Tuple{T, T}, T}

    node_data::NodeData{T, T1, M1}
    edge_data::EdgeData{T, T2, M2}
end

"""
    DataDiGraph{T, T1, T2, M1, M2}

Object for building and storing directed graphs that contain numerical data on nodes and/or edges.

DataDiGraphs have the following attributes:
 `g`: Graphs.SimpleDiGraph Object
 `nodes`: Vector of node names; node names are of type `Any`
 `edges`: Vector of edges; edges are tuples of integers
 `node_map`: dictionary pointing node name to node number
 `edge_map`: dictionary pointing tuple (node_name1, node_name2) to (node_number1, node_number2)
 `node_data`: NodeData object with attributes and data
 `edge_data`: EdgeData object with attributes and data
 `node_positions`: x-y coordinates for node positions; defaults to an empty Vector
"""
mutable struct DataDiGraph{T, T1, T2, M1, M2} <: AbstractDataGraph{T}
    g::Graphs.SimpleDiGraph{T}

    nodes::Vector{Any}
    edges::Vector{Tuple{T, T}}
    node_map::Dict{Any, T}
    edge_map::Dict{Tuple{T, T}, T}

    node_data::NodeData{T, T1, M1}
    edge_data::EdgeData{T, T2, M2}
end

"""
    DataGraphUnion

Data type that is a union of DataGraph and DataDiGraph; used for functions that apply to
both data types
"""
DataGraphUnion = Union{DataGraph{T}, DataDiGraph{T}} where T

function Base.eltype(datagraph::D) where {D <: DataGraphUnion}
    return eltype(eltype(datagraph.g.fadjlist))
end

include("datagraphs/core.jl")
include("datadigraphs/core.jl")
include("datadigraphs/utils.jl")
include("datadigraphs/interface.jl")
include("datagraphs/interface.jl")
include("datagraphs/utils.jl")
include("functions.jl")
include("interface.jl")

end
