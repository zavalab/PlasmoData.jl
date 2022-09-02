function plot_graph(g::DataGraph;
    get_new_positions::Bool=false,
    plot_edges::Bool=true,
    C::Real=1.0,
    K::Real=.1,
    iterations::Int=300,
    tol::Real=.1,
    xdim = 800,
    ydim = 800,
    linewidth = 1,
    linealpha = 1,
    legend::Bool = false,
    color = :blue,
    markercolor = :black,
    markersize = 5
)

    plt_options = Dict(:framestyle => :box, :grid => false, :size => (xdim,ydim), :axis => nothing, :legend => legend)
    line_options = Dict(:linecolor => color, :linewidth => linewidth, :linealpha => linealpha)

    am = create_adj_mat(g)

    if get_new_positions || length(g.node_positions) <= 1
        pos = NetworkLayout.sfdp(Graphs.SimpleGraph(am); tol = tol, C = C, K = K, iterations = iterations)
        g.node_positions = pos
    else
        pos = g.node_positions
    end

    plt = scatter([i[1] for i in pos], [i[2] for i in pos];markercolor=markercolor, markersize=markersize, plt_options...)

    if plot_edges
        for i in g.edges
            from = i[1]
            to   = i[2]

            plot!(plt,[pos[from][1], pos[to][1]], [pos[from][2], pos[to][2]]; line_options...)
        end
    end
    display(plt)
end

function set_matrix_node_positions(nodes, mat)
    dim1, dim2 = size(mat)

    positions = []
    for i in 1:length(nodes)
        node_val  = nodes[i]
        node_x    = Float64(node_val[2] * 5)
        node_y    = Float64((dim1 - node_val[1] * 5))
        push!(positions, Point(node_x, node_y))
    end

    return positions
end
