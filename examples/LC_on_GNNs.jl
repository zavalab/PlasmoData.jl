using Revise
using DataGraphs, Graphs, Statistics, LinearAlgebra, SparseArrays, JLD, Random
using GraphNeuralNetworks, Flux, MLUtils
using Flux:onecold, onehotbatch
using Flux.Losses: logitbinarycrossentropy
using Flux.Data: DataLoader
using CUDA

# I have adapted the code from GraphNeuralNetworks.jl example which can be found at:
# https://github.com/CarloLucibello/GraphNeuralNetworks.jl/blob/master/examples/graph_classification_tudataset.jl
# If you do not have a GPU available, you may need to change the "usecuda" argument in line 57 to false
# Data used in this example is simulated data from Smith and Zavala, 2021
# https://doi.org/10.1016/j.compchemeng.2021.107463

# Define function to give testing and training loss and accuracy
function eval_loss_accuracy(model, data_loader, device)
    loss = 0.
    acc = 0.
    ntot = 0
    for (g, y) in data_loader
        g, y = (g, y) |> device
        n = length(y)
        ŷ = model(g, g.ndata.x) |> vec

        loss += logitbinarycrossentropy(ŷ, y) * n
        acc += mean((ŷ .> 0) .== y) * n
        ntot += n
    end
    return (loss = round(loss/ntot, digits=4), acc = round(acc*100/ntot, digits=2))
end

# Define function to load in the appropriate data and build the GNN graphs
function getdataset()
    data = load((@__DIR__)*"/simulated_LC_data.jld")["data"]

    graphs = []

    for i in 1:200
        datagraph = matrix_to_graph(data[i, :, :])
        gnn_graph = GNNGraph(datagraph.g,
            ndata = get_node_data(datagraph).data'
        )
        push!(graphs, gnn_graph)
    end

    y = vcat(zeros(100), ones(100))

    return graphs, y
end

# arguments for the `train` function
Base.@kwdef mutable struct Args
    η = 1f-3             # learning rate
    batchsize = 32      # batch size (number of graphs in each batch)
    epochs = 100         # number of epochs
    seed = 17             # set seed > 0 for reproducibility
    usecuda = true      # if true use cuda (if available)
    nhidden = 32        # dimension of hidden features
    infotime = 2 	     # report every `infotime` epochs
end

# Define function to train the data over each epoch
function train(; kws...)
    args = Args(; kws...)
    args.seed > 0 && Random.seed!(args.seed)

    if args.usecuda && CUDA.functional()
        device = gpu
        args.seed > 0 && CUDA.seed!(args.seed)
        @info "Training on GPU"
    else
        device = cpu
        @info "Training on CPU"
    end

    # LOAD DATA
    NUM_TRAIN = 150

    dataset = getdataset()
    train_data, test_data = splitobs(dataset, at=NUM_TRAIN, shuffle=true)
    train_loader = DataLoader(train_data; args.batchsize, shuffle=true, collate=true)

    test_loader = DataLoader(test_data; args.batchsize, shuffle=false, collate=true)

    # DEFINE MODEL

    nin = size(dataset[1][1].ndata.x, 1)
    nhidden = args.nhidden

    model = GNNChain(GraphConv(nin => nhidden, relu),
                     GraphConv(nhidden => nhidden, relu),
                     GlobalPool(mean),
                     Dense(nhidden, 1))  |> device

    ps = Flux.params(model)
    opt = Adam(args.η)

    # LOGGING FUNCTION

    function report(epoch)
        train = eval_loss_accuracy(model, train_loader, device)
        test = eval_loss_accuracy(model, test_loader, device)
        println("Epoch: $epoch   Train: $(train)   Test: $(test)")
    end

    # TRAIN

    report(0)
    for epoch in 1:args.epochs
        for (g, y) in train_loader
            g, y = (g, y) |> device
            gs = Flux.gradient(ps) do
                ŷ = model(g, g.ndata.x) |> vec
                logitbinarycrossentropy(ŷ, y)
            end
            Flux.Optimise.update!(opt, ps, gs)
        end
        epoch % args.infotime == 0 && report(epoch)
    end

    return model
end

@time model = train()
