function Graphs.connected_components(
    dg::D
) where {D <: DataGraphUnion}
    connected_components_list = Graphs.connected_components(dg.g)

    nodes  = dg.nodes
    components = []

    for i in connected_components_list
        push!(components, nodes[i])
    end

    return components
end

function Graphs.is_connected(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.is_connected(dg.g)
end

function Graphs.common_neighbors(
    dg::D,
    node1::Any,
    node2::Any
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    cn = Graphs.common_neighbors(dg.g, node_map[node1], node_map[node2])

    return index_to_nodes(dg, cn)
end

function Graphs.common_neighbors(
    dg::D,
    node1::Int,
    node2::Int
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    cn = Graphs.common_neighbors(dg.g, node_map[node1], node_map[node2])

    return index_to_nodes(dg, cn)
end

function Graphs.neighbors(
    dg::D,
    node::Any
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    neighbor_list = Graphs.neighbors(dg.g, node_map[node])

    return index_to_nodes(dg, neighbor_list)
end

function Graphs.neighbors(
    dg::D,
    node::Int
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    neighbor_list = Graphs.neighbors(dg.g, node_map[node])

    return index_to_nodes(dg, neighbor_list)
end

function Graphs.core_number(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.core_number(dg.g)
end

function Graphs.k_core(
    dg::D,
    k = -1
) where {D <: DataGraphUnion}

    k_core_index = Graphs.k_core(dg.g, k)
    return dg.nodes[k_core_index]
end

function Graphs.k_shell(
    dg::D,
    k = -1
) where {D <: DataGraphUnion}

    k_shell_index = Graphs.k_shell(dg.g, k)
    return dg.nodes[k_shell_index]
end

function Graphs.k_crust(
    dg::D,
    k = -1
) where {D <: DataGraphUnion}

    k_crust_index = Graphs.k_crust(dg.g, k)
    return dg.nodes[k_crust_index]
end

function Graphs.eccentricity(
    dg::D,
    node::Any
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    return Graphs.eccentricity(dg.g, node_map[node])
end

function Graphs.eccentricity(
    dg::D,
    node::Int
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    return Graphs.eccentricity(dg.g, node_map[node])
end

function Graphs.diameter(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.diameter(dg.g)
end

function Graphs.periphery(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.periphery(dg.g)
end

function Graphs.radius(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.radius(dg.g)
end

function Graphs.center(
    dg::D
) where {D <: DataGraphUnion}
    return index_to_nodes(dg, Graphs.center(dg.g))
end

function Graphs.cycle_basis(
    dg::D
) where {D <: DataGraphUnion}

    numbered_cycles = Graphs.cycle_basis(dg.g)

    nodes  = dg.nodes
    cycles = []

    for i in numbered_cycles
        push!(cycles, nodes[i])
    end

    return cycles
end

function Graphs.indegree(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.indegree(dg.g)
end

function Graphs.indegree(
    dg::D,
    node::T
) where {D <: DataGraphUnion, T <: Any}

    node_map = dg.node_map
    return Graphs.indegree(dg.g, node_map[node])
end

function Graphs.indegree(
    dg::D,
    node::Int
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    return Graphs.indegree(dg.g, node_map[node])
end

function Graphs.outdegree(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.outdegree(dg.g)
end

function Graphs.outdegree(
    dg::D,
    node::T
 ) where {D <: DataGraphUnion, T <: Any}

    node_map = dg.node_map
    return Graphs.outdegree(dg.g, node_map[node])
end

function Graphs.outdegree(
    dg::D,
    node::Int
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    return Graphs.outdegree(dg.g, node_map[node])
end

function Graphs.degree(
    dg::D
) where {D <: DataGraphUnion}
    return Graphs.degree(dg.g)
end

function Graphs.degree(
    dg::D,
    node::T
) where {D <: DataGraphUnion, T <: Any}

    node_map = dg.node_map
    return Graphs.degree(dg.g, node_map[node])
end

function Graphs.degree(
    dg::D,
    node::Int
) where {D <: DataGraphUnion}

    node_map = dg.node_map
    return Graphs.degree(dg.g, node_map[node])
end

function Graphs.degree_histogram(
    dg::D
) where {D <: DataGraphUnion}
    return degree_histogram(dg.g)
end

function Graphs.degree_centrality(
    dg::D
) where {D <: DataGraphUnion}
    return degree_centrality(dg.g)
end

"""
    average_degree(datagraph)

Returns the average degree for `datagraph`
"""
function average_degree(
    dg::D
) where {D <: DataGraphUnion}

    degrees = Graphs.degree(dg)
    return sum(degrees) / length(degrees)
end

"""
    Graphs.has_path(datagraph, src_node, dst_node)

Returns true if a path exists in the `datagraph` between `src_node` to `dst_node`. Else returns false
"""
function has_path(
    dg::D,
    src_node::T1,
    dst_node::T2
) where {D <: DataGraphUnion, T1 <: Any, T2 <: Any}

    node_map = dg.node_map
    nodes    = dg.nodes

    if !(src_node in nodes && dst_node in nodes)
        error("User has passed a node that does not exist in the DataGraph")
    end

    src_index = node_map[src_node]
    dst_index = node_map[dst_node]

    return Graphs.has_path(dg.g, src_index, dst_index)
end

"""
    Graphs.has_path(datagraph, src_node, intermediate_node, dst_node)

Returns true if a path exists in the `datagraph` between `src_node` and `dst_node` which
passes through the `intermediate node`. Else returns false
"""
function has_path(
    dg::D,
    src_node::T1,
    intermediate_node::T2,
    dst_node::T3
) where {D <: DataGraphUnion, T1 <: Any, T2 <: Any, T3 <: Any}

    node_map = dg.node_map
    nodes    = dg.nodes

    if !(src_node in nodes && intermediate_node in nodes && dst_node in nodes)
        error("User has passed a node that does not exist in the DataGraph")
    end

    src_index = node_map[src_node]
    int_index = node_map[intermediate_node]
    dst_index = node_map[dst_node]

    if Graphs.has_path(dg.g, src_index, int_index) && Graphs.has_path(dg.g, int_index, dst_index)
        return true
    else
        return false
    end
end

"""
    get_path(datagraph, src_node, dst_node; algorithm = "Dijkstra")

Returns the shortest path in the `datagraph` between `src_node` and `dst_node`.
Shortest path is computed by Dijkstra's algorithm

`algorithm` is a string key word. Options are limited to "Dijkstra", "BellmanFord"
"""
function get_path(
    dg::D,
    src_node::T1,
    dst_node::T2;
    algorithm::String = "Dijkstra"
) where {D <: DataGraphUnion, T1 <: Any, T2 <: Any}

    node_map = dg.node_map
    nodes    = dg.nodes

    if !(src_node in nodes && dst_node in nodes)
        error("User has passed a node that does not exist in the DataGraph")
    end

    src_index = node_map[src_node]
    dst_index = node_map[dst_node]

    if algorithm == "Dijkstra"
        path_state = Graphs.dijkstra_shortest_paths(dg.g, [src_index])
    elseif algorithm == "BellmanFord"
        path_state = Graphs.bellman_ford_shortest_paths(dg.g, [src_index])
    else
        error("$algorithm is not a supported algorithm option")
    end

    index_path = Graphs.enumerate_paths(path_state, dst_index)

    if length(index_path) == 0
        println("Path between nodes does not exist")
        return []
    end

    path = Vector{Any}(undef, length(index_path))

    for i in 1:length(index_path)
        path[i] = nodes[index_path[i]]
    end

    return path
end

"""
    get_path(datagraph, src_node, intermediate_node, dst_node; algorithm = "Dijkstra")

Returns the shortest path in the `datagraph` between `src_node` and `dst_node`
which passes through `intermediate node`.

`algorithm` is a string key word. Options are limited to "Dijkstra", "BellmanFord"
"""
function get_path(
    dg::D,
    src_node::T1,
    intermediate_node::T2,
    dst_node::T3;
    algorithm = "Dijkstra"
) where {D <: DataGraphUnion, T1 <: Any, T2 <: Any, T3 <: Any}

    node_map = dg.node_map
    nodes    = dg.nodes

    if !(src_node in nodes && intermediate_node in nodes && dst_node in nodes)
        error("User has passed a node that does not exist in the DataGraph")
    end

    src_index = node_map[src_node]
    int_index = node_map[intermediate_node]
    dst_index = node_map[dst_node]

    if algorithm == "Dijkstra"
        path_state_src = Graphs.dijkstra_shortest_paths(dg.g, [src_index])
        path_state_int = Graphs.dijkstra_shortest_paths(dg.g, [int_index])
    elseif algorithm == "BellmanFord"
        path_state_src = Graphs.bellman_ford_shortest_paths(dg.g, [src_index])
        path_state_int = Graphs.bellman_ford_shortest_paths(dg.g, [int_index])
    else
        error("$algorithm is not a supported algorithm option")
    end

    index_path_to_int = Graphs.enumerate_paths(path_state_src, int_index)

    index_path_to_dst = Graphs.enumerate_paths(path_state_int, dst_index)

    if length(index_path_to_int) == 0 || length(index_path_to_dst) == 0
        println("Path through intermediate node does not exist")
        return []
    end

    path = Vector{Any}(undef, (length(index_path_to_int) + length(index_path_to_dst) - 1))
    nodes = dg.nodes

    path_to_int_len = length(index_path_to_int)
    path_to_dst_len = length(index_path_to_dst)

    for i in 1:path_to_int_len
        path[i] = nodes[index_path_to_int[i]]
    end

    for i in 2:path_to_dst_len
        path[i + path_to_int_len - 1] = nodes[index_path_to_dst[i]]
    end

    return path
end

"""
    nodes_to_index(datagraph, node_list)

From a list of nodes in the `datagraph`, return a list of their corresponding integer indices
"""
function nodes_to_index(
    dg::D,
    node_list::Vector
) where {D <: DataGraphUnion}

    nodes = dg.nodes
    node_map = dg.node_map

    if !(all(x -> x in nodes, node_list))
        error("Node(s) in node_list are not in DataGraph")
    end

    T = eltype(dg)

    index_list = Vector{T}(undef, length(node_list))
    for i in 1:length(index_list)
        index_list[i] = node_map[node_list[i]]
    end

    return index_list
end

"""
    index_to_nodes(datagraph, index_list)

From a list of integer indeices, return a list of corresponding nodes in the `datagraph`
"""
function index_to_nodes(
    dg::D,
    index_list::Vector
) where {D <: DataGraphUnion}

    nodes = dg.nodes

    if !(all(x -> x <= length(nodes), index_list))
        error("Value(s) in index_list are larger than the number of nodes in DataGraph")
    end

    node_list = Vector{Any}(undef, length(index_list))
    for i in 1:length(node_list)
        node_list[i] = nodes[index_list[i]]
    end

    return node_list
end

"""
    order_edges!(dg) where {D <: DataGraphUnion}

Arranges in place the edges of `dg` so that they follow the order of `dg.nodes`. For `DataGraph`s, this
means all edges connected to `dg.nodes[1]` are ordered first, and so on. For `DataDiGraph`s, this
means that all edges originating at `dg.nodes[1]` are ordered first, and so on for `length(dg.nodes)`
"""
function order_edges!(
    dg::D
) where {D <: DataGraphUnion}

    edges = dg.edges
    edge_map = dg.edge_map
    edge_order = _get_edge_order(dg)

    new_edges = edges[edge_order]

    for (i, edge) in enumerate(new_edges)
        edge_map[edge] = i
    end

    if length(dg.edge_data.attributes) > 0
        edge_data = get_edge_data(dg)
        dg.edge_data.data = edge_data[edge_order, :]
    end

    dg.edges = new_edges
end

"""
    get_ordered_edge_data(dg::D) where {D <: DataGraphUnion}

Returns the ordered edge data matrix. For `DataGraph`s, this means all edges connected to
`dg.nodes[1]` are ordered first, and so on. For `DataDiGraph`s, this means that all edges
originating at `dg.nodes[1]` are ordered first, and so on for `length(dg.nodes)`
"""
function get_ordered_edge_data(
    dg::D
) where {D <: DataGraphUnion}

    edge_order = _get_edge_order(dg)

    return get_edge_data(dg)[edge_order, :]
end

"""
    get_ordered_edge_data(dg::D, attribute_list) where {D <: DataGraphUnion}

Returns the ordered edge data matrix for the attributes in `attribute_list`.
For `DataGraph`s, this means all edges connected to `dg.nodes[1]` are ordered first,
and so on. For `DataDiGraph`s, this means that all edges originating at `dg.nodes[1]`
 are ordered first, and so on for `length(dg.nodes)`
"""
function get_ordered_edge_data(
    dg::D,
    attribute_list::Vector{String}
) where {D <: DataGraphUnion}

    edge_order = _get_edge_order(dg)

    return get_edge_data(dg, attribute_list)[edge_order, :]
end

"""
    get_ordered_edge_data(dg::D, attribute::String) where {D <: DataGraphUnion}

Returns the ordered edge data vector for `attribute`.
For `DataGraph`s, this means all edges connected to `dg.nodes[1]` are ordered first,
and so on. For `DataDiGraph`s, this means that all edges originating at `dg.nodes[1]`
 are ordered first, and so on for `length(dg.nodes)`
"""
function get_ordered_edge_data(
    dg::D,
    attribute::String
) where {D <: DataGraphUnion}

    edge_order = _get_edge_order(dg)

    return get_edge_data(dg, attribute)[edge_order]
end

function _add_data_column!(Data, attribute, default_weight)
    M = typeof(Data.data)
    dim1 = size(Data.data, 1)
    push!(Data.attributes, attribute)
    Data.attribute_map[attribute] = length(Data.attributes)
    new_col = M(fill(default_weight, dim1, 1))

    Data.data = hcat(Data.data, new_col)
end

function _get_edge_order(
    dg::DataGraph
)

    T = eltype(dg)

    edge_order = [T(1) for i in 1:length(dg.edges)]
    edge_map   = dg.edge_map

    current_index = 1
    for i in 1:length(dg.nodes)
        fadjlist = dg.g.fadjlist[i]
        next_index = findfirst(x -> x > i, fadjlist)
        if next_index != nothing
            neighbor_list = fadjlist[next_index:length(fadjlist)]
            for j in neighbor_list
                edge_order[current_index] = edge_map[(i, j)]
                current_index += 1
            end
        end
    end

    return edge_order
end

function _get_edge_order(
    dg::DataDiGraph
)

    T = eltype(dg)

    edge_order = [T(1) for i in 1:length(dg.edges)]
    edge_map   = dg.edge_map

    current_index = 1
    for i in 1:length(dg.nodes)
        fadjlist = dg.g.fadjlist[i]
        for j in fadjlist
            edge_order[current_index] = edge_map[(i, j)]
            current_index += 1
        end
    end

    return edge_order
end
