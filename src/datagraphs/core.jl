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

function Base.eltype(datagraph::D) where {D <: DataGraphUnion}
    return eltype(eltype(datagraph.g.fadjlist))
end

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
    nodes = Vector{Any}()
    edges = Vector{Tuple{T, T}}()

    ne = 0
    fadjlist = Vector{Vector{T}}()

    node_map = Dict{Any, T}()
    edge_map = Dict{Tuple{T, T}, T}()
    node_attributes = String[]
    edge_attributes = String[]
    node_attribute_map = Dict{String, T}()
    edge_attribute_map = Dict{String, T}()
    node_data = M1(undef, 0, 0)
    edge_data = M2(undef, 0, 0)

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
    dg::DataGraph, node_name::N
) where {N <: Any}
    nodes      = dg.nodes
    attributes = dg.node_data.attributes
    node_map   = dg.node_map

    T = eltype(dg)

    # If new node is not in the list of nodes, add it
    # otherwise, print that the node exists and don't do anything
    if !(node_name in nodes)
        push!(nodes,node_name)
        push!(dg.g.fadjlist, Vector{T}())

        # If there are data currently defined on the other nodes, add a 0 value to
        # the end of the weight array for the new node
        if length(attributes)>0
            node_data = dg.node_data.data
            row_to_add = fill(0, (1, length(attributes)))
            node_data = vcat(node_data, row_to_add)
            dg.node_data.data = node_data
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
    add_edge!(dg, node_1, node_2)
    add_edge!(dg, (node1, node2))

Add an edge to the DataGraph, `dg`. If the nodes are not defined in the graph, they are added to the graph
"""
function add_edge!(dg::DataGraph, node1::N1, node2::N2) where {N1 <: Any, N2 <: Any}
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
            row_to_add = fill(0, (1, length(attributes)))
            edge_data  = vcat(edge_data, row_to_add)
            dg.edge_data.data = edge_data
        end

        edge_map[edge] = length(edges)
        return true
    else
        return false
    end
end

function add_edge!(dg::DataGraph, edge::Tuple{Any, Any})
    DataGraphs.add_edge!(dg::DataGraph, edge[1], edge[2])
end

"""
    add_node_data!(datagraph, node_name, node_weight, attribute_name)

Add a weight value for the given node name in the DataGraph object. User must pass an "attribute
name" for the given weight. All other nodes that do not have a node_weight value defined for
that attribute name default to a value of zero.
"""
function add_node_data!(dg::DataGraph, node::Any, node_weight::T, attribute::String) where {T <: Real}
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
        new_col = fill(0, (length(nodes), 1))
        node_data = hcat(node_data, new_col)
        node_data[node_map[node], attribute_map[attribute]] = node_weight
        dg.node_data.data = node_data
        return true
    else
        node_data[node_map[node], attribute_map[attribute]] = node_weight
        return true
    end
end

"""
    add_edge_data!(datagraph, node_name1, node_name2, edge_weight, attribute_name)
    add_edge_data!(datagraph, edge, edge_weight, attribute_name)

Add a weight value for the edge between node_name1 and node_name2 in the DataGraph object.
When using the second function, `edge` must be a tuple with two node names. User must pass
an "attribute name" for the given weight. All other edges that do not have an edge_weight
value defined for that attribute name default to a value of zero.
"""
function add_edge_data!(dg::DataGraph, node1::Any, node2::Any, edge_weight::T, attribute::String) where {T <: Real}
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
        new_col = fill(0, (length(edges), 1))
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

function add_edge_data!(dg::DataGraph, edge::Tuple{Any, Any}, edge_weight::T, attribute::String) where {T <: Real}
    add_edge_data!(dg, edge[1], edge[2], edge_weight, attribute)
end

"""
    adjacency_matrix(datagraph)
    adjacency_matrix(datadigraph)

Return the adjacency matrix of a DataGraph object
"""
function adjacency_matrix(dg::D) where {D <: DataGraphUnion}
    am = Graphs.LinAlg.adjacency_matrix(dg.g)
    return am
end
