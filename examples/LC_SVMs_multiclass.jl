using Revise
using DataGraphs, Graphs
using Statistics, Plots
using JLD

# The data used in this example is from the paper Bao et al. 2022
# https://doi.org/10.1021/jacs.2c03424
data = load((@__DIR__)*"/SO2_grayscale_data.jld")["data"]
so2_classes = load((@__DIR__)*"/SO2_grayscale_data.jld")["classes"]

# Define the threshold of the EC curve
thresh = 0:.01:0.93

# Define a matrix for the EC curves
ECs = Array{Float64, 2}(undef, (length(thresh), 288))

# Build a graph from the matrix and compute the EC curve
for i in 1:288
    mat_graph = matrix_to_graph(data[i, :, :])

    ECs[:, i] = run_EC_on_nodes(mat_graph, thresh, scale = true)
end

Xs, ys = shuffleobs((ECs, so2_classes))

using MLUtils, LIBSVM

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
println("The average accuracy is ", mean(accuracy_values))

# Get the average of the EC curves

env1_avg = mean(ECs[:, (so2_classes .== 1)], dims = 2)
env2_avg = mean(ECs[:, (so2_classes .== 2)], dims = 2)
env3_avg = mean(ECs[:, (so2_classes .== 3)], dims = 2)
env4_avg = mean(ECs[:, (so2_classes .== 4)], dims = 2)

# Plot the individual EC curves
# env1 = .5 ppm, env2 = 1 ppm, env3 = 5 ppm, env4 = 2 ppm
plt = plot(thresh, ECs[:, 1], color=:blue, legend=:topright, label="0.5 ppm", linealpha=.5, linewidth = .3)
plot!(thresh, ECs[:, 73], color=:red, label="1.0 ppm", linealpha=.5, linewidth = .3)
plot!(thresh, ECs[:, 217], color = :orange, label = "2.0 ppm", linealpha = .5, linewidht = .3)
plot!(thresh, ECs[:, 145], color = :black, label = "5.0 ppm", linealpha = .5, linewidth = .3)
for i in 2:72
    plot!(thresh, ECs[:, i], color=:blue, linewidth=.3, label=:none, linealpha=.5)
end
for i in 74:144
    plot!(thresh, ECs[:, i], color=:red, linewidth=.3, label=:none, linealpha=.5)
end
for i in 146:216
    plot!(thresh, ECs[:, i], color=:black, linewidth=.3, label = :none, linealpha = .5)
end
for i in 218:288
    plot!(thresh, ECs[:, i], color=:orange, linewidth=.3, label = :none, linealpha = .5)
end
plot!(thresh, env1_avg, label = "0.5 ppm Average", color=:blue, linewidth = 2)
plot!(thresh, env2_avg, label = "1.0 ppm Average", color=:red, linewidth = 2)
plot!(thresh, env4_avg, label = "2.0 ppm Average", color = :orange, linewidth = 2)
plot!(thresh, env3_avg, label = "5.0 ppm Average", color = :black, linewidth = 2)
xlabel!("Threshold Value")
ylabel!("Euler Characteristic")
display(plt)
