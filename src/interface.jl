
"""
    get_node_data(dg::D) where {D <: DataGraphUnion}

Returns the `data` object from a DataGraph's or DataDiGraph's `NodeData`
"""
function get_node_data(
    dg::D
) where {D <: DataGraphUnion}
    return dg.node_data.data
end

"""
    get_edge_data(dg::D) where {D <: DataGraphUnion}

Returns the `data` object from a DataGraph's or DataDiGraph's `EdgeData`
"""
function get_edge_data(
    dg::D
) where {D <: DataGraphUnion}
    return dg.edge_data.data
end

"""
    get_graph_data(dg::D) where {D <: DataGraphUnion}

Returns the `data` object from a DataGraph's or DataDiGraph's `GraphData`
"""
function get_graph_data(
    dg::D
) where {D <: DataGraphUnion}
    return dg.graph_data.data
end

"""
    get_node_attributes(dg::D) where {D <: DataGraphUnion}

Returns the list of attributes contained in the `NodeData` of `dg`
"""
function get_node_attributes(
    dg::D
) where {D <: DataGraphUnion}
    return dg.node_data.attributes
end

"""
    get_edge_attributes(dg::D) where {D <: DataGraphUnion}

Returns the list of attributes contained in the `EdgeData` of `dg`
"""
function get_edge_attributes(
    dg::D
) where {D <: DataGraphUnion}
    return dg.edge_data.attributes
end

"""
    get_graph_attributes(dg::D) where {D <: DataGraphUnion}

Returns the list of attributes contained in the `GraphData` of `dg`
"""
function get_graph_attributes(
    dg::D
) where {D <: DataGraphUnion}
    return dg.graph_data.attributes
end

"""
    has_node(datagraph, node)
    has_node(datadigraph, node)

returns `true` if `node` is in the graph. Else return false
"""
function has_node(
    dg::D,
    node::T
) where {D <: DataGraphUnion, T <: Any}
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
function ne(
    dg::D
) where {D <: DataGraphUnion}
    return length(dg.edges)
end

"""
    nn(dg::D) where {D <: DataGraphUnion}
    nv(dg::D) where {D <: DataGraphUnion}

Returns the number of nodes (vertices) in a DataGraph or DataDiGraph
"""
function nn(
    dg::D
) where {D <: DataGraphUnion}
    return length(dg.nodes)
end

function nv(
    dg::D
) where {D <: DataGraphUnion}
    return nn(dg)
end

"""
    adjacency_matrix(datagraph)
    adjacency_matrix(datadigraph)

Return the adjacency matrix of a DataGraph object
"""
function adjacency_matrix(
    dg::D
) where {D <: DataGraphUnion}

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

    if length(dg.node_data.attributes) == 0
        M = typeof(node_data)
        node_data = M(undef, length(nodes), 0)
    end

    new_col = fill(default_weight, (length(nodes), 1))

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

    if length(dg.edge_data.attributes) == 0
        M = typeof(edge_data)
        edge_data = M(undef, length(edges), 0)
    end

    new_col = fill(default_weight, (length(edges), 1))

    edge_data = hcat(edge_data, new_col)
    push!(dg.edge_data.attributes, attribute)
    dg.edge_data.attribute_map[attribute] = length(dg.edge_data.attributes)

    dg.edge_data.data = edge_data

    return true
end

"""
    rename_node_attribute!(dg::D, attribute, new_name) where {D <: DataGraphUnion}

Rename the node data `attribute` as `new_name`. If `attribute` is not defined, returns an error.
"""
function rename_node_attribute!(dg::D, attribute::String, new_name::String) where {D <: DataGraphUnion}
    node_attributes = dg.node_data.attributes
    attribute_map = dg.node_data.attribute_map

    println(attribute, node_attributes, attribute in node_attributes)
    if !(attribute in node_attributes)
        error("$attribute is not in the node data attributes")
    end

    attribute_loc = attribute_map[attribute]
    delete!(attribute_map, attribute)
    deleteat!(node_attributes, attribute_loc)

    insert!(node_attributes, attribute_loc, new_name)
    attribute_map[new_name] = attribute_loc

    dg.node_data.attributes = node_attributes
    dg.node_data.attribute_map = attribute_map
end

"""
    rename_edge_attribute!(dg::D, attribute, new_name) where {D <: DataGraphUnion}

Rename the edge data `attribute` as `new_name`. If `attribute` is not defined, returns an error.
"""
function rename_edge_attribute!(dg::D, attribute::String, new_name::String) where {D <: DataGraphUnion}
    edge_attributes = dg.edge_data.attributes
    attribute_map = dg.edge_data.attribute_map

    if !(attribute in edge_attributes)
        error("$attribute is not in the edge data attributes")
    end

    attribute_loc = attribute_map[attribute]
    delete!(attribute_map, attribute)
    deleteat!(edge_attributes, attribute_loc)

    insert!(edge_attributes, attribute_loc, new_name)
    attribute_map[new_name] = attribute_loc

    dg.edge_data.attributes = edge_attributes
    dg.edge_data.attribute_map = attribute_map
end

"""
    rename_graph_attribute!(dg::D, attribute, new_name) where {D <: DataGraphUnion}

Rename the graph data `attribute` as `new_name`. If `attribute` is not defined, returns an error.
"""
function rename_graph_attribute!(dg::D, attribute::String, new_name::String) where {D <: DataGraphUnion}
    graph_attributes = dg.graph_data.attributes
    attribute_map = dg.graph_data.attribute_map

    if !(attribute in graph_attributes)
        error("$attribute is not in the graph data attributes")
    end

    attribute_loc = attribute_map[attribute]
    delete!(attribute_map, attribute)
    deleteat!(graph_attributes, attribute_loc)

    insert!(graph_attributes, attribute_loc, new_name)
    attribute_map[new_name] = attribute_loc
    dg.graph_data.attributes = graph_attributes
    dg.graph_data.attribute_map = attribute_map
end

"""
    add_graph_data!(dg::D, weight, attribute) where {D <: DataGraphUnion}

Add the value `weight` to the graph under the name attribute. If the attribute is already
defined, the value will be reset to `weight`.
"""
function add_graph_data!(dg::D, weight::Any, attribute::String) where {D <: DataGraphUnion}
    graph_data = dg.graph_data.data
    graph_attributes = dg.graph_data.attributes
    attribute_map = dg.graph_data.attribute_map

    if attribute in graph_attributes
        graph_data[attribute_map[attribute]] = weight
    else
        push!(graph_attributes, attribute)
        push!(graph_data, weight)
        attribute_map[attribute] = length(graph_attributes)
    end
end
