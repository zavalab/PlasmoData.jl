function Base.eltype(datagraph::D) where {D <: DataGraphUnion}
    return eltype(eltype(datagraph.g.fadjlist))
end
#=
"""
    DataGraph(nodes, edges; kwargs)

Constructor for building a DataGraph object from a list of nodes and edges. Key word arguments
include `ne`, `fadjlist`, `node_attributes`, `edge_attributes`, `node_map`, `edge_map`,
`node_data`, `edge_data`, and `node_positions`.
"""
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
=#
"""
    DataGraph{T, T1, T2, M1, M2}()
    DataGraph()

Constructor for initializing and empty DataGraph object. Datatypes are as follows: T is the
integer type for indexing, T1 and T2 are the data type in the node and edge data respectively,
and M1 <: AbstractMatrix{T1} corresponds to the node data and M2 <: AbstractMatrix{T2} corresponds
to the edge data.

When T, T1, T2, M1, and M2 are not defined, the defaults are `Int`, `Float64`, `Float64`,
`Matrix{Float64}`, and `Matrix{Float64}` respectively.
"""
function DataGraph{T, T1, T2, M1, M2}() where {T <: Integer, T1, T2,  M1 <: AbstractMatrix{T1}, M2 <: AbstractMatrix{T2}}
    nodes = Vector{String}()
    edges = Vector{Tuple{T, T}}()

    ne = 0
    fadjlist = Vector{Vector{T}}()

    node_data = NamedArray([])
    edge_data = NamedArray([])

    node_attributes = Vector{String}()
    edge_attributes = Vector{String}()

    node_positions = [[0.0 0.0]]

    g = SimpleGraph(ne, fadjlist)


    DataGraph{T, T1, T2, M1, M2}(
        g, nodes, edges, node_data, edge_data,
        node_attributes, edge_attributes, node_positions
    )
end

DataGraph() = DataGraph{Int, Float64, Float64, Matrix{Float64}, Matrix{Float64}}()

"""
    DataGraph(adjacency_matrix::AbstractMatrix)

Constructor for building a DataGraph object from an adjacency matrix.
"""
function DataGraph(adj_mat::AbstractMatrix{T}) where {T <: Real}

    dima, dimb = size(adj_mat)
    isequal(dima, dimb) || throw(ArgumentError("Adjacency / distance matrices must be square"))
    LinearAlgebra.issymmetric(adj_mat) || throw(ArgumentError("Adjacency / distance matrices must be symmetric"))

    dg = DataGraph()

    @inbounds for i in findall(LinearAlgebra.triu(adj_mat) .!= 0)
        DataGraphs.add_edge!(dg, i[1], i[2])
    end

    return dg
end

"""
    DataGraph(edge_list)

Constructor for building a DataGraph object from a list of edges, where the edge list is a
vector of Tuple{Any, Any}.
"""
function DataGraph(edge_list::Vector{T}) where {T <: Tuple{Any, Any}}
    dg = DataGraph()

    for i in edge_list
        DataGraphs.add_edge!(dg, i[1], i[2])
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
    dg::DataGraph, node_name::String
)
    nodes      = dg.nodes
    node_data  = dg.node_data

    if typeof(node_name) != String
        node_name = string(node_name)
    end

    T = eltype(dg)

    # If new node is not in the list of nodes, add it
    # otherwise, print that the node exists and don't do anything
    if !(node_name in nodes)
        push!(nodes, node_name)
        push!(dg.g.fadjlist, Vector{T}())

        # If there are data currently defined on the other nodes, add a NaN value to
        # the end of the weight array for the new node
        if length(node_data) > 0
            row_to_add = fill(NaN, (1, length(dg.node_attributes)))
            node_data.array = vcat(node_data.array, row_to_add)
            node_data.dicts[1][node_name] = length(nodes)
            dg.node_data = node_data
        end

        return true
    else
       println("Node already exists")
       return false
    end
end

function add_node!(dg::DataGraph, node_name::Any)
    node_name = string(node_name)
    return DataGraphs.add_node!(dg, node_name)
end

"""
    add_edge!(dg, node_1, node_2)
    add_edge!(dg, (node1, node2))

Add an edge to the DataGraph, `dg`. If the nodes are not defined in the graph, they are added to the graph
"""
function add_edge!(dg::DataGraph, node1::String, node2::String)
    edges      = dg.edges
    nodes      = dg.nodes

    if typeof(node1) != String
        node1 = string(node1)
    end

    if typeof(node2) != String
        node2 = string(node2)
    end

    if !(node1 in nodes)
        add_node!(dg, node1)
    end
    if !(node2 in nodes)
        add_node!(dg, node2)
    end

    nodes       = dg.nodes
    node_data   = dg.node_data
    edge_data   = dg.edge_data

    if length(dg.node_attributes) > 0
        node1_index = node_data.dicts[1][node1]
        node2_index = node_data.dicts[1][node2]
    end

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

        if length(edge_data) > 0
            edge_data  = dg.edge_data.data
            row_to_add = fill(NaN, (1, length(dg.edge_attributes)))
            edge_data.array = vcat(edge_data.array, row_to_add)
            edge_data.dicts[1][string(edge)] = length(edges)
            dg.edge_data = edge_data
        end

        return true
    else
        return false
    end
end

function add_edge!(dg::DataGraph, node1::N1, node2::String) where {N1 <: Any}
    node1 = string(node1)
    return DataGraphs.add_edge!(dg, node1, node2)
