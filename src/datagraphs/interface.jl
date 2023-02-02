"""
    get_node_data(datagraph, node_name, attribute_name)

Returns the value of attribute name on the given node
"""
function get_node_data(dg::DataGraph, node::Any, attribute::String=dg.node_data.attributes[1])
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
function get_edge_data(dg::DataGraph, node1, node2, attribute::String=dg.edge_data.attributes[1])
    edge_map  = dg.edge_map
    edge_data = dg.edge_data
    node_map  = dg.node_map
    attribute_map = edge_data.attribute_map

    edge = _get_edge(node_map[node1], node_map[node2])

    if !(edge in dg.edges)
        error("Edge $((node1, node2)) does not exist")
    end

    return edge_data.data[edge_map[edge], attribute_map[attribute]]
end

function get_edge_data(dg::DataGraph, edge_tuple::Tuple{Any, Any}, attribute::String=dg.edge_data.attributes[1])

    return get_edge_data(dg, edge_tuple[1], edge_tuple[2], attribute)
end

"""
    get_node_data(dg::D) where {D <: DataGraphUnion}

Returns the `NodeData` object from a DataGraph or DataDiGraph
"""
function get_node_data(dg::D) where {D <: DataGraphUnion}
    return dg.node_data.data
end

"""
    get_edge_data(dg::D) where {D <: DataGraphUnion}

Returns the `EdgeData` object from a DataGraph or DataDiGraph
"""
function get_edge_data(dg::D) where {D <: DataGraphUnion}
    return dg.edge_data.data
end

"""
    ne(dg::D) where {D <: DataGraphUnion}

Returns the number of edges in a DataGraph or DataDiGraph
"""
function ne(dg::D) where {D <: DataGraphUnion}
    length(dg.edges)
end

"""
    nn(dg::D) where {D <: DataGraphUnion}
    nv(dg::D) where {D <: DataGraphUnion}

Returns the number of nodes (vertices) in a DataGraph or DataDiGraph
"""
function nn(dg::D) where {D <: DataGraphUnion}
    length(dg.nodes)
end

function nv(dg::D) where {D <: DataGraphUnion}
    nn(dg)
end


# Add set node_data
# Add set edge_data
# Add get_node positions
# Add get_edge positions
# Add number nodes
# Add number edges
# Consider changing interface functions; some functions apply to DataGraphUnions, and I should consider where to put these
