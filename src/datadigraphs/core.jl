"""
    DataDiGraph{T, T1, T2, M1, M2}()
    DataDiGraph()

Constructor for initializing and empty DataDiGraph object. Datatypes are as follows: T is the
integer type for indexing, T1 and T2 are the data type in the node and edge data respectively,
and M1 <: AbstractMatrix{T1} corresponds to the node data and M2 <: AbstractMatrix{T2} corresponds
to the edge data.

When T, T1, T2, M1, and M2 are not defined, the defaults are `Int`, `Float64`, `Float64`,
`Matrix{Float64}`, and `Matrix{Float64}` respectively.
"""
function DataDiGraph{T, T1, T2, T3, M1, M2}() where {T <: Integer, T1, T2, T3, M1 <: Matrix{T1}, M2 <: Matrix{T2}}
    nodes = Vector{Any}()
    edges = Vector{Tuple{T, T}}()

    ne = 0
    fadjlist = Vector{Vector{T}}()
    badjlist = Vector{Vector{T}}()

    node_map = Dict{Any, T}()
    edge_map = Dict{Tuple{T, T}, T}()
    node_attributes = String[]
    edge_attributes = String[]
    graph_attributes = String[]
    node_attribute_map = Dict{String, T}()
    edge_attribute_map = Dict{String, T}()
    graph_attribute_map = Dict{String, T}()
    node_data = M1(undef, 0, 0)
    edge_data = M2(undef, 0, 0)
    graph_data = Vector{T3}()

    g = SimpleDiGraph(ne, fadjlist, badjlist)

    node_data_struct = NodeData(node_attributes, node_attribute_map, node_data)
    edge_data_struct = EdgeData(edge_attributes, edge_attribute_map, edge_data)
    graph_data_struct = GraphData(graph_attributes, graph_attribute_map, graph_data)

    DataDiGraph{T, T1, T2, T3, M1, M2}(
        g, nodes, edges, node_map, edge_map,
        node_data_struct, edge_data_struct, graph_data_struct
    )
end

DataDiGraph() = DataDiGraph{Int, Float64, Float64, Float64, Matrix{Float64}, Matrix{Float64}}()


"""
    DataDiGraph(adjacency_matrix::AbstractMatrix)

Constructor for building a DataDiGraph object from an adjacency matrix.
"""
function DataDiGraph(
    adj_mat::AbstractMatrix{T}
) where {T <: Real}

    dima, dimb = size(adj_mat)
    isequal(dima, dimb) || throw(ArgumentError("Adjacency / distance matrices must be square"))
    LinearAlgebra.issymmetric(adj_mat) || throw(ArgumentError("Adjacency / distance matrices must be symmetric"))

    dg = DataDiGraph()

    maxc = length(adj_mat.colptr)
    @inbounds for c = 1:(maxc - 1)
        for rind = adj_mat.colptr[c]:(adj_mat.colptr[c + 1] - 1)
            isnz = (adj_mat.nzval[rind] != zero(T))
            if isnz
                r = adj_mat.rowval[rind]
                DataGraphs.add_edge!(dg, r, c)
            end
        end
    end
    return dg
end

