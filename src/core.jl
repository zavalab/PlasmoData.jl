abstract type AbstractDataGraph{T} <: Graphs.AbstractGraph{T} end

mutable struct NodeData{T, M}
    attributes::Vector{String}
    attribute_map::Dict{String, Int}
    data::M
end

function NodeData(
    attributes::Vector{String} = Vector{String}(),
    attribute_map::Dict{String, Int} = Dict{String, Int}(),
    data::M = Array{Float64}(undef, 0, 0)
) where {T, M <: Matrix{T}}
    NodeData{T, M}(
        attributes,
        attribute_map,
        data
    )
end

mutable struct EdgeData{T, M}
    attributes::Vector{String}
    attribute_map::Dict{String, Int}
    data::M
end

function EdgeData(
    attributes::Vector{String} = Vector{String}(),
    attribute_map::Dict{String, Int} = Dict{String, Int}(),
    data::M = NamedArray{Float64}(undef, 0, 0)
) where {T, M <: Matrix{T}}
    EdgeData{T, M}(
        attributes,
        attribute_map,
        data
    )
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

function Base.eltype(datagraph::DataGraph)
    return eltype(eltype(datagraph.g.fadjlist))
end

function DataGraph(
    nodes::Vector{Any},
    edges::Vector{Tuple{T, T}};
    ne::T = length(edges),
    fadjlist::Vector{Vector{T}} = [Vector{Int} for i in 1:length(nodes)],
    node_attributes::Vector{String} = String[],
    edge_attributes::Vector{String} = String[],
    node_map::Dict{Any, Int} = Dict{Any, Int}(),
    edge_map::Dict{Tuple{T}, Int} = Dict{Any, Int}(),
    node_data::M1 = Array{Float64}(undef, 0, 0),
    edge_data::M2 = Array{Float64}(undef, 0, 0),
    node_positions = [[0.0 0.0]]
) where {T <: Int, T1, T2, M1 <: Matrix{T1}, M2 <: Matrix{T2}}

    if length(edges) != ne
        error("Defined edges do not match ne")
    end
    if ne != length(edge_map)
        error("edge_map does not match the number of edges")
    end
    if length(nodes) != length(node_map)
        error("node_map does not match the number of nodes")
    end

    g = SimpleGraph(ne, fadjlist)

    node_attribute_map = Dict{String, Int}()
    edge_attribute_map = Dict{String, Int}()

    for i in 1:length(node_attributes)
        node_attribute_map[node_attributes[i]] = i
    end

    for i in 1:length(edge_attributes)
        edge_attribtue_map[edge_attributes[i]] = i
    end

    node_data_struct = NodeData(node_attributes, node_attribute_map, node_data)
    edge_data_struct = EdgeData(edge_attributes, edge_attribute_map, edge_data)

    DataGraph{T, M1, M2}(
        g, nodes, edges, node_map, edge_map,
        node_data_struct, edge_data_struct, node_positions
    )
end

function DataGraph{T, T1, T2, M1, M2}() where {T <: Integer, T1, T2,  M1 <: Matrix{T1}, M2 <: Matrix{T2}}
    nodes = Vector{Any}()
    edges = Vector{Tuple{Int, Int}}()

    ne = 0
    fadjlist = Vector{Vector{Int}}()

    node_map = Dict{Any, Int}()
    edge_map = Dict{Tuple{Int, Int}, Int}()
    node_attributes = String[]
    edge_attributes = String[]
    node_attribute_map = Dict{String, Int}()
    edge_attribute_map = Dict{String, Int}()
    node_data = Array{Float64}(undef, 0, 0)
    edge_data = Array{Float64}(undef, 0, 0)

    node_positions = [[0.0 0.0]]

    g = SimpleGraph(ne, fadjlist)

    node_data_struct = NodeData(node_attributes, node_attribute_map, node_data)
    edge_data_struct = EdgeData(edge_attributes, edge_attribute_map, edge_data)

    DataGraph{T, T1, T2, M1, M2}(
        g, nodes, edges, node_map, edge_map,
        node_data_struct, edge_data_struct, node_positions
    )
end

DataGraph() = DataGraph{Int, Float64, Float64, Matrix{Float64}, Matrix{Float64}}()

function DataGraph(adj_mat::AbstractMatrix{T}) where {T <: Real}

    dima, dimb = size(adj_mat)
    isequal(dima, dimb) || throw(ArgumentError("Adjacency / distance matrices must be square"))
    LinearAlgebra.issymmetric(adj_mat) || throw(ArgumentError("Adjacency / distance matrices must be symmetric"))

    dg = DataGraph()

    @inbounds for i in findall(LinearAlgebra.triu(adj_mat) .!= 0)
        Graphs.add_edge!(dg, i[1], i[2])
    end

    return dg
end

function DataGraph(edge_list::Vector{T}) where {T <: Tuple{Any, Any}}
    dg = DataGraph()

    for i in edge_list
        Graphs.add_edge!(dg, i[1], i[2])
    end

    return dg
end

function _get_edge(node1_index, node2_index)
    if node2_index > node1_index
        return (node1_index, node2_index)
    else
        return (node2_index, node1_index)
    end
end


