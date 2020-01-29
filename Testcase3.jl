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
path = "/home/kogler/Julia/tecnalia/Data_reduced/Testcase3/TC3.1.txt"
file = collect(eachrow(readdlm(path, ',', Float64, header=false)))
slack_meas = measurement(file[1:3]..., -(file[2].+file[3]), file[4:5]..., -(file[4].+file[5]))
load_meas = measurement(file[[1;6:7]]..., -(file[6].+file[7]), file[8:9]..., -(file[8].+file[9]))
fac = 1.1/sqrt(3.0)
inverter1_meas = measurement(file[1], fac*file[10:11]..., -fac*(file[10].+file[11]),
                                file[12:13]..., -(file[12].+file[13]))
inverter2_meas = measurement(file[1], fac*file[14:15]..., -fac*(file[14].+file[15]),
                                file[16:17]..., -(file[16].+file[17]))

slack = toComplex(slack_meas)
load = toComplex(load_meas)
inverter1 = toComplex(inverter1_meas)
inverter2 = toComplex(inverter2_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
#tspan = (1., 36.) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
p1 = plot(slack.t[idx], [slack.uAmp[idx], load.uAmp[idx], inverter1.uAmp[idx], inverter2.uAmp[idx]], ylabel="|u| [pu]", label="")
#p2 = plot(slack.t[idx], [slack.iAmp[idx], load.iAmp[idx], inverter1.iAmp[idx], inverter2.iAmp[idx]], ylabel="|i| [pu]", label="")
p3 = plot(slack.t[idx], [slack.f[idx], load.f[idx], inverter1.f[idx], inverter2.f[idx]], ylabel="f [Hz]", label="")
p4 = plot(slack.t[idx], [-slack.P[idx], -load.P[idx], inverter1.P[idx], inverter2.P[idx]], ylabel="P [pu]", label="")
leg = plot([0 0 0 0], showaxis = false, grid = false, label = ["Slack" "Load" "Inverter 1" "Inverter 2"])
plot(leg, p1, p3, p4, layout=(4,1), legend=:top)
#savefig("Scenario4b-4_results") # save as .png

# # without slack
# tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
# #tspan = (1., 99.) # plot specific time span (in seconds)
# idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
# p1 = plot(slack.t[idx], [load.uAmp[idx], inverter1.uAmp[idx], inverter2.uAmp[idx]], ylabel="|u| [pu]", label="")
# #p2 = plot(slack.t[idx], [slack.iAmp[idx], load.iAmp[idx], inverter1.iAmp[idx], inverter2.iAmp[idx]], ylabel="|i| [pu]", label="")
# p3 = plot(slack.t[idx], [load.f[idx], inverter1.f[idx], inverter2.f[idx]], ylabel="f [Hz]", label="")
# p4 = plot(slack.t[idx], [-load.P[idx], inverter1.P[idx], inverter2.P[idx]], ylabel="P [pu]", label="")
# leg = plot([0 0 0], showaxis = false, grid = false, label = ["Load" "Inverter 1" "Inverter 2"])
# plot(leg, p1, p3, p4, layout=(4,1), legend=:top)
# savefig("Scenario4a-4_results") # save as .png