end

function add_edge!(dg::DataGraph, node1::String, node2::N2) where {N2 <: Any}
    node2 = string(node2)
    return DataGraphs.add_edge!(dg, node1, node2)
end

function add_edge!(dg::DataGraph, node1::N1, node2::N2) where {N1 <: Any, N2 <: Any}
    node1 = string(node1)
    node2 = string(node2)
    return DataGraphs.add_edge!(dg, node1, node2)
end

function add_edge!(dg::DataGraph, edge::Tuple{N1, N2}) where {N1 <: Any, N2 <: Any}
    DataGraphs.add_edge!(dg::DataGraph, edge[1], edge[2])
end

"""
    add_node_data!(datagraph, node_name, node_weight, attribute_name)

Add a weight value for the given node name in the DataGraph object. User must pass an "attribute
name" for the given weight. All other nodes that do not have a node_weight value defined for
that attribute name default to a value of zero.
"""
function add_node_data!(dg::DataGraph, node::String, node_weight::T, attribute::String) where {T <: Real}
    nodes           = dg.nodes
    node_data       = dg.node_data
    node_attributes = dg.node_attributes

    if !(node in nodes)
        error("node does not exist in graph")
    end

    if length(node_data) == 0
        node_data = NamedArray(zeros(len(nodes), 1), (nodes, [attribute]))
        push!(node_attributes, attribute)
        node_data[node, attribute] = node_weight
        dg.node_attributes = node_attributes
        dg.node_data = node_data
        return true
    end

    if !(attribute in node_attributes)
        # Add new column to node_data array
        push!(node_attributes, attribute)
        new_col = fill(NaN, (length(nodes), 1))
        node_data.array = hcat(node_data.array, new_col)
        node_data.dicts[2][attribute] = length(node_attributes)
        node_data[node, attribute] = node_weight
        dg.node_data = node_data
        return true
    else
        node_data[node, attribute] = node_weight
        dg.node_data = node_data
        return true
    end
end

function add_node_data!(dg::DataGraph, node::N, node_weight::T, attribute::String) where {N <: Any, T <: Real}
    node = string(node)
    return  DataGraphs.add_node_data!(dg, node, node_weight, attribute)
end

"""
    add_edge_data!(datagraph, node_name1, node_name2, edge_weight, attribute_name)
    add_edge_data!(datagraph, edge, edge_weight, attribute_name)

Add a weight value for the edge between node_name1 and node_name2 in the DataGraph object.
When using the second function, `edge` must be a tuple with two node names. User must pass
an "attribute name" for the given weight. All other edges that do not have an edge_weight
value defined for that attribute name default to a value of zero.
"""
function add_edge_data!(dg::DataGraph, node1::String, node2::String, edge_weight::T, attribute::String) where {T <: Real}
    #TODO: use multiple dispatch to allow for node1/2 of type string rather than any so that I can eliminate the if statements
    edges     = dg.edges
    node_data = dg.node_data

    node1_index = node_data.dicts[1][node1]
    node2_index = node_data.dicts[1][node2]

    edge = _get_edge(node1_index, node2_index)

    edge_attributes = dg.edge_attributes
    edge_data       = dg.edge_data
    if !(edge in edges)
        error("edge does not exist in graph")
    end

    if length(edge_attributes) == 0
        edge_data = NamedArray(zeros(len(edges), 1), (edges, [attribute]))
        push!(edge_attributes, attribute)
        edge_data[edge, attribute] = edge_weight
        dg.edge_attributes = edge_attributes
        dg.edge_data = edge_data
        return true
    end

    if !(attribute in attributes)
        # Add new column to node_weight array
        push!(edge_attributes, attribute)
        new_col = fill(NaN, (length(edges), 1))
        edge_data.array = hcat(edge_data.array, new_col)
        edge_data.dicts[2][attribute] = length(edge_attributes)
        edge_data[edge, attribute] = edge_weight
        dg.edge_data = edge_data
        dg.edge_attributes = edge_attributes
        return true
    else
        edge_data[edge, attribute] = edge_weight
        dg.edge_data = edge_data
        return true
    end
end

function add_edge_data!(dg::DataGraph, node1::N1, node2::String, edge_weight::T, attribute::String) where {N1 <: Any, T <: Real}
    node1 = string(node1)
    DataGraphs.add_edge_data!(dg, node1, node2, edge_weight, attribute)
end

function add_edge_data!(dg::DataGraph, node1::String, node2::N2, edge_weight::T, attribute::String) where {N2 <: Any, T <: Real}
    node2 = string(node2)
    DataGraphs.add_edge_data!(dg, node1, node2, edge_weight, attribute)
end

function add_edge_data!(dg::DataGraph, node1::N1, node2::N2, edge_weight::T, attribute::String) where {N1 <: Any, N2 <: Any, T <: Real}
    node1 = string(node1)
    node2 = string(node2)
    DataGraphs.add_edge_data!(dg, node1, node2, edge_weight, attribute)
end

function add_edge_data!(dg::DataGraph, edge::Tuple{Any, Any}, edge_weight::T, attribute::String) where {T <: Real}
    add_edge_data!(dg, edge[1], edge[2], edge_weight, attribute)
end

"""
    adjacency_matrix(datagraph)

Return the adjacency matrix of a DataGraph object
"""
function adjacency_matrix(dg::D) where {D <: DataGraphUnion}
    am = Graphs.LinAlg.adjacency_matrix(dg.g)
    return am
end
