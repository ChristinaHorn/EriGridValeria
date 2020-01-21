using LinearAlgebra
using CSV
using Plots


# define structs for measurement data and complex phasor representation
################################################################################
mutable struct measurement
    t; U1; U2; U3; I1; I2; I3; P1; P2; P3; P; f; delta;
    U1Amp; U1Phi; U2Amp; U2Phi; U3Amp; U3Phi;
    I1Amp; I1Phi; I2Amp; I2Phi; I3Amp; I3Phi
end

mutable struct phasor
    t; u; uRot; uAmp; uPhi; i; iRot; iAmp; iPhi; P; Q; f
end
################################################################################

# define transformations to complex phasor representation
################################################################################
ABTransform = sqrt(2.0/3.0)*[1.0 -0.5 -0.5;
                             0.0 sqrt(3.0)*0.5 -sqrt(3.0)*0.5;
                             1.0/sqrt(2.0) 1.0/sqrt(2.0) 1.0/sqrt(2.0)]

function ToComplex(meas::measurement)
    u_ab = ABTransform*transpose(hcat(meas.U1, meas.U2, meas.U3))
    u = u_ab[1,:] .+ im*u_ab[2,:]
    f = meas.f
    uRot = u.*exp.(im*2*pi*50.0*meas.t)
    uAmp = abs.(uRot)
    uPhi = angle.(uRot)
    i_ab = ABTransform*transpose(hcat(meas.I1, meas.I2, meas.I3))
    i = i_ab[1,:] .+ im*i_ab[2,:]
    iRot = i.*exp.(im*2*pi*50.0*meas.t)
    iAmp = abs.(iRot)
    iPhi = angle.(iRot)
    S = uRot.*conj.(iRot)
    P = real.(S)
    Q = imag.(S)
    return phasor(meas.t, u, uRot, uAmp, uPhi, i, iRot, iAmp, iPhi, P, Q, f)
end
################################################################################

# read csv files for slack and load and transform to phasor representation
################################################################################
path = "/home/kogler/Julia/tecnalia/Tests_Day_1/TC1.3_Box1.csv"
file = CSV.File(path; delim=",", header=false)
slack_meas = measurement(file...)

path = "/home/kogler/Julia/tecnalia/Tests_Day_1/TC1.3_Box2.csv"
file = CSV.File(path; delim=",", header=false)
load_meas = measurement(file...)

# transfer quantities only measured for the slack but needed for phasor
load_meas.I1, load_meas.I2, load_meas.I3 = -slack_meas.I1, -slack_meas.I2, -slack_meas.I3

slack = ToComplex(slack_meas)
load = ToComplex(load_meas)
################################################################################

# plots
################################################################################
tspan = (slack.t[1], slack.t[end])
#tspan = (10., 12.)
idx = findall(x -> x>=tspan[1] && x<=tspan[2], slack.t)
p1 = plot(slack.t[idx], [slack.uAmp[idx], load.uAmp[idx]], ylabel="|U|")
p2 = plot(slack.t[idx], slack.iAmp[idx], ylabel="|I|")
p3 = plot(slack.t[idx], [slack.f[idx], load.f[idx]], ylabel="f")
p4 = plot(slack.t[idx], [slack.P[idx], load.P[idx]], ylabel="P")
plot(p1, p2, p3, p4, layout=(4,1), label=["Slack" "Load"])

