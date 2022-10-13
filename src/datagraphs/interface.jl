function get_node_data(dg::DataGraph, node::Any, attribute::String=dg.node_data.attributes[1])
    node_map  = dg.node_map
    node_data = dg.node_data
    attribute_map = node_data.attribute_map

    return node_data.data[node_map[node], attribute_map[attribute]]
end

function get_edge_data(dg::DataGraph, node1, node2, attribute::String=dg.edge_data.attributes[1])
    edge_map  = dg.edge_map
    edge_data = dg.edge_data
    node_map  = dg.node_data
    attribute_map = edge_data.attribute_map

    edge = _get_edge(node_map[node1], node_map[node2])

    return edge_data.data[edge_map[edge], attribute_map[attribute]]
end

function get_edge_data(dg::DataGraph, edge_tuple::Tuple{Any, Any}, attribute::String=dg.edge_data.attributes[1])
    edge_map  = dg.edge_map
    edge_data = dg.edge_data
    node_map  = dg.node_data
    attribute_map = edge_data.attribute_map

    edge = _get_edge(node_map[edge_tuple[1]], node_map[edge_tuple[2]])

    return edge_data.data[edge_map[edge], attribute_map[attribute]]
end

function get_node_data(dg::DataGraphUnion)
    return dg.node_data
end

function get_edge_data(dg::DataGraphUnion)
    return dg.edge_data
end

function ne(dg::DataGraphUnion)
    length(dg.edges)
end

function nn(dg::DataGraphUnion)
    length(dg.nodes)
end

function nv(dg::DataGraphUnion)
    nn(dg)
end


# Add set node_data
# Add set edge_data
# Add get_node positions
# Add get_edge positions
# Add number nodes
# Add number edges
# Consider changing interface functions; some functions apply to DataGraphUnions, and I should consider where to put these
