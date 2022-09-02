using Test
include("../src/DataGraphs.jl")

# Test add_node!
nodes = [7, "node2", :node3, 17.5]

dg = DataGraphs.DataGraph()
for i in nodes
    DataGraphs.add_node!(dg, i)
end

@testset "add_node! test" begin
    @test length(dg.nodes) == length(nodes)
    @test dg.nodes == nodes
    @test length(dg.g.fadjlist) == length(nodes)
    @test length(dg.node_map) == length(nodes)
    for (i, node) in enumerate(nodes)
        @test dg.node_map[node] == i
    end
end

# Test add_edge!

edges = [(17.5, 7), (:node3, "node2"), (7, :node3)]

for (i, j) in edges
    DataGraphs.add_edge!(dg, i, j)
end

@testset "add_edge! test" begin
    @test length(dg.edges) == length(edges)
    @test length(dg.edge_map) == length(edges)
    @test length(dg.edges) == dg.g.ne

    node_map = dg.node_map
    for (i, edge) in enumerate(edges)
        node1 = node_map[edge[1]]
        node2 = node_map[edge[2]]

        @test ((node1, node2) == dg.edges[i] || (node2, node1) == dg.edges[i])
        @test node2 in dg.g.fadjlist[node1]
        @test node1 in dg.g.fadjlist[node2]
    end
end
