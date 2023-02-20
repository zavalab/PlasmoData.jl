nodes = [1, 2, 3, 4, 5, 6]
node_data = [1, 2, 4, 1, 2, 1]
edges = [(1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (4, 5), (4, 6)]
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

filtered_graph = filter_nodes(dg, 3)

@testset "filter_nodes test" begin
    @test length(dg.nodes) - 1 == length(filtered_graph.nodes)
    @test length(dg.edges) - 2 == length(filtered_graph.edges)
    @test count(x -> x < 3, get_node_data(filtered_graph)) == length(filtered_graph.nodes)
    @test test_map(filtered_graph.nodes, filtered_graph.node_map)
    @test test_map(filtered_graph.edges, filtered_graph.edge_map)
end

filtered_graph = filter_edges(dg, 3.5)

@testset "filter_edges test" begin
    @test length(dg.nodes) == length(filtered_graph.nodes)
    @test length(dg.edges) - 2 == length(filtered_graph.edges)
    @test count(x -> x < 3.5, get_edge_data(filtered_graph)) == length(filtered_graph.edges)
    @test test_map(filtered_graph.nodes, filtered_graph.node_map)
    @test test_map(filtered_graph.edges, filtered_graph.edge_map)
end

agg_graph = aggregate(dg, [1, 5], "new_node")

@testset "aggregate test" begin
    @test length(dg.nodes) - 1 == length(agg_graph.nodes)
    @test length(dg.edges) - 1 == length(agg_graph.edges)
    @test test_map(agg_graph.nodes, agg_graph.node_map)
    @test test_map(agg_graph.edges, agg_graph.edge_map)
    @test get_node_data(agg_graph, "new_node") == 1.5
    @test agg_graph.g.ne == length(agg_graph.edges)
    @test (5, 2) in agg_graph.edges
    @test (5, 3) in agg_graph.edges
    @test (3, 5) in agg_graph.edges
    @test get_node_data(agg_graph)[:] == [2.0, 4.0, 1.0, 1.0, 1.5]
    @test get_edge_data(agg_graph)[:] == [1.0, 1.0, 3.0, 4.0, 2.0, 4.0]
    @test_throws ErrorException aggregate(dg, [1,7], "new_node")
    @test_throws ErrorException aggregate(dg, [1,5], 6)
end

remove_node!(dg, 2)

@testset "remove_node! test" begin
    @test length(dg.nodes) == 5
    @test length(dg.edges) == 5
    @test length(dg.edges) == dg.g.ne
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    @test length(get_node_data(dg)) == length(dg.nodes)
    @test length(get_edge_data(dg)) == length(dg.edges)
    @test dg.nodes[2] == 6
    @test get_node_data(dg)[2] == 1
    @test_throws ErrorException remove_node!(dg, 7)
end

remove_edge!(dg, 4, 6)

@testset "remove_edge! test1" begin
    @test length(dg.nodes) == 5
    @test length(dg.edges) == 4
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    @test length(get_edge_data(dg)) == length(dg.edges)
    @test get_edge_data(dg)[:] == [1.0, 1.0, 2.0, 2.0]
end

remove_edge!(dg, (1, 3))

@testset "remove_edge! test2" begin
    @test length(dg.nodes) == 5
    @test length(dg.edges) == 3
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    @test length(get_edge_data(dg)) == length(dg.edges)
    @test get_edge_data(dg)[:] == [1.0, 2.0, 2.0]
    @test_throws ErrorException remove_edge!(dg, 1, 2)
    @test_throws ErrorException remove_edge!(dg, 1, 6)
end
