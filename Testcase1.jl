using LinearAlgebra
using CSV
using Plots
using FFTW

VBase = 400
PBase = 1e4
IBase = PBase/VBase
resolution = 1e-3
samplerate = trunc(Int, 1/resolution)

# define structs for measurement data and complex phasor representation
################################################################################
mutable struct measurement
    t; U1; U2; U3; I1; I2; I3; P1; P2; P3; P; f; delta;
    U1Amp; U1Phi; U2Amp; U2Phi; U3Amp; U3Phi;
    I1Amp; I1Phi; I2Amp; I2Phi; I3Amp; I3Phi
end

mutable struct phasor
    t; u; uRot; uAmp; uPhi; i; iRot; iAmp; iPhi; P; Q; f; fAvg
end
################################################################################

# define transformations to complex phasor representation with post-processing
################################################################################
ABTransform = sqrt(2.0/3.0)*[1.0 -0.5 -0.5;
                             0.0 sqrt(3.0)*0.5 -sqrt(3.0)*0.5;
                             1.0/sqrt(2.0) 1.0/sqrt(2.0) 1.0/sqrt(2.0)]

function averageWin(data, winSize::Int)
    output = copy(data)
    for k in 1:length(data)-winSize
        output[k] = sum(data[k:k+winSize-1])/winSize
    end
    return output
end

function getFreqAvg(data, rate)
    data_fft = rfft(data)
    val, fInd = findmax(abs2.(data_fft[2:end]))
    fSteps = rfftfreq(length(data), rate)
    fAvgOut = fSteps[fInd+1]
    return fAvgOut
end

function getFreqInst(data, res, rate)
    len = length(data)
    ddt1 = zeros(len)
    ddt3 = zeros(len)
    for k in 3:len-2
        ddt1[k] = (data[k+1] - data[k-1])/(2.0*res)
        ddt3[k] = (data[k+2]/2.0 - data[k+1] + data[k-1] - data[k-2]/2.0)/res^3
    end
    fInstOut = (ddt1 .- res^2/6.0*ddt3)/(2.0*pi)
    return fInstOut
end

function ToComplex(meas::measurement)
    fAvg = getFreqAvg(Array{Float64}(meas.U1), samplerate)
    win = trunc(Int, 1/(resolution*fAvg))
    u_ab = ABTransform*transpose(hcat(meas.U1, meas.U2, meas.U3))
    u = (u_ab[1,:] .+ im*u_ab[2,:])/VBase
    uRot = u.*exp.(im*2*pi*fAvg*meas.t)
    uRotAvg = averageWin(uRot, win)
    uAmp = abs.(uRotAvg)
    uPhi = angle.(uRotAvg)
    i_ab = ABTransform*transpose(hcat(meas.I1, meas.I2, meas.I3))
    i = (i_ab[1,:] .+ im*i_ab[2,:])/IBase
    iRot = i.*exp.(im*2*pi*fAvg*meas.t)
    iRotAvg = averageWin(iRot, win)
    iAmp = abs.(iRotAvg)
    iPhi = angle.(iRotAvg)
    f = fAvg .+ getFreqInst(uPhi, resolution, samplerate)
    S = uRotAvg.*conj.(iRotAvg)
    P = real.(S)
    Q = imag.(S)
    return phasor(meas.t, u, uRot, uAmp, uPhi, i, iRot, iAmp, iPhi, P, Q, f, fAvg)
end
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

slack = ToComplex(slack_meas)
load = ToComplex(load_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1]+1.0, slack.t[end]-1.0) # plot whole test
tspan = (10., 10.5) # plot specific time span (in seconds)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
p1 = plot(slack.t[idx], [slack.uAmp[idx], load.uAmp[idx]], ylabel="|u| [pu]")
p2 = plot(slack.t[idx], [slack.f[idx], load.f[idx]], ylabel="f [Hz]")
p3 = plot(slack.t[idx], [slack.P[idx], load.P[idx]], ylabel="P [pu]")
plot(p1, p2, p3, layout=(3,1), label=["Slack" "Load"], legend=:outertopright)
#savefig("Testcase1-1_results") # save as .png
