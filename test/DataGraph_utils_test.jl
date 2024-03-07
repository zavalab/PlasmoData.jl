Random.seed!(10)
random_matrix = rand(10, 10)

dg = matrix_to_graph(random_matrix, diagonal = true, attribute = "matrix_value")

@testset "matrix_to_graph test1" begin
    @test length(dg.nodes) == 100
    @test get_node_data(dg)[:] == random_matrix[:]
    @test dg.node_data.attributes == ["matrix_value"]
    @test length(dg.edges) == dg.g.ne
    @test length(dg.edges) == 342
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
end

dg = matrix_to_graph(random_matrix, diagonal = false, attribute = "matrix_value")

@testset "matrix_to_graph test2" begin
    @test length(dg.nodes) == 100
    @test get_node_data(dg)[:] == random_matrix[:]
    @test dg.node_data.attributes == ["matrix_value"]
    @test length(dg.edges) == dg.g.ne
    @test length(dg.edges) == 180
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
end

@test get_EC(dg) == (length(dg.nodes) - length(dg.edges))

random_array = rand(10, 10, 5)
attribute_names = ["matrix1", "matrix2", "matrix3", "matrix4", "matrix5"]

dg = matrix_to_graph(random_array, diagonal = true, attributes = attribute_names)

@testset "matrix_to_graph test3" begin
    @test length(dg.nodes) == 100
    @test get_node_data(dg)[:] == random_array[:]
    @test dg.node_data.attributes == attribute_names
    @test length(dg.edges) == dg.g.ne
    @test length(dg.edges) == 342
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
end

sym_matrix = random_matrix + random_matrix'

dg = symmetric_matrix_to_graph(sym_matrix[1:5, 1:5]; attribute = "weight_value")

@testset "symmetric_matrix_to_graph test" begin
    @test length(dg.nodes) == 5
    @test length(dg.edges) == dg.g.ne
    @test length(dg.edges) == 10
    @test dg.edge_data.attributes == ["weight_value"]
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    edge_data = get_edge_data(dg)
    @test edge_data[1:4] == sym_matrix[2:5, 1]
    @test edge_data[5:7] == sym_matrix[3:5, 2]
    @test edge_data[8:9] == sym_matrix[4:5, 3]
    @test edge_data[10]  == sym_matrix[5, 4]
    @test_throws ErrorException symmetric_matrix_to_graph(random_matrix)
end

dg = tensor_to_graph(random_array, "weight_value")

@testset "tensor_to_graph test" begin
    @test length(dg.nodes) == 500
    @test length(dg.edges) == dg.g.ne
    @test length(dg.edges) == 1300
    @test dg.node_data.attributes == ["weight_value"]
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    @test get_node_data(dg)[:] == random_array[:]
    @test_throws ErrorException tensor_to_graph(random_matrix)
end

matrix = [1 2 2; 1 1 3; 1 1 1]

dg = matrix_to_graph(matrix, diagonal = false)

filtered_graph = filter_nodes(dg, 2.5)

@testset "filter_nodes test" begin
    @test length(dg.nodes) - 1 == length(filtered_graph.nodes)
    @test length(dg.edges) - 3 == length(filtered_graph.edges)
    @test count(x -> x < 2.5, get_node_data(filtered_graph)) == length(filtered_graph.nodes)
    @test test_map(filtered_graph.nodes, filtered_graph.node_map)
    @test test_map(filtered_graph.edges, filtered_graph.edge_map)
end

thresh = [0, 1, 2, 3]
ECs = run_EC_on_nodes(dg, thresh)

@test ECs == [0.0, 0.0, 0.0, -1.0]

remove_node!(dg, (1, 3))

@testset "remove_node! test" begin
    @test length(dg.nodes) == 8
    @test length(dg.edges) == 10
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    @test length(get_node_data(dg)) == length(dg.nodes)
    @test dg.nodes[7] == (3, 3)
    @test get_node_data(dg)[7] == 1
    @test_throws ErrorException remove_node!(dg, (11, 15))
end

sym_matrix = matrix + matrix'

dg = symmetric_matrix_to_graph(sym_matrix)

filtered_graph = filter_edges(dg, 3.5)

