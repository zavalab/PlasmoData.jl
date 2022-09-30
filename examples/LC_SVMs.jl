using Revise
using DataGraphs, Graphs
using DelimitedFiles

# Read in the simulated liquid crystal (LC) data
# Data contains 100 x 100 matrices, with the first 100 corresponding to one
# environment, the last 100 corresponding to another environment
initial_data = readdlm((@__DIR__)*"/LC_data.csv", ',')

data = Array{Float64, 3}(undef, (200, 100, 100))

for i in 1:200
    range_values = (1 + (i - 1) * 100):(i * 100)
    data[i, :, :] = initial_data[range_values, :]
end

# Define the threshold of the EC curve
thresh = -1.0:.02:1.82

# Define a matrix for the EC curves
ECs = Array{Float64, 2}(undef, (200, length(thresh)))

# Build a graph from the matrix and compute the EC curve
for i in 1:200
    mat_graph = matrix_to_graph(data[i, :, :])

    ECs[i, :] = run_EC_on_nodes(mat_graph, thresh)
    println("Done with iteration $i")
end

# Define the data and their class
X = transpose(ECs)
y = vcat(-ones(100), ones(100))

# Classify the EC curves to environment 1 or 2 using SVMs
using LIBSVM

Xtrain = X[:, 1:2:end]
Xtest  = X[:, 2:2:end]
ytrain = y[1:2:end]
ytest  = y[2:2:end]

model = svmtrain(Xtrain, ytrain, kernel = Kernel.Linear)

yhat, decision_values = svmpredict(model, Xtest)

println("The error rate is $(sum(abs.(yhat .- ytest))/2 / 100)%" )

# Plot the average EC curves for environment 1 and 2
using Statistics, Plots

env1_avg = mean(X[:, 1:100], dims = 2)
env2_avg = mean(X[:, 101:end], dims = 2)

plt_avg = plot(thresh, env1_avg)
plot!(thresh, env2_avg)
display(plt_avg)

# Plot the individual EC curves
plt = plot(thresh, X[:, 1], color=:blue, legend=false, linewidth = .2)
for i in 2:100
    plot!(thresh, X[:, i], color=:blue, linewidth=.2)
end
for i in 101:200
    plot!(thresh, X[:, i], color=:red, linewidth=.2)
end
display(plt)

# Perform PCA and plot the results for environments 1 and 2
using MultivariateStats

M = fit(PCA, Xtrain; maxoutdim = 2, pratio = .99999)

Yte = MultivariateStats.predict(M, Xtest)

env1 = Yte[:, 1:50]
env2 = Yte[:, 51:100]

p = scatter(env1[1, :], env1[2,:], marker=:circle, linewidth=0)
scatter!(env2[1, :], env2[2, :], marker=:circle, linewidth=0)
plot!(p)
