nodes = [1, 2, 3, 4, 5, 6]
node_data = [1, 2, 4, 1, 2, 1]
edges = [(1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (4, 5), (4,6)]
edge_data = [1, 1, 2, 3, 4, 2, 4]

dg = DataGraph()
for i in 1:length(nodes)
    add_node!(dg, nodes[i])
    add_node_data!(dg, nodes[i], node_data[i], "weight")
end

for i in 1:length(edges)
    PlasmoData.add_edge!(dg, edges[i])
    add_edge_data!(dg, edges[i], edge_data[i], "weight")
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
    @test PlasmoData.ne(dg) == length(dg.edges)
    @test PlasmoData.nv(dg) == length(dg.nodes)
    @test nn(dg) == length(dg.nodes)
    @test has_node(dg, 4)
    @test !(has_node(dg, 7))
    @test PlasmoData.has_edge(dg, 1, 3)
    @test PlasmoData.has_edge(dg, 3, 1)
    @test !(PlasmoData.has_edge(dg, 2, 5))
    @test_throws ErrorException PlasmoData.has_edge(dg, 7, 3)
    @test_throws ErrorException PlasmoData.has_edge(dg, 3, 7)
    @test dg.node_data.attributes == ["weight1"]
    @test dg.node_data.attribute_map["weight1"] == 1
    @test dg.edge_data.attributes == ["weight1"]
    @test dg.edge_data.attribute_map["weight1"] == 1
    @test_throws ErrorException rename_node_attribute!(dg, "wrong_weight", "weight")
    @test_throws ErrorException rename_edge_attribute!(dg, "wrong_weight", "weight")
end
