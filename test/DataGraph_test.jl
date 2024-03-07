# Test add_node!
nodes = [7, "node2", :node3, 17.5]
node_data = [6.3, 7.2, 8.6, 4.3]

node_data2 = [4, 2.4]
node_list2 = [:node3, 17.5]
node_data3 = [17, 4, 2.2, 6]
node_data_dict = Dict(7 => 3, "node2" => 4.2, :node3 => 1.0, 17.5 => 14.5)

edges = [(17.5, 7), (:node3, "node2"), (7, :node3)]
edge_data = [2.1, 3.5, 6.8]

edge_data2 = [2.3, 4.4]
edge_list2 = [(:node3, "node2"), (:node3, 7)]
edge_data3 = [14, 15.3, 16.4]
edge_data_dict = Dict((17.5, 7) => .2, (:node3, "node2") => .5, (7, :node3) => .33)

function build_datagraph(nodes, edges)
    dg = DataGraph()
    for i in nodes
        add_node!(dg, i)
    end
    for (i, j) in edges
        add_edge!(dg, i, j)
    end

    return dg
end

dg = DataGraph()
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

add_node_data!(dg, nodes[2], node_data[2], "weight")
add_node_data!(dg, nodes[4], node_data[4], "weight")
add_node_data!(dg, nodes[1], node_data[1], "weight")
add_node_data!(dg, nodes[3], node_data[3], "weight")

@testset "add_node_data! test" begin
    @test dg.node_data.data[:, 1] == node_data
    @test dg.node_data.attributes == ["weight"]
    @test_throws ErrorException add_node_data!(dg, "node5", 5.0, "weight")
end

# Test add_node_attribute!

add_node_attribute!(dg, "weight2", 1.0)

@testset "add_node_attribute! test" begin
    @test size(get_node_data(dg)) == (length(dg.nodes), 2)
    @test dg.node_data.attributes == ["weight", "weight2"]
    @test dg.node_data.attribute_map["weight2"] == 2
    @test all(i -> i == 1.0, get_node_data(dg)[:, 2])
    @test_throws ErrorException add_node_attribute!(dg, "weight", 0.0)
    @test get_node_attributes(dg) == ["weight", "weight2"]
end

# Test add_node_dataset!

add_node_dataset!(dg, node_list2, node_data2, "weight2")
add_node_dataset!(dg, node_data3, "weight3")
add_node_dataset!(dg, node_data_dict, "weight4")
weight_list = ["weight", "weight2", "weight3", "weight4"]
dg2 = build_datagraph(nodes, edges)
dg3 = build_datagraph(nodes, edges)
dg4 = build_datagraph(nodes, edges)
add_node_dataset!(dg2, node_list2, node_data2, "weight2")
add_node_attribute!(dg3, "weight3", 1.0)
add_node_attribute!(dg4, "weight4", 1.0)
add_node_dataset!(dg3, node_data3, "weight3")
add_node_dataset!(dg4, node_data_dict, "weight4")

@testset "add_node_dataset! test" begin
    @test dg.node_data.attributes == weight_list
    @test test_map(dg.node_data.attributes, dg.node_data.attribute_map)
    @test get_node_data(dg)[:, 2][:] == [1, 1, 4, 2.4]
    @test get_node_data(dg)[:, 3][:] == node_data3
    @test get_node_data(dg)[:, 4][:] == [3, 4.2, 1.0, 14.5]
    @test_throws ErrorException add_node_dataset!(dg, [:node5], [7.2], "weight5")
    @test_throws ErrorException add_node_dataset!(dg, [:node3, "node2"], [7.2], "weight5")
    @test_throws ErrorException add_node_dataset!(dg, [7.2, 3.4], "weight5")
    @test_throws ErrorException add_node_dataset!(dg, Dict("node5" => 7.2), "weight5")
    @test dg2.node_data.attributes == ["weight2"]
    @test dg3.node_data.attributes == ["weight3"]
    @test dg4.node_data.attributes == ["weight4"]
    @test get_node_data(dg2)[:, 1][:] == [0.0, 0.0, 4.0, 2.4]
    @test get_node_data(dg3)[:, 1][:] == node_data3
    @test get_node_data(dg4)[:, 1][:] == [3, 4.2, 1.0, 14.5]
    @test get_node_data(dg, ["weight", "weight4"]) == [6.3 3.0; 7.2 4.2; 8.6 1.0; 4.3 14.5]
    @test get_node_data(dg, "weight") == [6.3, 7.2, 8.6, 4.3]
    @test_throws ErrorException get_node_data(dg, ["weight3", "weight5"])
    @test_throws ErrorException get_node_data(dg, "weight5")

    @test_throws ErrorException get_node_data(dg, ["weight3"], nodes = [1, 3, 7])
    @test get_node_data(dg, ["weight3", "weight4"], nodes = [7, :node3]) == [17.0 3.0; 2.2 1.0]