"""
    add_node!(dg, node_name)

Add the node `node_name` to the DataDiGraph `dg`
"""
function add_node!(
    dg::DataDiGraph,
    node_name::N
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
        push!(dg.g.badjlist, Vector{T}())

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

Add an edge to the DataDiGraph, `dg`. If the nodes are not defined in the graph, they are added to the graph
"""
function add_edge!(
    dg::DataDiGraph,
    node1::N1,
    node2::N2
) where {N1 <: Any, N2 <: Any}

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

    edge = (node1_index, node2_index)

    # If the edge isn't already defined, then add the edge; add to weight arrays too
    if !(edge in edges)
        push!(edges, edge)
        dg.g.ne += 1

        @inbounds node_neighbors = dg.g.fadjlist[node1_index]
        index = searchsortedfirst(node_neighbors, node2_index)
        insert!(node_neighbors, index, node2_index)

        @inbounds node_neighbors = dg.g.badjlist[node2_index]
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

function add_edge!(
    dg::DataDiGraph,
    edge::Tuple
)

    DataGraphs.add_edge!(dg, edge[1], edge[2])
end

"""
    add_edge_data!(datadigraph, node_name1, node_name2, edge_weight, attribute_name)
    add_edge_data!(datadigraph, edge, edge_weight, attribute_name)

Add a weight value for the edge between node_name1 and node_name2 in the DataDiGraph object.
When using the second function, `edge` must be a tuple with two node names. User must pass
an "attribute name" for the given weight. All other edges that do not have an edge_weight
value defined for that attribute name default to a value of zero.
"""
function add_edge_data!(
    dg::DataDiGraph,
    node1::N1,
    node2::N2,
    edge_weight::N3,
    attribute::String="weight"
) where {N1 <: Any, N2 <: Any, N3 <: Any}

    edges         = dg.edges
    attributes    = dg.edge_data.attributes
    edge_map      = dg.edge_map
    node_map      = dg.node_map
    attribute_map = dg.edge_data.attribute_map

    node1_index = node_map[node1]
    node2_index = node_map[node2]

    edge = (node1_index, node2_index)

    if !(edge in edges)
        error("edge does not exist in graph")
    end

    if length(attributes) == 0
        edge_data = Array{eltype(dg.edge_data.data)}(undef, length(edges), 0)
        dg.edge_data.data = edge_data
    end

    if !(attribute in attributes)
        edge_data = dg.edge_data.data
        edge_type = eltype(edge_data)
        # Add new column to node_weight array
        push!(attributes, attribute)
        attribute_map[attribute] = length(attributes)
        new_col = fill(edge_type(0), (length(edges), 1))
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

function add_edge_data!(
    dg::DataDiGraph,
    edge::Tuple,
    edge_weight::N,
    attribute::String = "weight"
) where {N <: Any}
    add_edge_data!(dg, edge[1], edge[2], edge_weight, attribute)
end


function add_edge_dataset!(
    dg::DataDiGraph,
    edge_list::Vector,
    weight_list::Vector,
    attribute::String
)

    edges         = dg.edges
    attributes    = dg.edge_data.attributes
    edge_map      = dg.edge_map
    node_map      = dg.node_map
    attribute_map = dg.edge_data.attribute_map
    edge_data     = get_edge_data(dg)

    if length(edge_list) != length(weight_list)
        error("edge list and weight list have different lengths")
    end

    if !(all(x -> (node_map[x[1]], node_map[x[2]]) in edges, edge_list))
        error("edge(s) in edge_list does not exist in datagraph")
    end

    if length(attributes) == 0
        edge_data = Array{eltype(dg.edge_data.data)}(undef, length(edges), 0)
        dg.edge_data.data = edge_data
    end

    if !(attribute in attributes)
        edge_data = dg.edge_data.data
        T = eltype(edge_data)
        # Add new column to node_weight array
        push!(attributes, attribute)
        attribute_map[attribute] = length(attributes)
        new_col = fill(T(0), (length(edges), 1))
        edge_data = hcat(edge_data, new_col)

        for i in 1:length(edge_list)
            edge = (node_map[edge_list[i][1]], node_map[edge_list[i][2]])
            edge_data[edge_map[edge], attribute_map[attribute]] = weight_list[i]
        end
        dg.edge_data.data = edge_data
        return true
    else
        for i in 1:length(edge_list)
            edge = (node_map[edge_list[i][1]], node_map[edge_list[i][2]])
            edge_data[edge_map[edge], attribute_map[attribute]] = weight_list[i]
        end
        return true
    end
end

function add_edge_dataset!(
    dg::DataDiGraph,
    weight_list::Vector,
    attribute::String
)

    edges         = dg.edges
    attributes    = dg.edge_data.attributes
    edge_map      = dg.edge_map
    node_map      = dg.node_map
    attribute_map = dg.edge_data.attribute_map
    edge_data     = get_edge_data(dg)

    if length(edges) != length(weight_list)
        error("weight list is not the same length as number of edges")
    end

    if length(attributes) == 0
        edge_data = Array{eltype(dg.edge_data.data)}(undef, length(edges), 0)
        dg.edge_data.data = edge_data
    end

    if !(attribute in attributes)
        edge_data = dg.edge_data.data
        T = eltype(edge_data)
        # Add new column to node_weight array
        push!(attributes, attribute)
        attribute_map[attribute] = length(attributes)
        new_col = fill(T(0), (length(edges), 1))
        edge_data = hcat(edge_data, new_col)

        for i in 1:length(edges)
            edge_data[i, attribute_map[attribute]] = weight_list[i]
        end
        dg.edge_data.data = edge_data
        return true
    else
        for i in 1:length(edges)
            edge_data[i, attribute_map[attribute]] = weight_list[i]
        end
        return true
    end
end

function add_edge_dataset!(
    dg::DataDiGraph,
    weight_dict::Dict,
    attribute::String
)

    edges         = dg.edges
    attributes    = dg.edge_data.attributes
    edge_map      = dg.edge_map
    node_map      = dg.node_map
    attribute_map = dg.edge_data.attribute_map
    edge_data     = get_edge_data(dg)

    edge_keys = keys(weight_dict)

    if !(all(x -> (node_map[x[1]], node_map[x[2]]) in edges, edge_keys))
        error("edge key(s) in weight dict contains edges not in datagraph")
    end

    if length(attributes) == 0
        edge_data = Array{eltype(dg.edge_data.data)}(undef, length(edges), 0)
        dg.edge_data.data = edge_data
    end

    if !(attribute in attributes)
        edge_data = dg.edge_data.data
        T = eltype(edge_data)
        # Add new column to node_weight array
        push!(attributes, attribute)
        attribute_map[attribute] = length(attributes)
        new_col = fill(T(0), (length(edges), 1))
        edge_data = hcat(edge_data, new_col)

        for i in edge_keys
            edge_index = edge_map[(node_map[i[1]], node_map[i[2]])]
            edge_data[edge_index, attribute_map[attribute]] = weight_dict[i]
        end

        dg.edge_data.data = edge_data
        return true
    else
        for i in edge_keys
            edge_index = edge_map[(node_map[i[1]], node_map[i[2]])]
            edge_data[edge_index, attribute_map[attribute]] = weight_dict[i]
        end
        return true
    end
end
