nodes = [1, 2, 3, 4, 5, 6]
node_data = [1, 2, 4, 1, 2, 1]
edges = [(1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (4, 5), (4,6)]
edge_data = [1, 1, 2, 3, 4, 2, 4]

dg = DataDiGraph()
for i in 1:length(nodes)
    add_node!(dg, nodes[i])
    add_node_data!(dg, nodes[i], node_data[i])
end

for i in 1:length(edges)
    DataGraphs.add_edge!(dg, edges[i])
    add_edge_data!(dg, edges[i], edge_data[i])
end

@testset "get_edge_data test" begin
    @test get_edge_data(dg, 1, 3, "weight") == 1
    @test get_edge_data(dg, 4, 6, "weight") == 4
    @test get_edge_data(dg, (1, 3), "weight") == 1
    @test get_edge_data(dg, (4, 6), "weight") == 4
    @test_throws ErrorException get_edge_data(dg, 1, 6, "weight")
end

@testset "ne, nn, nv test" begin
    @test DataGraphs.ne(dg) == length(dg.edges)
    @test DataGraphs.nv(dg) == length(dg.nodes)
    @test nn(dg) == length(dg.nodes)
end
