using LinearAlgebra
using DelimitedFiles
using FFTW
using PyPlot

################################################################################
# USABLE FOR TESTCASE 2 & 5 & 6
################################################################################


# struct and function definitions
################################################################################
include("Definitions.jl")
################################################################################

# read csv files for slack and load and transform to phasor representation
################################################################################
path = "/home/kogler/Julia/tecnalia/Data_reduced/Testcase2/TC2.2.txt"
file = collect(eachrow(readdlm(path, ',', Float64, header=false)))
slack_meas = measurement(file[1:7]...)
load_meas = measurement(file[[1;8:13]]...)
fac = 1.087/sqrt(3.0)
inverter_meas = measurement(file[1], fac*file[14:15]..., -fac*(file[14].+file[15]),
                                -(file[5:7].+file[11:13])...)

slack = toComplex(slack_meas)
load = toComplex(load_meas)
inverter = toComplex(inverter_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
#tspan = (1., 76.) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)

tt = slack.t[idx] .- slack.t[idx[1]]
data11 = [averageWin(inverter.f, 1)[idx] slack.f[idx] load.f[idx]]
data12 = -[inverter.P[idx] slack.P[idx] load.P[idx]]
data21 = [inverter.uAmp[idx] slack.uAmp[idx] load.uAmp[idx]]
data22 = -[inverter.Q[idx] slack.Q[idx] load.Q[idx]]

matplotlib.rc("font", size=15.0)
fig, axs = plt.subplots(2, 2, sharex="col", figsize=(10,5))
subplots_adjust(hspace=0.2, wspace=0.35)
ax1, ax2, ax3, ax4 = axs
setp(axs, xlim=(tt[1], tt[end]))#, xticks=0:10:tt[end])
ax1.plot(tt, data11); ax1.set_ylabel("f [Hz]"); ax1.set_ylim(48.5,52.5)
ax2.plot(tt, data12)
ax2.set_xlabel("t [s]"); ax2.set_ylabel("P [pu]"); ax2.set_ylim(-4,4); ax2.set_yticks(-4:2:4)
ax3.plot(tt, data21); ax3.set_ylabel("V [pu]"); ax3.set_ylim(0.8,1.1)
ax4.plot(tt, data22)
ax4.set_xlabel("t [s]"); ax4.set_ylabel("Q [pu]"); ax4.set_ylim(-4.,4.); ax4.set_yticks(-4:2:4)
fig.legend(["Inverter", "Slack", "Load"], loc="upper center", ncol=3, borderaxespad=0.1)
ax1.grid(); ax2.grid(); ax3.grid(); ax4.grid()
fig.canvas.draw()
gcf()

#PyPlot.savefig("Scenario6-25_results", dpi=400) # save as .png

# # no slack
# tt = slack.t[idx] .- slack.t[idx[1]]
# data11 = [averageWin(inverter.f, 1)[idx] load.f[idx]]
# data12 = -[inverter.P[idx]  load.P[idx]]
# data21 = [inverter.uAmp[idx]  load.uAmp[idx]]
# data22 = -[inverter.Q[idx]  load.Q[idx]]
#
# matplotlib.rc("font", size=15.0)
# fig, axs = plt.subplots(2, 2, sharex="col", figsize=(10,5))
# subplots_adjust(hspace=0.2, wspace=0.35)
# ax1, ax2, ax3, ax4 = axs
# setp(axs, xlim=(tt[1], tt[end]))#, xticks=0:10:tt[end])
# ax1.plot(tt, data11); ax1.set_ylabel("f [Hz]"); ax1.set_ylim(49.,51.)
# ax2.plot(tt, data12)
# ax2.set_xlabel("t [s]"); ax2.set_ylabel("P [pu]"); ax2.set_ylim(-2.,2); ax2.set_yticks(-2:1:2)
# ax3.plot(tt, data21); ax3.set_ylabel("V [pu]"); ax3.set_ylim(0.9,1.)
# ax4.plot(tt, data22)
# ax4.set_xlabel("t [s]"); ax4.set_ylabel("Q [pu]"); ax4.set_ylim(-2.,2.); ax4.set_yticks(-2:2)
# fig.legend(["Inverter", "Load"], loc="upper center", ncol=3, borderaxespad=0.1)
# ax1.grid(); ax2.grid(); ax3.grid(); ax4.grid()
# fig.canvas.draw()
# gcf()
#
# PyPlot.savefig("Scenario2a-3_results", dpi=400) # save as .png
