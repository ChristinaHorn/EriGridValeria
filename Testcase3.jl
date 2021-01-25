using LinearAlgebra
using DelimitedFiles
using FFTW
using PyPlot

################################################################################
# USABLE FOR TESTCASE 3 & 4
################################################################################

# struct and function definitions
################################################################################
include("Definitions.jl")
################################################################################

# read csv files for slack and load and transform to phasor representation
################################################################################
path = "/home/kogler/Julia/tecnalia/Data_reduced/Testcase3_bis/TC3b.3_bis.txt"
file = collect(eachrow(readdlm(path, ',', Float64, header=false)))
slack_meas = measurement(file[1:3]..., -(file[2].+file[3]), file[4:5]..., -(file[4].+file[5]))
load_meas = measurement(file[[1;6:7]]..., -(file[6].+file[7]), -file[8:9]..., (file[8].+file[9]))
fac = 1.087/sqrt(3.0)
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
tspan = (slack.t[1]+0.0, slack.t[end]-1.0) # plot whole test
#tspan = (20., 45.) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)

tt = slack.t[idx] .- slack.t[idx[1]]
data11 = [averageWin(inverter1.f, 1)[idx] averageWin(inverter2.f, 1)[idx] slack.f[idx] load.f[idx]]
data12 = [inverter1.P[idx] inverter2.P[idx] slack.P[idx] load.P[idx]]
data21 = [inverter1.uAmp[idx] inverter2.uAmp[idx] slack.uAmp[idx] load.uAmp[idx]]
data22 = [inverter1.Q[idx] inverter2.Q[idx] slack.Q[idx] load.Q[idx]]

matplotlib.rc("font", size=15.0)
fig, axs = plt.subplots(2, 2, sharex="col", figsize=(10,5))
subplots_adjust(hspace=0.2, wspace=0.35)
ax1, ax2, ax3, ax4 = axs
setp(axs, xlim=(tt[1], tt[end]))#, xticks=0:10:tt[end])
ax1.plot(tt, data11); ax1.set_ylabel("f [Hz]"); ax1.set_ylim(49.,51.)
ax2.plot(tt, data12)
ax2.set_xlabel("t [s]"); ax2.set_ylabel("P [pu]"); ax2.set_ylim(-3,3); ax2.set_yticks(-2:1:3)
ax3.plot(tt, data21); ax3.set_ylabel("V [pu]"); ax3.set_ylim(0.985,1.055)
ax4.plot(tt, data22)
ax4.set_xlabel("t [s]"); ax4.set_ylabel("Q [pu]"); ax4.set_ylim(-2.,2.); ax4.set_yticks(-2:2)
fig.legend(["CS Inverter", "VS Inverter", "Slack", "Load"], loc="upper center", ncol=4, borderaxespad=0.1)
ax1.grid(); ax2.grid(); ax3.grid(); ax4.grid()
fig.canvas.draw()
gcf()

#PyPlot.savefig("Scenario3b-5_results", dpi=400) # save as .png

# # no slack
# tt = slack.t[idx] .- slack.t[idx[1]]
# data11 = [averageWin(inverter1.f, 1)[idx] averageWin(inverter2.f, 1)[idx] load.f[idx]]
# data12 = [inverter1.P[idx] inverter2.P[idx] -load.P[idx]]
# data21 = [inverter1.uAmp[idx] inverter2.uAmp[idx] load.uAmp[idx]]
# data22 = [inverter1.Q[idx] inverter2.Q[idx] -load.Q[idx]]
#
# matplotlib.rc("font", size=15.0)
# fig, axs = plt.subplots(2, 2, sharex="col", figsize=(10,5))
# subplots_adjust(hspace=0.2, wspace=0.35)
# ax1, ax2, ax3, ax4 = axs
# setp(axs, xlim=(tt[1], tt[end]))#, xticks=0:10:tt[end])
# ax1.plot(tt, data11); ax1.set_ylabel("f [Hz]"); ax1.set_ylim(48,52.)
# ax2.plot(tt, data12)
# ax2.set_xlabel("t [s]"); ax2.set_ylabel("P [pu]"); ax2.set_ylim(-2,2); ax2.set_yticks(-2:1:2)
# ax3.plot(tt, data21); ax3.set_ylabel("V [pu]"); ax3.set_ylim(0.9,1.1)
# ax4.plot(tt, data22)
# ax4.set_xlabel("t [s]"); ax4.set_ylabel("Q [pu]"); ax4.set_ylim(-2.,2.); ax4.set_yticks(-2:2)
# fig.legend(["Inverter 1", "Inverter 2", "Load"], loc="upper center", ncol=4, borderaxespad=0.1)
# ax1.grid(); ax2.grid(); ax3.grid(); ax4.grid()
# fig.canvas.draw()
# gcf()
#
# #PyPlot.savefig("Scenario4a-4_results", dpi=400) # save as .png
