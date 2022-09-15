function Graphs.connected_components(dg::DataGraph)
    connected_components_list = Graphs.connected_components(dg.g)

    nodes  = dg.nodes
    components = []

    for i in connected_components_list
        push!(components, nodes[i])
    end

    return components
end

function Graphs.is_connected(dg::DataGraph)
    return Graphs.is_connected(dg.g)
end

function Graphs.common_neighbors(dg::DataGraph, node1, node2)
    node_map = dg.node_map
    return Graphs.common_neighbors(dg.g, node_map[node1], node_map[node2])
end

function Graphs.neighbors(dg::DataGraph, node)
    node_map = dg.node_map
    return Graphs.neighbors(dg.g, node_map[node])
end

function Graphs.core_number(dg::DataGraph)
    return Graphs.core_number(dg.g)
end

function Graphs.k_core(dg::DataGraph, k = -1)
    k_core_index = Graphs.k_core(dg.g, k)
    return dg.nodes[k_core_index]
end

function Graphs.k_shell(dg::DataGraph, k = -1)
    k_shell_index = Graphs.k_shell(dg.g, k)
    return dg.nodes[k_shell_index]
end

function Graphs.k_crust(dg::DataGraph, k = -1)
    k_crust_index = Graphs.k_crust(dg.g, k)
    return dg.nodes[k_crust_index]
end

function Graphs.eccentricity(dg::DataGraph, node)
    node_map = dg.node_map
    return Graphs.eccentricity(dg.g, node_map[node])
end

function Graphs.diameter(dg::DataGraph)
    return Graphs.diameter(dg.g)
end

function Graphs.periphery(dg::DataGraph)
    return Graphs.periphery(dg.g)
end

function Graphs.radius(dg::DataGraph)
    return Graphs.radius(dg.g)
end

function Graphs.center(dg::DataGraph)
    return Graphs.center(dg.g)
end

function Graphs.complement(dg::DataGraph)
    return Graphs.complement(dg.g)
end

function Graphs.cycle_basis(dg::DataGraph)
    numbered_cycles = Graphs.cycle_basis(dg.g)

    nodes  = dg.nodes
    cycles = []

    for i in numbered_cycles
        push!(cycles, nodes[i])
    end

    return cycles
end

function Graphs.indegree(dg::DataGraph)
    return Graphs.indegree(dg.g)
end

function Graphs.indegree(dg::DataGraph, node)
    node_map = dg.node_map
    return Graphs.indegree(dg::DataGraph, node_map[node])
end

function Graphs.outdegree(dg::DataGraph)
    return Graphs.outdegree(dg.g)
end

function Graphs.outdegree(dg::DataGraph, node)
    node_map = dg.node_map
    return Graphs.outdegree(dg::DataGraph, node_map[node])
end

function Graphs.degree(dg::DataGraph)
    return Graphs.degree(dg.g)
end

function Graphs.degree(dg::DataGraph, node)
    node_map = dg.node_map
    return Graphs.degree(dg::DataGraph, node_map[node])
end

function Graphs.degree_histogram(dg::DataGraph)
    return degree_histogram(dg.g)
end

function Graphs.degree_centrality(dg::DataGraph)
    return degree_centrality(dg.g)
end

function average_degree(dg::DataGraph)
    degrees = Graphs.degree(dg)
    return sum(degrees) / length(degrees)
end
