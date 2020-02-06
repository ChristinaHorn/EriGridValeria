using LinearAlgebra
using DelimitedFiles
using Plots
using FFTW

################################################################################
# USABLE FOR TESTCASE 2 & 5 & 6
################################################################################


# struct and function definitions
################################################################################
include("Definitions.jl")
################################################################################

# read csv files for slack and load and transform to phasor representation
################################################################################
path = "/home/kogler/Julia/tecnalia/Data_reduced/Testcase2/TC2.1.txt"
file = collect(eachrow(readdlm(path, ',', Float64, header=false)))
slack_meas = measurement(file[1:7]...)
load_meas = measurement(file[[1;8:13]]...)
fac = 1.1/sqrt(3.0)
inverter_meas = measurement(file[1], fac*file[14:15]..., -fac*(file[14].+file[15]),
                                -(file[5:7].+file[11:13])...)

slack = toComplex(slack_meas)
load = toComplex(load_meas)
inverter = toComplex(inverter_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
#tspan = (1., 98.) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
p1 = plot(slack.t[idx], [slack.uAmp[idx], load.uAmp[idx], inverter.uAmp[idx]], ylabel="|u| [pu]", label="")
#p2 = plot(slack.t[idx], [slack.iAmp[idx], load.iAmp[idx], inverter.iAmp[idx]], ylabel="|i [pu]|", label="")
p3 = plot(slack.t[idx], [slack.f[idx], load.f[idx], inverter.f[idx]], ylabel="f [Hz]", label="")
p4 = plot(slack.t[idx], [-slack.P[idx], -load.P[idx], -inverter.P[idx]], ylabel="P [pu]", label="")
leg = plot([0 0 0], showaxis = false, grid = false, label = ["Slack" "Load" "Inverter"])
plot(leg, p1, p3, p4, layout=(4,1), legend=:top)
#savefig("Scenario5-25_results") # save as .png

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
# savefig("Scenario2a-4_results") # save as .png
