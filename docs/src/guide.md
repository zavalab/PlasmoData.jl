# Getting Started

A `DataGraph` can be initiated by calling 

```julia
dg = DataGraph()
```

PlasmoData.jl also supports building a `DataGraph` from an adjacency matrix. The `DataGraph` can be changed by adding nodes or edges to the graph, as shown below. `add_node!` takes two arguments: the `DataGraph` of interest and the node name (any data type is permitted). `add_edge` takes three arguments, the `DataGraph` of interest, and the names of two nodes in the graph. 

```julia
add_node!(dg, "node1")
add_node!(dg, :node2)
add_node!(dg, 3)

add_edge!(dg, "node1", :node2)
add_edge!(dg, 3, :node2)
add_edge!(dg, "node1", 3)
```

Data can be added to these nodes or edges by calling `add_node_data!` or `add_edge_data!` as shown below. Here, these functions take similar arguments to `add_node!` or `add_edge!`, but they also take two additional arguments, one for the weight value and one for the attribute name (must be a string). When setting a new attribute, the other nodes or edges will receive a default value of 0. 

```julia
add_node_data!(dg, "node1", 1.0,   "node_weight_1")
add_node_data!(dg, :node2,  2.0, "node_weight_1")
add_node_data!(dg, 3,       3.0,   "node_weight_1")

add_edge_data!(dg, "node1", :node2,  4.0, "edge_weight_1")
add_edge_data!(dg, :node2,  3,       5.0, "edge_weight_1")
add_edge_data!(dg, 3,       "node1", 6.0, "edge_weight_1")
```

Note that for `DataGraph`s, the order of the nodes in the edge is not important, but it is important for `DataDiGraph`s. 

## Additional Functions for Building Graphs

There are also functions for direclty building a graph from a set of data. Examples are shown below.

```julia
random_matrix = rand(20, 20)

matrix_graph = matrix_to_graph(random_matrix, "matrix_weight")

symmetric_random_matrix = random_matrix .+ random_matrix'

symmetric_matrix_graph = symmetric_matrix_to_graph(symmetric_random_matrix, "matrix_weight")

random_tensor = rand(20, 20, 15)

tensor_graph = tensor_to_graph(random_tensor)

matrix_graph_multiple_weights = matrix_to_graph(random_tensor)
```

## Manipulating Graph Structure

PlasmoData.jl enables manipulating graph structure while maintaining the data in the resulting graph. For both `DataGraph`s and `DataDiGraph`s, users can call `filter_nodes`, `filter_edges`, `aggregate`, `remove_node!`, and `remove_edge!`. 

```julia
# Keep nodes for which the "matrix_weight" is greater than 0.5
filtered_graph = filter_nodes(matrix_graph, 0.5, "matrix_weight", fn = Base.isgreater)

# Keep edges for which the "matrix_weight" is less than 0.5
filtered_graph = filter_edges(symmetric_matrix_graph, 0.5, "matrix_weight", fn = Base.isless)

# aggregate the nodes (2, 3), (2, 4), and (3, 3) together
aggregated_graph = aggregate(matrix_graph, [(2, 3), (2, 4), (3, 3)], "new_node")

remove_node!(matrix_graph, (4, 4))
remove_edge!(matrix_graph, (4, 5), (4, 6))
```

## Data Analysis

Representing and modeling data as a graph enables unique analysis, including analyzing the topology of the resulting graph. [Topological Data Analysis (TDA)](https://en.wikipedia.org/wiki/Topological_data_analysis) can be applied generally to geometric shapes, including to graphs. TDA is an expanding field, and it has been shown to be a powerful data analysis tool for many systems. Some TDA is enabled within PlasmoData.jl (in many cases, through extending the functions of Graphs.jl).

The [Euler Characteristic (EC)](https://www.sciencedirect.com/science/article/abs/pii/S0098135421002416) is a topological descriptor for geometric objects. For graphs, the EC is equal to the number of nodes minus the number of edges (or equivalently, the number of connected components minus the number of cycles). Often, the EC is combined with filtration to form an EC Curve. For node- or edge-weighted graphs, this involves filtering out nodes or edges of a graph based on their weight value and computing the EC of the resulting structure. This is done at a range of threshold values to get a vector (curve). PlasmoData.jl provides functions for computing the EC and the EC curve (note that the EC only applies to `DataGraph`s and not `DataDiGraph`s)

```julia
thresh = 0:.01:1

EC_curve = run_EC_on_nodes(matrix_graph, thresh)

EC_curve = run_EC_on_edges(symmetric_matrix_graph, thresh)

EC = get_EC(matrix_graph)
```

Other metrics are also available for studying the topology of the graph. Some examples are shown below (largely extensions of Graphs.jl)

```julia
ad = average_degree(matrix_graph)

cycles = Graphs.cycle_basis(matrix_graph)

conn_comp = Graphs.connected_components(matrix_graph)

neighbor_list = Graphs.neighbors(matrix_graph, (2, 2))

diam = Graphs.diameter(matrix_graph)

communities = Graphs.clique_percolation(matrix_graph, k = 3)

max_clique = Graphs.maximal_cliques(matrix_graph)
```

In addition, there are also functions for analyzing the connections in directed graphs. These include `has_path` (returns `true` or `false` depending on if there is a path between two given nodes) and `get_path` (returns the path between two given nodes if it exists). In addition, these functions can also take another argument of an intermediate node (i.e., for detecting a path between two nodes that passes through the intermediate node).  In addition, there are functions to get all the upstream and downstream nodes of a given node using `upstream_nodes` and `downstream_nodes`.

```julia
nodes = [1, 2, 3, 4, 5]
edges = [(1, 2), (1, 3), (2, 3), (3, 4), (4, 2), (5, 4)]

dg = DataDiGraph()
for i in nodes
    add_node!(dg, i)
end

for i in edges
    add_edge!(dg, i)
end

# Test if there is a path between nodes 1 and 4
PlasmoData.has_path(dg, 1, 4)

# Test if there is a path between nodes 1 and 5 that passes through 4
PlasmoData.has_path(dg, 1, 4, 5)

# Return the (shortest) path between Nodes 1 and 4
get_path(dg, 1, 4)

# Return the (shortest) path between Nodes 1 and 4 that passes through 2
get_path(dg, 1, 2, 4)

up_nodes = upstream_nodes(dg, 4)

down_nodes = downstream_nodes(dg, 1
```

## Further Examples

To see additional examples of how PlasmoData.jl can be used, please see the [examples](https://github.com/zavalab/PlasmoData.jl/tree/main/examples) directory within this repository.