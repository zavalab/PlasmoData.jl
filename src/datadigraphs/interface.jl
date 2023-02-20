"""
    get_node_data(datagraph, node_name, attribute_name)

Returns the value of attribute name on the given node
"""
function get_node_data(
    dg::DataDiGraph,
    node::N,
    attribute::String=dg.node_data.attributes[1]
) where {N <: Any}

    node_map  = dg.node_map
    node_data = dg.node_data
    attribute_map = node_data.attribute_map

    return node_data.data[node_map[node], attribute_map[attribute]]
end

"""
    get_edge_data(datagraph, node_name1, node_name2, attribute_name)
    get_edge_data(datagraph, edge, attribute_name)

Returns the value of attribute name on the edge between `node_name1` and `node_name2`. `edge` is
a tuple containing `node_name1` and `node_name2`.
"""
function get_edge_data(
    dg::DataDiGraph,
    node1::N1,
    node2::N2,
    attribute::String=dg.edge_data.attributes[1]
) where {N1 <: Any, N2 <: Any}

    edge_map  = dg.edge_map
    edge_data = dg.edge_data
    node_map  = dg.node_map
    attribute_map = edge_data.attribute_map

    edge = (node_map[node1], node_map[node2])

    if !(edge in dg.edges)
        error("Edge $((node1, node2)) does not exist")
    end

    return edge_data.data[edge_map[edge], attribute_map[attribute]]
end

function get_edge_data(
    dg::DataDiGraph,
    edge_tuple::Tuple,
    attribute::String=dg.edge_data.attributes[1]
)
    return get_edge_data(dg, edge_tuple[1], edge_tuple[2], attribute)
end

"""
    has_edge(datagraph, node1, node2)

Return `true` if there is an edge going from `node1` to `node2` in `datadigraph`. Else return false
"""
function has_edge(
    dg::DataDiGraph,
    node1::N1,
    node2::N2
) where {N1 <: Any, N2 <: Any}

    if !(node1 in dg.nodes)
        error("$node1 not defined in graph")
    elseif !(node2 in dg.nodes)
        error("$node2 not defined in graph")
    end

    node_map = dg.node_map

    if (node_map[node1], node_map[node2]) in dg.edges
        return true
    else
        return false
    end
end
