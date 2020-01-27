using LinearAlgebra
using CSV
using Plots
using FFTW

# global parameters
################################################################################
VBase = 400
PBase = 1e4
IBase = PBase/VBase
resolution = 1e-3
samplerate = trunc(Int, 1/resolution)
################################################################################

# struct and function definitions
################################################################################
include("Definitions.jl")
################################################################################

# read csv files for slack and load and transform to phasor representation
################################################################################
path = "/home/kogler/Julia/tecnalia/Tests_Day_1/TC1.1_Box1.csv"
file = CSV.File(path; delim=",", header=false)
slack_meas = measurement(file...)

path = "/home/kogler/Julia/tecnalia/Tests_Day_1/TC1.1_Box2.csv"
file = CSV.File(path; delim=",", header=false)
load_meas = measurement(file...)

# transfer quantities only measured for the slack but needed for phasor
load_meas.I1, load_meas.I2, load_meas.I3 = -slack_meas.I1, -slack_meas.I2, -slack_meas.I3

slack = toComplex(slack_meas)
load = toComplex(load_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
#tspan = (10., 10.5) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
p1 = plot(slack.t[idx], [slack.uAmp[idx], load.uAmp[idx]], ylabel="|u| [pu]")
p2 = plot(slack.t[idx], [slack.f[idx], load.f[idx]], ylabel="f [Hz]")
p3 = plot(slack.t[idx], [slack.P[idx], load.P[idx]], ylabel="P [pu]")
plot(p1, p2, p3, layout=(3,1), label=["Slack" "Load"], legend=:outertopright)
#savefig("Testcase1-1_results") # save as .png
