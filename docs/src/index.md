# PlasmoData

PlasmoData.jl is a package for [Julia](https://julialang.org/) designed for representing and modeling data as graphs and for building graph models that contain large amounts of data on the nodes or edges of the graph. This package also has an accompanying package [DataGraphPlots.jl](https://github.com/zavalab/DataGraphPlots.jl) which can be used for plotting the graphs. 

## Installation

To install this package, you can use 

```julia
using Pkg
Pkg.add(url="https://github.com/zavalab/PlasmoData.jl")
```

or

```julia
pkg> add https://github.com/zavalab/PlasmoData.jl
```

## Overview

PlasmoData.jl is designed to store data within the graph structure and to manipulate that graph based on the data. It extends the package [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl), which is a highly optimized and efficient package in Julia. PlasmoData.jl enables representing datasets (such as matrices, images, or tensors) as graphs and for performing some topological data analysis (TDA). Some of these concepts can be found in [this paper](https://www.sciencedirect.com/science/article/pii/S0098135421002416?ref=pdf_download&fr=RR-2&rr=76810ff31b5361c2).

PlasmoData.jl uses an object `DataGraph` (or `DataDiGraph` for directed graphs) to store information. These objects contain the following features:

 * `g`: `SimpleGraph` (or `SimpleDiGraph` for directed graphs) containing the graph structure.
 * `nodes`: A vector of nodes, where the entries of the vector are node names. These names are of type `Any` so that the nodes can use a variety of naming conventions (strings, symbols, tuples, etc.)
 * `edges`: A vector of tuples, where each tuple contains two entries, where each entry relates to a node. 
 * `node_map`: A dictionary that maps the node names to their index in the `nodes` vector
 * `edge_map`: A dictionary that maps the edges to their index in the `edges` vector.
 * `node_data`: An object of type `NodeData` that includes a matrix of data, where the first dimension of the matrix corresponds to the node, and the second dimension corresponds to attributes for the nodes. Any number of attributes is allowed, and `NodeData` also includes attribute names and a mapping of the attribute name to the column of the data matrix. 
 * `edge_data`: An object of type `EdgeData` that includes a matrix of data, where the first dimension fo the matrix corresponds to the edges, and the second dimension corresponds to attributes for the edges. Any number of attributes is allowed, and `EdgeData` also includes attribute names and a mapping of the attribute name to the column of the data matrix. 
 * `graph_data`: An object of type `GraphData` that includes a vector of data whose dimension corresponds to the number of attributes for the graph. Any number of attributes is allowed, and `GraphData` also includes attribute names and a mapping of the attribute name to the entry in the vector. 

PlasmoData.jl includes several functions for building graphs from specific data structures, including functions like `matrix_to_graph`, `symmetric_matrix_to_graph`, and `tensor_graph` which build specific graph structures an save data to those structures. 

PlasmoData.jl also includes functions for manipulating graph structure and analyzing the resulting topology of those structures. Functions `filter_nodes`, `filter_edges`, or `aggregate` change the graph structure based on the arguments passed to the functions. There are also functions such as `get_EC`, `run_EC_on_nodes`, and `run_EC_on_edges` that get the Euler Characteristic or the Euler Characteristic Curve for a graph, and other functions such as `cycle_basis`, `diameter`, or `average_degree` (largely extensions of Graphs.jl) for finding other topological descriptors. 

Support for `DataDiGraph`s is still underway. However, for `DataGraph` objects, all functions shown above have doc strings, which can be accessed through the REPL by first typing `?` and then the function or object name. 


## Bug Reports and Support

This package is under development, and significant changes will continue to come. If you encounter any issues or bugs, please submit them through the [Github issue tracker](https://github.com/zavalab/PlasmoData.jl/issues). 