@testset "filter_edges test" begin
    @test length(dg.nodes) == length(filtered_graph.nodes)
    @test length(dg.edges) - 1 == length(filtered_graph.edges)
    @test count(x -> x < 3.5, get_edge_data(filtered_graph)) == length(filtered_graph.edges)
    @test test_map(filtered_graph.nodes, filtered_graph.node_map)
    @test test_map(filtered_graph.edges, filtered_graph.edge_map)
end

thresh = [1, 2, 3, 4]
ECs = run_EC_on_edges(dg, thresh)

@test ECs == [3.0, 3.0, 3.0, 1.0]

remove_edge!(dg, 2, 1)

@testset "remove_edge! test1" begin
    @test length(dg.nodes) == 3
    @test length(dg.edges) == 2
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    @test length(get_edge_data(dg)) == length(dg.edges)
    @test dg.edges[1] == (1, 3)
    @test get_edge_data(dg)[2] == 4
end

dg = symmetric_matrix_to_graph(sym_matrix)

remove_edge!(dg, (2,1))

@testset "remove_edge! test2" begin
    @test length(dg.nodes) == 3
    @test length(dg.edges) == 2
    @test test_map(dg.nodes, dg.node_map)
    @test test_map(dg.edges, dg.edge_map)
    @test length(get_edge_data(dg)) == length(dg.edges)
    @test dg.edges[1] == (1, 3)
    @test get_edge_data(dg)[2] == 4
end

dg = matrix_to_graph(matrix, diagonal = false)

agg_graph = aggregate(dg, [(2, 2), (2, 3)], "agg_node")

@testset "aggregate test" begin
    @test length(dg.nodes) - 1 == length(agg_graph.nodes)
    @test length(dg.edges) - 1 == length(agg_graph.edges)
    @test test_map(agg_graph.nodes, agg_graph.node_map)
    @test test_map(agg_graph.edges, agg_graph.edge_map)
    @test dg.g.ne == length(dg.edges)
    node_2_2_val = get_node_data(dg, (2, 2), "weight")
    node_2_3_val = get_node_data(dg, (2, 3), "weight")
    @test get_node_data(agg_graph, "agg_node", "weight") == (node_2_2_val + node_2_3_val) / 2
    @test test_edge_exists(agg_graph, (1, 2), "agg_node")
    @test test_edge_exists(agg_graph, (1, 3), "agg_node")
    @test test_edge_exists(agg_graph, (2, 1), "agg_node")
    @test test_edge_exists(agg_graph, (3, 2), "agg_node")
    @test test_edge_exists(agg_graph, (3, 3), "agg_node")
    @test_throws ErrorException aggregate(dg, ["a", "b"], "agg_node")
end


dg = matrix_to_graph(matrix, diagonal = false)

edge_vals = fill(1., length(dg.edges))

add_edge_dataset!(dg, edge_vals, "edge_weight")

agg_graph = aggregate(dg, [(2, 2), (3, 2)], "agg_node", save_agg_edge_data = true)
agg_graph2 = aggregate(dg, [(2, 2), (3, 2)], "agg_node", save_agg_edge_data = true, node_attributes_to_add = ["weight2"])

dg_extra = matrix_to_graph(matrix, diagonal = false)
add_edge_dataset!(dg_extra, edge_vals, "weight")

@testset "aggregate test 2" begin
    @test agg_graph.node_data.attributes == ["weight", "edge_weight"]
    @test length(agg_graph.node_data.attribute_map) == 2
    @test get_node_data(agg_graph, "agg_node", "edge_weight") == 1
    @test get_node_data(agg_graph, (1, 1), "edge_weight") == 0
    @test agg_graph2.node_data.attributes == ["weight", "weight2"]
    @test length(agg_graph2.node_data.attribute_map) == 2
    @test get_node_data(agg_graph2, "agg_node", "weight2") == 1
    @test get_node_data(agg_graph2, (1, 1), "weight2") == 0
    @test_throws ErrorException aggregate(dg, [(2,2), (3,2)], "agg_node", save_agg_edge_data = true, node_attributes_to_add = ["edge_weight", "edge_weight2"])
    @test_throws ErrorException aggregate(dg, [(2,2), (3,2)], "agg_node", save_agg_edge_data = true, node_attributes_to_add = ["weight"])
    @test_throws ErrorException aggregate(dg_extra, [(2,2), (3,2)], "agg_node", save_agg_edge_data = true)
end