end

# Test add_edge! function 1

for (i, j) in edges
    add_edge!(dg, i, j)
end

@testset "add_edge! test" begin
    @test length(dg.edges) == length(edges)
    @test length(dg.edge_map) == length(edges)
    @test length(dg.edges) == dg.g.ne
    @test test_map(dg.edges, dg.edge_map)

    node_map = dg.node_map
    for (i, edge) in enumerate(edges)
        node1 = node_map[edge[1]]
        node2 = node_map[edge[2]]

        @test ((node1, node2) == dg.edges[i] || (node2, node1) == dg.edges[i])
        @test node2 in dg.g.fadjlist[node1]
        @test node1 in dg.g.fadjlist[node2]
    end
end

# Test add_edge_data! function 1

add_edge_data!(dg, edges[3][1], edges[3][2], edge_data[3], "weight")
add_edge_data!(dg, edges[1][1], edges[1][2], edge_data[1], "weight")
add_edge_data!(dg, edges[2][1], edges[2][2], edge_data[2], "weight")

@testset "add_edge_data!" begin
    @test dg.edge_data.data[:, 1] == edge_data
    @test dg.edge_data.attributes == ["weight"]
end

#test add_edge! function 2

dg = DataGraph()
for i in nodes
    add_node!(dg, i)
end

for i in edges
    add_edge!(dg, i)
end

@testset "add_edge! test" begin
    @test length(dg.edges) == length(edges)
    @test length(dg.edge_map) == length(edges)
    @test length(dg.edges) == dg.g.ne
    @test test_map(dg.edges, dg.edge_map)

    node_map = dg.node_map
    for (i, edge) in enumerate(edges)
        node1 = node_map[edge[1]]
        node2 = node_map[edge[2]]

        @test ((node1, node2) == dg.edges[i] || (node2, node1) == dg.edges[i])
        @test node2 in dg.g.fadjlist[node1]
        @test node1 in dg.g.fadjlist[node2]
    end
end

# Test add_edge_data! function 2

add_edge_data!(dg, edges[3], edge_data[3], "weight")
add_edge_data!(dg, edges[1], edge_data[1], "weight")
add_edge_data!(dg, edges[2], edge_data[2], "weight")

@testset "add_edge_data!" begin
    @test dg.edge_data.data[:, 1] == edge_data
    @test dg.edge_data.attributes == ["weight"]
end

# Test add_edge_attribute!

add_edge_attribute!(dg, "weight2", 1.0)

@testset "add_edge_attribute! test" begin
    @test size(get_edge_data(dg)) == (length(dg.edges), 2)
    @test dg.edge_data.attributes == ["weight", "weight2"]
    @test dg.edge_data.attribute_map["weight2"] == 2
    @test all(i -> i == 1.0, get_edge_data(dg)[:, 2])
    @test_throws ErrorException add_edge_attribute!(dg, "weight", 0.0)
    @test get_edge_attributes(dg) == ["weight", "weight2"]
end

# Test add_edge_dataset!

add_edge_dataset!(dg, edge_list2, edge_data2, "weight2")
add_edge_dataset!(dg, edge_data3, "weight3")
add_edge_dataset!(dg, edge_data_dict, "weight4")
weight_list = ["weight", "weight2", "weight3", "weight4"]
add_edge_dataset!(dg2, edge_list2, edge_data2, "weight2")
add_edge_attribute!(dg3, "weight3", 1.0)
add_edge_attribute!(dg4, "weight4", 1.0)
add_edge_dataset!(dg3, edge_data3, "weight3")
add_edge_dataset!(dg4, edge_data_dict, "weight4")

