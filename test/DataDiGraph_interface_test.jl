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

rename_node_attribute!(dg, "weight", "weight1")
rename_edge_attribute!(dg, "weight", "weight1")

@testset "interface test" begin
    @test DataGraphs.ne(dg) == length(dg.edges)
    @test DataGraphs.nv(dg) == length(dg.nodes)
    @test nn(dg) == length(dg.nodes)
    @test has_node(dg, 4)
    @test !(has_node(dg, 7))
    @test DataGraphs.has_edge(dg, 1, 3)
    @test !(DataGraphs.has_edge(dg, 3, 1))
    @test_throws ErrorException DataGraphs.has_edge(dg, 7, 3)
    @test_throws ErrorException DataGraphs.has_edge(dg, 3, 7)
    @test dg.node_data.attributes == ["weight1"]
    @test dg.node_data.attribute_map["weight1"] == 1
    @test dg.edge_data.attributes == ["weight1"]
    @test dg.edge_data.attribute_map["weight1"] == 1
    @test_throws ErrorException rename_node_attribute!(dg, "wrong_weight", "weight")
    @test_throws ErrorException rename_edge_attribute!(dg, "wrong_weight", "weight")
end
