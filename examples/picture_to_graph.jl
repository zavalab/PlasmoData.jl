using Revise
using Colors, TestImages, Images
using DataGraphs, Graphs
using DataGraphPlots

# Load in the image
img = Images.load("./examples/Bucky_Badger.jpg")
#picture from https://www.wikiwand.com/en/Bucky_Badger

# Convert the image to grayscale
imgg = Gray.(img)

# Convert the image to an array
mat = convert(Array{Float64}, imgg)

# Build a graph from the array
mat_graph = matrix_to_graph(mat)
mat_graph.node_positions = set_matrix_node_positions(mat_graph.nodes, mat)

plot_graph(mat_graph; plot_edges=false, markersize = .5)

# Filter the graph
for i in 1:3
    @time filtered_mat_graph = filter_nodes(mat_graph, i*.125; attribute = "weight")
    println("done with filter on $i")
    plot_graph(filtered_mat_graph, plot_edges = false, markersize = .5)
    println("Done with $i")
end

# Perform the filtration on all three channels
mat3 = channelview(img)

mat_graph_R = DataGraphs.matrix_to_graph(mat3[1, :, :])
mat_graph_R.node_positions = set_matrix_node_positions(mat_graph_R.nodes, mat3[1, :, :])

mat_graph_G = DataGraphs.matrix_to_graph(mat3[2, :, :])
mat_graph_G.node_positions = set_matrix_node_positions(mat_graph_G.nodes, mat3[2, :, :])

mat_graph_B = DataGraphs.matrix_to_graph(mat3[3, :, :])
mat_graph_B.node_positions = set_matrix_node_positions(mat_graph_B.nodes, mat3[3, :, :])

for i in 1:3
    @time filtered_mat_graph = filter_nodes(mat_graph_R, i*.125; attribute = "weight")
    println("done with filter on $i")
    plot_graph(filtered_mat_graph, plot_edges = false, markersize = .5)
    println("Done with $i")
end

for i in 1:3
    @time filtered_mat_graph = filter_nodes(mat_graph_G, i*.125; attribute = "weight")
    println("done with filter on $i")
    plot_graph(filtered_mat_graph, plot_edges = false, markersize = .5)
    println("Done with $i")
end

for i in 1:3
    @time filtered_mat_graph = filter_nodes(mat_graph_B, i*.125; attribute = "weight")
    println("done with filter on $i")
    plot_graph(filtered_mat_graph, plot_edges = false, markersize = .5)
    println("Done with $i")
end
