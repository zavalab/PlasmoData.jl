function Graphs.connected_components(dg::D) where {D <: DataGraphUnion}
    connected_components_list = Graphs.connected_components(dg.g)

    nodes  = dg.nodes
    components = []

    for i in connected_components_list
        push!(components, nodes[i])
    end

    return components
end

function Graphs.is_connected(dg::D) where {D <: DataGraphUnion}
    return Graphs.is_connected(dg.g)
end

function Graphs.common_neighbors(dg::D, node1, node2) where {D <: DataGraphUnion}
    node_map = dg.node_map
    return Graphs.common_neighbors(dg.g, node_map[node1], node_map[node2])
end

function Graphs.neighbors(dg::D, node) where {D <: DataGraphUnion}
    node_map = dg.node_map
    return Graphs.neighbors(dg.g, node_map[node])
end

function Graphs.core_number(dg::D) where {D <: DataGraphUnion}
    return Graphs.core_number(dg.g)
end

function Graphs.k_core(dg::D, k = -1) where {D <: DataGraphUnion}
    k_core_index = Graphs.k_core(dg.g, k)
    return dg.nodes[k_core_index]
end

function Graphs.k_shell(dg::D, k = -1) where {D <: DataGraphUnion}
    k_shell_index = Graphs.k_shell(dg.g, k)
    return dg.nodes[k_shell_index]
end

function Graphs.k_crust(dg::D, k = -1) where {D <: DataGraphUnion}
    k_crust_index = Graphs.k_crust(dg.g, k)
    return dg.nodes[k_crust_index]
end

function Graphs.eccentricity(dg::D, node) where {D <: DataGraphUnion}
    node_map = dg.node_map
    return Graphs.eccentricity(dg.g, node_map[node])
end

function Graphs.diameter(dg::D) where {D <: DataGraphUnion}
    return Graphs.diameter(dg.g)
end

function Graphs.periphery(dg::D) where {D <: DataGraphUnion}
    return Graphs.periphery(dg.g)
end

function Graphs.radius(dg::D) where {D <: DataGraphUnion}
    return Graphs.radius(dg.g)
end

function Graphs.center(dg::D) where {D <: DataGraphUnion}
    return Graphs.center(dg.g)
end

function Graphs.complement(dg::D) where {D <: DataGraphUnion}
    return Graphs.complement(dg.g)
end

function Graphs.cycle_basis(dg::D) where {D <: DataGraphUnion}
    numbered_cycles = Graphs.cycle_basis(dg.g)

    nodes  = dg.nodes
    cycles = []

    for i in numbered_cycles
        push!(cycles, nodes[i])
    end

    return cycles
end

function Graphs.indegree(dg::D) where {D <: DataGraphUnion}
    return Graphs.indegree(dg.g)
end

function Graphs.indegree(dg::D, node) where {D <: DataGraphUnion}
    node_map = dg.node_map
    return Graphs.indegree(dg, node_map[node])
end

function Graphs.outdegree(dg::D) where {D <: DataGraphUnion}
    return Graphs.outdegree(dg.g)
end

function Graphs.outdegree(dg::D, node) where {D <: DataGraphUnion}
    node_map = dg.node_map
    return Graphs.outdegree(dg, node_map[node])
end

function Graphs.degree(dg::D) where {D <: DataGraphUnion}
    return Graphs.degree(dg.g)
end

function Graphs.degree(dg::D, node) where {D <: DataGraphUnion}
    node_map = dg.node_map
    return Graphs.degree(dg, node_map[node])
end

function Graphs.degree_histogram(dg::D) where {D <: DataGraphUnion}
    return degree_histogram(dg.g)
end

function Graphs.degree_centrality(dg::D) where {D <: DataGraphUnion}
    return degree_centrality(dg.g)
end

function average_degree(dg::D) where {D <: DataGraphUnion}
    degrees = Graphs.degree(dg)
    return sum(degrees) / length(degrees)
end
