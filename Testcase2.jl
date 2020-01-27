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
path = "/home/kogler/Julia/tecnalia/Tests_Day_2/TC2a.4_Box1.csv"
file1 = CSV.File(path; delim=",", header=false)
slack_meas = measurement(file1[1:7]...)

path = "/home/kogler/Julia/tecnalia/Tests_Day_2/TC2a.4_Box2.csv"
file2 = CSV.File(path; delim=",", header=false)
load_meas = measurement(file2[1:7]...)

fac = 1.1/sqrt(3.0)
inverter_meas = measurement(file1[1], file2[end]*fac, file1[end]*fac,
                -fac*(file1[end] .+ file2[end]), -(slack_meas.I1 .+ load_meas.I1),
                -(slack_meas.I2 .+ load_meas.I2), -(slack_meas.I3 .+ load_meas.I3))

slack = toComplex(slack_meas)
load = toComplex(load_meas)
inverter = toComplex(inverter_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
#tspan = (11.22, 11.27) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
p1 = plot(slack.t[idx], [slack.uAmp[idx], load.uAmp[idx], inverter.uAmp[idx]], ylabel="|U|")
p2 = plot(slack.t[idx], [slack.iAmp[idx], load.iAmp[idx], inverter.iAmp[idx]], ylabel="|I|")
p3 = plot(slack.t[idx], [slack.f[idx], load.f[idx], inverter.f[idx]], ylabel="f")
p4 = plot(slack.t[idx], [-slack.P[idx], -load.P[idx], -inverter.P[idx]], ylabel="P")
plot(p1, p2, p3, p4, layout=(4,1), label=["Slack" "Load" "Inverter"])
################################################################################