@testset "add_edge_dataset! test" begin
    @test dg.edge_data.attributes == weight_list
    @test test_map(dg.node_data.attributes, dg.edge_data.attribute_map)
    @test get_edge_data(dg)[:, 2][:] == [1.0, 2.3, 4.4]
    @test get_edge_data(dg)[:, 3][:] == edge_data3
    @test get_edge_data(dg)[:, 4][:] == [0.2, 0.5, 0.33]
    @test_throws ErrorException add_edge_dataset!(dg, [(17.5, "node2")], [8.3], "weight5")
    @test_throws ErrorException add_edge_dataset!(dg, [(17.5, 7), (7, :node3)], [8.3], "weight5")
    @test_throws ErrorException add_edge_dataset!(dg, [8.3, 8.2], "weight5")
    @test_throws ErrorException add_edge_dataset!(dg, Dict((:node3, 17.5) => 8.2), "weight5")
    @test dg2.node_data.attributes == ["weight2"]
    @test dg3.node_data.attributes == ["weight3"]
    @test dg4.node_data.attributes == ["weight4"]
    @test get_edge_data(dg2)[:, 1][:] == [0.0, 2.3, 4.4]
    @test get_edge_data(dg3)[:, 1][:] == edge_data3
    @test get_edge_data(dg4)[:, 1][:] == [0.2, 0.5, 0.33]
    @test get_edge_data(dg, ["weight", "weight3"]) == [2.1 14.0; 3.5 15.3; 6.8 16.4]
    @test get_edge_data(dg, "weight3") == edge_data3
    @test_throws ErrorException get_edge_data(dg, ["weight3", "weight5"])
    @test_throws ErrorException get_edge_data(dg, "weight5")
end

# Test edge ordering

@testset "test edge ordering" begin
    @test get_ordered_edge_data(dg) == [6.8 4.4 16.4 0.33; 2.1 1.0 14.0 0.2; 3.5 2.3 15.3 0.5]
    @test get_ordered_edge_data(dg, ["weight3", "weight2"]) == [16.4 4.4; 14.0 1.0; 15.3 2.3]
    @test get_ordered_edge_data(dg, "weight4") == [0.33, 0.2, 0.5]
    order_edges!(dg)
    @test dg.edges == [(1, 3), (1, 4), (2, 3)]
    @test test_map(dg.edges, dg.edge_map)
    @test get_edge_data(dg)  == [6.8 4.4 16.4 0.33; 2.1 1.0 14.0 0.2; 3.5 2.3 15.3 0.5]
    @test get_edge_data(dg, ["weight3", "weight2"]) == [16.4 4.4; 14.0 1.0; 15.3 2.3]
    @test get_edge_data(dg, "weight4") == [0.33, 0.2, 0.5]
end


# Test graph_data

add_graph_data!(dg, 1.0, "class1")
add_graph_data!(dg, 0.0, "class2")

@testset "graph_data tests" begin
    @test get_graph_data(dg) == [1.0, 0.0]
    @test get_graph_attributes(dg) == ["class1", "class2"]
    @test_throws ErrorException rename_graph_attribute!(dg, "class3", "class4")
    rename_graph_attribute!(dg, "class2", "class3")
    add_graph_data!(dg, 2.0, "class3")
    @test get_graph_data(dg) == [1.0, 2.0]
    @test get_graph_attributes(dg) == ["class1", "class3"]
end

# Test adjacency matrix constructor

adj_mat = sparse([1, 1, 2, 3, 3, 4, 2, 3, 5, 4, 5, 5],
    [2, 3, 5, 4, 5, 5, 1, 1, 2, 3, 3, 4],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

dg = DataGraph(adj_mat)

@testset "adjacency matrix constructor" begin
    @test length(dg.nodes) == 5
    @test length(dg.edges) == 6
    @test (1, 2) in dg.edges
    @test (1, 3) in dg.edges
    @test (3, 4) in dg.edges
    @test (2, 5) in dg.edges
    @test (3, 5) in dg.edges
    @test (4, 5) in dg.edges
end

edge_list = [(1, 2), (1, 3), (3, 4), (2, 5), (3, 5), (4, 5)]

dg = DataGraph(edge_list)

@testset "edge_list constructor" begin
    @test length(dg.nodes) == 5
    @test length(dg.edges) == 6
    @test (1, 2) in dg.edges
    @test (1, 3) in dg.edges
    @test (3, 4) in dg.edges
    @test (2, 5) in dg.edges
    @test (3, 5) in dg.edges
    @test (4, 5) in dg.edges
end

# Test eltype function
@test eltype(eltype(dg.g.fadjlist)) == eltype(dg)

dg = DataGraph{Int8, Float32, Float32, Float32, Matrix{Float32}, Matrix{Float32}}()

@testset "DataGraph Typing" begin
    @test eltype(dg) == Int8
    @test typeof(get_node_data(dg)) == Matrix{Float32}
    @test typeof(get_edge_data(dg)) == Matrix{Float32}
    @test typeof(get_graph_data(dg)) == Vector{Float32}
    @test eltype(get_node_data(dg)) == Float32
    @test eltype(get_edge_data(dg)) == Float32
    @test eltype(get_graph_data(dg)) == Float32
end
