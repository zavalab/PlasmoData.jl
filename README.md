# DataGraphs

DataGraphs.jl is a package for [Julia](https://julialang.org/) designed for representing data as graphs and for building graph models that contain large amounts of data on the nodes or edges of the graph. This package also has an accompanying package [DataGraphPlots.jl](https://github.com/dlcole3/DataGraphPlots.jl) which can be used for plotting the graphs. 

## Bug Reports and Support

This package is functional and can be installed as is. It is still under development, and significant changes will continue to come. If you encounter any issues or bugs, please submit them through the [Github issue tracker](https://github.com/dlcole3/DataGraphs.jl/issues). 

## Installation

To install this package, you can use 

```julia
using Pkg
Pkg.add(url="https://github.com/dlcole3/DataGraphs.jl")
```

or

```julia
pkg> add https://github.com/dlcole3/DataGraphs.jl
```

## Overview

DataGraphs.jl is designed to store data within the graph structure and to manipulate that graph based on the data. It extends the package [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl), which is a highly optimized and efficient package in Julia. DataGraphs.jl enables representing datasets (such as matrices, images, or tensors) as graphs and for performing some topological data analysis (TDA). Some of these concepts can be found in [this paper](https://www.sciencedirect.com/science/article/pii/S0098135421002416?ref=pdf_download&fr=RR-2&rr=76810ff31b5361c2).

Datagraphs.jl uses an object `DataGraph` (or `DataDiGraph` for directed graphs) to store information. These objects contain the following features:

 * `g`: `SimpleGraph` (or `SimpleDiGraph` for directed graphs) containing the graph structure.
 * `nodes`: A vector of nodes, where the entries of the vector are node names. These names are of type `Any` so that the nodes can use a variety of naming conventions (strings, symbols, tuples, etc.)
 * `edges`: A vector of tuples, where each tuple contains two entries, where each entry relates to a node. 
 * `node_map`: A dictionary that maps the node names to their index in the `nodes` vector
 * `edge_map`: A dictionary that maps the edges to their index in the `edges` vector.
 * `node_data`: An object of type `NodeData` that includes a matrix of data, where the first dimension of the matrix corresponds to the node, and the second dimension corresponds to attributes for the nodes. Any number of attributes is allowed, and `NodeData` also includes attribute names and a mapping of the attribute name to the column of the data matrix. 
 * `edge_data`: An object of type `EdgeData` that includes a matrix of data, where the first dimension fo the matrix corresponds to the edges, and the second dimension corresponds to attributes for the edges. Any number of attributes is allowed, and `EdgeData` also includes attribute names and a mapping of the attribute name to the column of the data matrix. 
 * `node_positions`: Contains an empty vector that is initialized when plotting a graph. Values here are used by DataGraphPlots.jl.

DataGraphs.jl includes several functions for building graphs from specific data structures, including functions like `matrix_to_graph`, `symmetric_matrix_to_graph`, and `tensor_graph` which build specific graph structures an save data to those structures. 

Datagraphs.jl also includes functions for manipulating graph structure and analyzing the resulting topology of those structures. Functions `filter_nodes`, `filter_edges`, or `aggregate` change the graph structure based on the arguments passed to the functions. There are also functions such as `get_EC`, `run_EC_on_nodes`, and `run_EC_on_edges` that get the Euler Characteristic or the Euler Characteristic Curve for a graph, and other functions such as `cycle_basis`, `diameter`, or `average_degree` (largely extensions of Graphs.jl) for finding other topological descriptors. 

Support for `DataDiGraph`s is still underway. However, for `DataGraph` objects, all functions shown above have doc strings, which can be accessed through the REPL by first typing `?` and then the function or object name. 

## Getting Started

A `DataGraph` can be initiated by calling 

```julia
dg = DataGraph()
```

DataGraphs.jl also supports building a `DataGraph` from an adjacency matrix. The `DataGraph` can be changed by adding nodes or edges to the graph, as shown below. `add_node!` takes two arguments: the `DataGraph` of interest and the node name (any data type is permitted). `add_edge` takes three arguments, the `DataGraph` of interest, and the names of two nodes in the graph. 

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

Note that for `DataGraph`s, the order of the edges is not important, but it is important for `DataDiGraph`s. 

There are also functions for direclty building a graph from a set of data. Examples are shown below.

```julia
random_matrix = rand(20, 20)

matrix_graph = matrix_to_graph(random_matrix, "matrix_weight")

symmetric_random_matrix = random_matrix .+ random_matrix'

symmetric_matrix_graph = symmetric_matrix_to_graph(symmetric_random_matrix, "matrix_weight")

random_tensor = rand(20, 20, 15)

tensor_graph = tensor_to_graph(random_tensor)
```

## Further Examples

To see additional examples of how DataGraphs.jl can be used or applied, please see the [examples](https://github.com/dlcole3/DataGraphs.jl/tree/main/examples) directory within this repository.