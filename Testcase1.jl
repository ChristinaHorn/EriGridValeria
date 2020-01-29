using LinearAlgebra
using DelimitedFiles
using Plots
using FFTW

# struct and function definitions
################################################################################
include("Definitions.jl")
################################################################################

# read csv files for slack and load and transform to phasor representation
################################################################################
path = "/home/kogler/Julia/tecnalia/Data_reduced/Testcase1/TC1.5.txt"
file = collect(eachrow(readdlm(path, ',', Float64, header=false)))
slack_meas = measurement(file[1:7]...)
load_meas = measurement(file[[1;8:10]]..., -file[5:7]...)

slack = toComplex(slack_meas)
load = toComplex(load_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
#tspan = (10., 10.5) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
p1 = plot(slack.t[idx], [slack.uAmp[idx], load.uAmp[idx]], ylabel="|u| [pu]", label="")
p2 = plot(slack.t[idx], [slack.f[idx], load.f[idx]], ylabel="f [Hz]", label="")
p3 = plot(slack.t[idx], [slack.P[idx], load.P[idx]], ylabel="P [pu]", label="")
leg = plot([0 0], showaxis = false, grid = false, label = ["Slack" "Load"])
plot(leg, p1, p2, p3, layout=(4,1), legend=:top)
#savefig("Scenario1-5_results") # save as .png
