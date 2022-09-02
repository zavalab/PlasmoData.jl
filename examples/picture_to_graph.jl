using Colors, TestImages, Images, Plots
include("../src/DataGraphs.jl")
img = Images.load("./examples/Bucky_Badger.jpg")
#picture from https://www.wikiwand.com/en/Bucky_Badger

imgg = Gray.(img)

mat = convert(Array{Float64}, imgg)

mat_graph = DataGraphs.matrix_to_graph(mat)
mat_graph.node_positions = DataGraphs.set_matrix_node_positions(mat_graph.nodes, mat)

#DataGraphs.plot_graph(mat_graph; plot_edges=false, markersize=.5, xdim = 500, ydim = 500)

for i in 1:8
    @time filtered_mat_graph = DataGraphs.filter_nodes(mat_graph, i*.125; attribute = "weight")
    println("done with filter on $i")
    DataGraphs.plot_graph(filtered_mat_graph, plot_edges = false, markersize = .5)
    println("Done with $i")
end


#DataGraphs.plot_graph(mat_graph, color=:gray, C=1, K=.01, xdim = 400, ydim = 400)
