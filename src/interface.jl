
"""
    get_node_data(dg::D) where {D <: DataGraphUnion}

Returns the `data` object from a DataGraph's or DataDiGraph's `NodeData`
"""
function get_node_data(dg::D) where {D <: DataGraphUnion}
    return dg.node_data.data
end

"""
    get_edge_data(dg::D) where {D <: DataGraphUnion}

Returns the `data` object from a DataGraph's or DataDiGraph's `EdgeData`
"""
function get_edge_data(dg::D) where {D <: DataGraphUnion}
    return dg.edge_data.data
end

"""
    get_node_attributes(dg::D) where {D <: DataGraphUnion}

Returns the list of attributes contained in the `NodeData` of `dg`
"""
function get_node_attributes(dg::D) where {D <: DataGraphUnion}
    return dg.node_data.attributes
end

"""
    get_edge_attributes(dg::D) where {D <: DataGraphUnion}

Returns the list of attributes contained in the `EdgeData` of `dg`
"""
function get_edge_attributes(dg::D) where {D <: DataGraphUnion}
    return dg.edge_data.attributes
end

"""
    has_node(datagraph, node)
    has_node(datadigraph, node)

returns `true` if `node` is in the graph. Else return false
"""
function has_node(dg::D, node::Any) where {D <: DataGraphUnion}
    if node in dg.nodes
        return true
    else
        return false
    end
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


"""
    adjacency_matrix(datagraph)
    adjacency_matrix(datadigraph)

Return the adjacency matrix of a DataGraph object
"""
function adjacency_matrix(dg::D) where {D <: DataGraphUnion}
    am = Graphs.LinAlg.adjacency_matrix(dg.g)
    return am
end

"""
    add_node_attribute!(datagraph, attribute, default_weight = 0.0)
    add_node_attribute!(datadigraph, attribute, default_weight = 0.0)

Add a column filled with `default_weight` to the `node_data` matrix with the name `attribute`.
If `attribute` already exists in the node data, an error is thrown.
"""
function add_node_attribute!(dg::D, attribute::String, default_weight = 0.0) where {D <: DataGraphUnion}
    if attribute in dg.node_data.attributes
        error("attribute $attribute already exists")
    end

    node_data = get_node_data(dg)
    nodes = dg.nodes

    new_col = fill(default_weight, (length(nodes,), 1))

    node_data = hcat(node_data, new_col)
    push!(dg.node_data.attributes, attribute)
    dg.node_data.attribute_map[attribute] = length(dg.node_data.attributes)

    dg.node_data.data = node_data

    return true
end

"""
    add_edge_attribute!(datagraph, attribute, default_weight = 0.0)
    add_edge_attribute!(datadigraph, attribute, default_weight = 0.0)

Add a column filled with `default_weight` to the `edge_data` matrix with the name `attribute`.
If `attribute` already exists in the edge data, an error is thrown.
"""
function add_edge_attribute!(dg::D, attribute::String, default_weight = 0) where {D <: DataGraphUnion}
    if attribute in dg.edge_data.attributes
        error("attribute $attribute already exists")
    end

    edge_data = get_edge_data(dg)
    edges = dg.edges

    new_col = fill(default_weight, (length(edges), 1))

    edge_data = hcat(edge_data, new_col)
    push!(dg.edge_data.attributes, attribute)
    dg.edge_data.attribute_map[attribute] = length(dg.edge_data.attributes)

    dg.edge_data.data = edge_data

    return true
end