"""
    add_node!(dg, node_name)

Add the node `node_name` to the DataGraph `dg`
"""
function add_node!(
    dg::DataGraph, node_name::Any
)
    nodes      = dg.nodes
    attributes = dg.node_data.attributes
    node_map   = dg.node_map

    T = eltype(dg)

    # If new node is not in the list of nodes, add it
    # otherwise, print that the node exists and don't do anything
    if !(node_name in nodes)
        push!(nodes,node_name)
        push!(dg.g.fadjlist, Vector{T}())

        # If there are data currently defined on the other nodes, add a NaN value to
        # the end of the weight array for the new node
        if length(attributes)>0
            node_data = dg.node_data.data
            row_to_add = fill(NaN, (1, length(attributes)))
            node_data = vcat(node_data, row_to_add)
            dg.node_data._data = node_data
        end

        # Add the new node as a key to the dictionary
        node_map[node_name] = length(nodes)
        dg.node_map = node_map
        return true
    else
       println("Node already exists")
       return false
    end
end


"""
    add_edge!(g, node_1, node_2)
    add_edge!(g, (node1, node2))

Add an edge to the graph, `g`. If the nodes are not defined in the graph, they are added to the graph
"""
function Graphs.add_edge!(dg::DataGraph, node1::Any, node2::Any)
    edges      = dg.edges
    nodes      = dg.nodes
    attributes = dg.edge_data.attributes
    edge_map   = dg.edge_map

    if !(node1 in nodes)
        add_node!(dg, node1)
    end
    if !(node2 in nodes)
        add_node!(dg, node2)
    end

    nodes       = dg.nodes
    node_map    = dg.node_map

    node1_index = node_map[node1]
    node2_index = node_map[node2]

    edge = _get_edge(node1_index, node2_index)

    # If the edge isn't already defined, then add the edge; add to weight arrays too
    if !(edge in edges)
        push!(edges, edge)
        dg.g.ne += 1

        @inbounds node_neighbors = dg.g.fadjlist[node1_index]
        index = searchsortedfirst(node_neighbors, node2_index)
        insert!(node_neighbors, index, node2_index)

        @inbounds node_neighbors = dg.g.fadjlist[node2_index]
        index = searchsortedfirst(node_neighbors, node1_index)
        insert!(node_neighbors, index, node1_index)


        if length(attributes)>0
            edge_data  = dg.edge_data.data
            row_to_add = fill(NaN, (1, length(attributes)))
            edge_data  = vcat(edge_data, row_to_add)
            dg.edge_data.data = edge_data
        end

        edge_map[edge] = length(edges)
        return true
    else
        return false
    end
end

function Graphs.add_edge!(dg::DataGraph, edge::Tuple{Any, Any})
    Graphs.add_edge!(dg::DataGraph, edge[1], edge[2])
end

function add_node_data!(dg::DataGraph, node::Any, node_weight::Number, attribute::String)
    nodes         = dg.nodes
    attributes    = dg.node_data.attributes
    node_map      = dg.node_map
    node_data     = dg.node_data.data
    attribute_map = dg.node_data.attribute_map

    if !(node in nodes)
        error("node does not exist in graph")
    end

    if length(attributes) < 1
        node_data = Array{eltype(dg.node_data.data)}(undef, length(nodes), 0)
        dg.node_data.data = node_data
    end

    if !(attribute in attributes)
        # Add new column to node_weight array
        push!(attributes, attribute)
        attribute_map[attribute] = length(attributes)
        new_col = fill(NaN, (length(nodes), 1))
        node_data = hcat(node_data, new_col)
        node_data[node_map[node], attribute_map[attribute]] = node_weight
        dg.node_data.data = node_data
        return true
    else
        node_data[node_map[node], attribute_map[attribute]] = node_weight
        return true
    end
end

function add_edge_data!(dg::DataGraph, node1::Any, node2::Any, edge_weight::Real, attribute::String)
    edges         = dg.edges
    attributes    = dg.edge_data.attributes
    edge_map      = dg.edge_map
    node_map      = dg.node_map
    attribute_map = dg.edge_data.attribute_map

    node1_index = node_map[node1]
    node2_index = node_map[node2]

    edge = _get_edge(node1_index, node2_index)

    if !(edge in edges)
        error("edge does not exist in graph")
    end

    if length(attributes) == 0
        edge_data = Array{eltype(dg.edge_data.data)}(undef, length(edges), 0)
        dg.edge_data.data = edge_data
    end

    if !(attribute in attributes)
        edge_data = dg.edge_data.data
        # Add new column to node_weight array
        push!(attributes, attribute)
        attribute_map[attribute] = length(attributes)
        new_col = fill(NaN, (length(edges), 1))
        edge_data = hcat(edge_data, new_col)
        edge_data[edge_map[edge], attribute_map[attribute]] = edge_weight
        dg.edge_data.data = edge_data
        return true
    else
        edge_data = dg.edge_data.data
        edge_data[edge_map[edge], attribute_map[attribute]] = edge_weight
        return true
    end
end

function add_edge_data!(dg::DataGraph, edge::Tuple{Any, Any}, edge_weight::Real, attribute::String)
    add_edge_data!(dg, edge[1], edge[2], edge_weight, attribute)
end

function adjacency_matrix(dg::DataGraph)
    am = Graphs.LinAlg.adjacency_matrix(dg.g)
    return am
end
