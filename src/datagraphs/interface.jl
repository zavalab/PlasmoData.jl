function get_node_data(dg::DataGraph, node::Any, weight::String=dg.node_data.attributes[1])
    node_map  = dg.node_map
    node_data = dg.node_data
    attribute_map = node_data.attribute_map

    return node_data.data[node_map[node], attribute_map[weight]]
end

function get_edge_data(dg::DataGraph, node1, node2, weight::String=dg.edge_data.attributes[1])
    edge_map  = dg.edge_map
    edge_data = dg.edge_data
    node_map  = dg.node_data
    attribute_map = edge_data.attribute_map

    edge = _get_edge(node_map[node1], node_map[node2])

    return edge_data.data[edge_map[edge], attribute_map[weight]]
end

function get_edge_data(dg::DataGraph, edge_tuple::Tuple{Any, Any}, weight::String=dg.edge_data.attributes[1])
    edge_map  = dg.edge_map
    edge_data = dg.edge_data
    node_map  = dg.node_data
    attribute_map = edge_data.attribute_map

    edge = _get_edge(node_map[edge_tuple[1]], node_map[edge_tuple[2]])

    return edge_data.data[edge_map[edge], attribute_map[weight]]
end

function get_node_data(dg::DataGraph)
    return dg.node_data
end

function get_edge_data(dg::DataGraph)
    return dg.edge_data
end
