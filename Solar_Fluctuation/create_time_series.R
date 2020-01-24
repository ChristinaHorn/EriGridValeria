source("RT-fJumpDiff.R")

Dt = 0.01
N = 5000
power= fJumpDiff(N, no=1, s=0, ns=1, cld=0, sund=0, Dt, alpha=0.021, Diff=0.15, lambda=0.01)

n = length(power)
time = seq(from=0.0, to=(n-1)*Dt, by=Dt)

data = cbind(time, power)
write.csv(data, file = "solar_time_series.csv",row.names=FALSE)
