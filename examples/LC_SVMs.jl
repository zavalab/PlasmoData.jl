using Revise
using DataGraphs, Graphs
using JLD

# Read in the simulated liquid crystal (LC) data from the paper Smith and Zavala 2021
# https://doi.org/10.1016/j.compchemeng.2021.107463
# Data contains 100 x 100 matrices, with the first 100 corresponding to one
# environment, the last 100 corresponding to another environment
data = load((@__DIR__)*"/simulated_LC_data.jld")["data"]

# Define the threshold of the EC curve
thresh = -1.0:.02:1.82

# Define a matrix for the EC curves
ECs = Array{Float64, 2}(undef, (length(thresh), 200))

# Build a graph from the matrix and compute the EC curve
for i in 1:200
    mat_graph = matrix_to_graph(data[i, :, :])

    ECs[:, i] = run_EC_on_nodes(mat_graph, thresh; scale = true)
end

# Define the class data
y = vcat(-ones(100), ones(100))

using MLUtils, LIBSVM

# Shuffle data for k-fold CV
Xs, ys = shuffleobs((ECs, y))

# Define function for testing accuracy
function get_accuracy(yhat, ytest)
    num_errors = 0
    for i in 1:length(yhat)
        if yhat[i] != ytest[i]
            num_errors += 1
        end
    end
    return 1 - num_errors / length(yhat)
end

# Perform 5-fold CV
accuracy_values = []
for (train_data, val_data) in kfolds((Xs, ys); k = 5)
    model = svmtrain(train_data[1], train_data[2], kernel = Kernel.Linear)
    yhat, decision_values = svmpredict(model, val_data[1])

    accuracy = get_accuracy(yhat, val_data[2])
    push!(accuracy_values, accuracy)
end

println(accuracy_values)


# Plot the average EC curves for environment 1 and 2
using Statistics, Plots

env1_avg = mean(ECs[:, 1:100], dims = 2)
env2_avg = mean(ECs[:, 101:end], dims = 2)

plt_avg = plot(thresh, env1_avg)
plot!(thresh, env2_avg)
display(plt_avg)

# Plot the individual EC curves
plt = plot(thresh, ECs[:, 1], color=:blue, legend=:topright, linewidth = .2, label="Env 1", linealpha=.5)
plot!(thresh, ECs[:, 101], color=:red, label="Env 2", linealpha=.5)
for i in 2:100
    plot!(thresh, ECs[:, i], color=:blue, linewidth=.2, label=:none, linealpha=.5)
end
for i in 102:200
    plot!(thresh, ECs[:, i], color=:red, linewidth=.2, label=:none, linealpha=.5)
end
plot!(thresh, env1_avg, label="Env 1 Average", color=:black)
plot!(thresh, env2_avg, label="Env 2 Average", color=:darkred)
xlabel!("Threshold Value")
ylabel!("Euler Characteristic")
display(plt)

# Perform PCA and plot the results for environments 1 and 2
using MultivariateStats

Xtrain = ECs[:, 1:2:end]
Xtest  = ECs[:, 2:2:end]
ytrain = y[1:2:end]
ytest  = y[2:2:end]

M = fit(PCA, Xtrain; maxoutdim = 2, pratio = .99999)

Yte = MultivariateStats.predict(M, Xtest)

env1 = Yte[:, 1:50]
env2 = Yte[:, 51:100]

p = scatter(env1[1, :], env1[2,:], marker=:circle, markersize = 5, legend=#=:topleft=#:none, linewidth=0, label="Env 1", xaxis = nothing, yaxis = nothing)
scatter!(env2[1, :], env2[2, :], marker=:circle, linewidth=0, label= "Env 2", markersize = 5)
plot!(p)
xlabel!("Principal Component 1")
ylabel!("Principal Component 2")
