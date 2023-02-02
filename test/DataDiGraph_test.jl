# Test add_node!
nodes = [7, "node2", :node3, 17.5]

dg = DataDiGraph()
for i in nodes
    add_node!(dg, i)
end

@testset "add_node! test" begin
    @test length(dg.nodes) == length(nodes)
    @test dg.nodes == nodes
    @test length(dg.g.fadjlist) == length(nodes)
    @test test_map(dg.nodes, dg.node_map)
end

# Test add_node_data!

node_data = [6.3, 7.2, 8.6, 4.3]

add_node_data!(dg, nodes[2], node_data[2], "weight")
add_node_data!(dg, nodes[4], node_data[4], "weight")
add_node_data!(dg, nodes[1], node_data[1], "weight")
add_node_data!(dg, nodes[3], node_data[3], "weight")

@testset "add_node_data!" begin
    @test dg.node_data.data[:, 1] == node_data
    @test dg.node_data.attributes == ["weight"]
end

# Test add_edge! function 1

edges = [(17.5, 7), (:node3, "node2"), (7, :node3)]

for (i, j) in edges
    DataGraphs.add_edge!(dg, i, j)
end

@testset "add_edge! test1" begin
    @test length(dg.edges) == length(edges)
    @test length(dg.edge_map) == length(edges)
    @test length(dg.edges) == dg.g.ne
    @test test_map(dg.edges, dg.edge_map)

    node_map = dg.node_map
    for (i, edge) in enumerate(edges)
        node1 = node_map[edge[1]]
        node2 = node_map[edge[2]]

        @test ((node1, node2) == dg.edges[i])
        @test node2 in dg.g.fadjlist[node1]
        @test node1 in dg.g.badjlist[node2]
    end
end

# Test add_edge_data!

edge_data = [2.1, 3.5, 6.8]

add_edge_data!(dg, edges[3][1], edges[3][2], edge_data[3], "weight")
add_edge_data!(dg, edges[1][1], edges[1][2], edge_data[1], "weight")
add_edge_data!(dg, edges[2][1], edges[2][2], edge_data[2], "weight")

@testset "add_edge_data! test1" begin
    @test dg.edge_data.data[:, 1] == edge_data
    @test dg.edge_data.attributes == ["weight"]
end

# Test add_edge! function 2

edges = [(17.5, 7), (:node3, "node2"), (7, :node3)]

dg = DataDiGraph()
for i in nodes
    add_node!(dg, i)
end

for i in edges
    DataGraphs.add_edge!(dg, i)
end

@testset "add_edge! test2" begin
    @test length(dg.edges) == length(edges)
    @test length(dg.edge_map) == length(edges)
    @test length(dg.edges) == dg.g.ne
    @test test_map(dg.edges, dg.edge_map)

    node_map = dg.node_map
    for (i, edge) in enumerate(edges)
        node1 = node_map[edge[1]]
        node2 = node_map[edge[2]]

        @test ((node1, node2) == dg.edges[i])
        @test node2 in dg.g.fadjlist[node1]
        @test node1 in dg.g.badjlist[node2]
    end
end

# Test add_edge_data! function 2

edge_data = [2.1, 3.5, 6.8]

add_edge_data!(dg, edges[3], edge_data[3], "weight")
add_edge_data!(dg, edges[1], edge_data[1], "weight")
add_edge_data!(dg, edges[2], edge_data[2], "weight")

@testset "add_edge_data! test 2" begin
    @test dg.edge_data.data[:, 1] == edge_data
    @test dg.edge_data.attributes == ["weight"]
end

# Test adjacency matrix constructor

adj_mat = sparse([1, 1, 2, 3, 3, 4, 2, 3, 5, 4, 5, 5],
    [2, 3, 5, 4, 5, 5, 1, 1, 2, 3, 3, 4],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

dg = DataDiGraph(adj_mat)

@testset "adjacency matrix constructor" begin
    @test length(dg.nodes) == 5
    @test length(dg.edges) == 12
    @test (1, 2) in dg.edges
    @test (3, 2) in dg.edges
    @test (2, 1) in dg.edges
    @test (4, 1) in dg.edges
    @test (2, 3) in dg.edges
    @test (5, 3) in dg.edges
    @test (4, 3) in dg.edges
    @test (3, 5) in dg.edges
    @test (4, 5) in dg.edges
    @test (1, 4) in dg.edges
    @test (3, 4) in dg.edges
    @test (5, 4) in dg.edges
end

dg = DataDiGraph{Int8, Float32, Float32, Matrix{Float32}, Matrix{Float32}}()

@testset "DataDiGraph Typing" begin
    @test eltype(dg) == Int8
    @test typeof(get_node_data(dg)) == Matrix{Float32}
    @test typeof(get_edge_data(dg)) == Matrix{Float32}
    @test eltype(get_node_data(dg)) == Float32
    @test eltype(get_edge_data(dg)) == Float32
end
