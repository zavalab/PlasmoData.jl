Random.seed!(10)
random_matrix = rand(10, 10)

nodes = [1, 2, 3, 4, 5, 6]
node_data = [1, 2, 4, 1, 2, 1]
edges = [(1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (4, 5), (4, 6)]
edge_data = [1, 1, 2, 3, 4, 2, 4]

ddg = DataDiGraph()
for i in 1:length(nodes)
    add_node!(ddg, nodes[i])
    add_node_data!(ddg, nodes[i], node_data[i])
end

for i in 1:length(edges)
    DataGraphs.add_edge!(ddg, edges[i])
    add_edge_data!(ddg, edges[i], edge_data[i])
end

dg = matrix_to_graph(random_matrix, true, "matrix_value")

@testset "function tests" begin
    @test nodes_to_index(dg, Graphs.connected_components(dg)[1]) == Graphs.connected_components(dg.g)[1]
    @test Graphs.connected_components(ddg) == Graphs.connected_components(ddg.g)
    @test Graphs.is_connected(dg) == Graphs.is_connected(dg.g)
    @test Graphs.is_connected(ddg) == Graphs.is_connected(ddg.g)

    @test nodes_to_index(dg, Graphs.common_neighbors(dg, (1, 1), (2, 1))) == Graphs.common_neighbors(dg.g, 1, 2)
    @test Graphs.common_neighbors(ddg, 1, 3) == Graphs.common_neighbors(ddg.g, 1, 3)
    @test nodes_to_index(dg, Graphs.neighbors(dg, (1, 1))) == Graphs.neighbors(dg.g, 1)
    @test Graphs.neighbors(ddg, 1) == Graphs.neighbors(ddg.g, 1)

    @test Graphs.core_number(dg) == Graphs.core_number(dg.g)
    @test Graphs.core_number(ddg) == Graphs.core_number(ddg.g)
    @test nodes_to_index(dg, Graphs.k_core(dg)) == Graphs.k_core(dg.g)
    @test Graphs.k_core(ddg) == Graphs.k_core(ddg.g)
    @test nodes_to_index(dg, Graphs.k_shell(dg)) == Graphs.k_shell(dg.g)
    @test Graphs.k_shell(ddg) == Graphs.k_shell(ddg.g)
    @test nodes_to_index(dg, Graphs.k_crust(dg)) == Graphs.k_crust(dg.g)
    @test Graphs.k_crust(ddg) == Graphs.k_crust(ddg.g)

    @test Graphs.eccentricity(dg, (1, 1)) == Graphs.eccentricity(dg.g, 1)
    @test Graphs.diameter(dg) == Graphs.diameter(dg.g)
    @test Graphs.radius(dg) == Graphs.radius(dg.g)
    @test nodes_to_index(dg, Graphs.center(dg)) == Graphs.center(dg.g)
    @test Graphs.cycle_basis(ddg) == Graphs.cycle_basis(ddg.g)

    @test Graphs.indegree(dg) == Graphs.indegree(dg.g)
    @test Graphs.indegree(dg, (1, 1)) == Graphs.indegree(dg.g, 1)
    @test Graphs.indegree(ddg, 3) == Graphs.indegree(ddg.g, 3)
    @test Graphs.outdegree(ddg) == Graphs.outdegree(ddg.g)
    @test Graphs.outdegree(dg, (1, 1)) == Graphs.outdegree(dg.g, 1)
    @test Graphs.outdegree(ddg, 3) == Graphs.outdegree(ddg.g, 3)
    @test Graphs.degree(dg) == Graphs.degree(dg.g)
    @test Graphs.degree(dg, (1, 1)) == Graphs.degree(dg.g, 1)
    @test Graphs.degree(ddg, 3) == Graphs.degree(ddg.g, 3)

    @test Graphs.degree_histogram(dg) == Graphs.degree_histogram(dg.g)
    @test Graphs.degree_histogram(ddg) == Graphs.degree_histogram(ddg.g)
    @test Graphs.degree_centrality(dg) == Graphs.degree_centrality(dg.g)
    @test Graphs.degree_centrality(ddg) == Graphs.degree_centrality(ddg.g)
end

@testset "pathway functions" begin
    @test DataGraphs.has_path(ddg, 1, 6)
    @test DataGraphs.has_path(ddg, 1, 4, 6)
    @test get_path(ddg, 1, 6) == [1, 4, 6]
    @test get_path(ddg, 1, 4, 6) == [1, 4, 6]
    @test get_path(ddg, 1, 6; algorithm = "BellmanFord") == [1, 4, 6]
    @test get_path(ddg, 1, 4, 6; algorithm = "BellmanFord") == [1, 4, 6]
    @test_throws ErrorException DataGraphs.has_path(ddg, 1, 7)
    @test_throws ErrorException DataGraphs.has_path(ddg, 1, 7, 4)
    @test_throws ErrorException get_path(ddg, 7, 3)
    @test_throws ErrorException get_path(ddg, 1, 3, 7)
end

@test average_degree(ddg) == length(ddg.edges) * 2 / length(ddg.nodes)

matrix = [1 2 2; 1 1 3; 1 1 1]
dg = matrix_to_graph(matrix, true)

@testset "pathway functions" begin
    @test DataGraphs.has_path(dg, (1, 1), (3, 3))
    @test DataGraphs.has_path(dg, (1, 1), (2, 1), (3, 3))
    @test get_path(dg, (1, 1), (3, 3)) == [(1, 1), (2, 2), (3, 3)]
    @test get_path(dg, (1, 1), (2, 1), (3, 3)) == [(1, 1), (2, 1), (3, 2), (3, 3)]
    @test get_path(dg, (1, 1), (3, 3); algorithm = "BellmanFord") == [(1, 1), (2, 2), (3, 3)]
    @test get_path(dg, (1, 1), (2, 1), (3, 3); algorithm = "BellmanFord") == [(1, 1), (2, 1), (2, 2), (3, 3)]
    @test_throws ErrorException DataGraphs.has_path(dg, (1, 1), (3, 4))
    @test_throws ErrorException DataGraphs.has_path(dg, (1, 1), (3, 3), (3, 4))
    @test_throws ErrorException get_path(dg, (1, 4), (3, 3))
    @test_throws ErrorException get_path(dg, (1, 1), (2, 4), (3, 3))
end

@test average_degree(dg) == length(dg.edges) * 2 / length(dg.nodes)

@test index_to_nodes(dg, [1, 4, 7]) == [(1, 1), (1, 2), (1, 3)]
@test nodes_to_index(dg, [(1, 1), (1, 2), (1, 3)]) == [1, 4, 7]
