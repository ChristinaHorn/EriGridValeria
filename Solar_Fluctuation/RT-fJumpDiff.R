
#### The stochastic group of Oldenburg University (TWiSt)
#### Date: 10/03/2013
#### Numerical simulation for solving the anti-correlated jump-diffusion model
#### To run this program first you must install 'zoo' package
####
#### Inputs:
#### N: The size of timeseries ( for cleaysky index) 
#### no: If it is 1 there is a jump and if it is 0 it will be no jumps in process
#### s: If s=1 there is a potential symmetry in process and if s=0 there will be potential non-
#### symmetry
#### ns: It relates to potential non-symmetry. If s=1 it should be 0 and if s=0 it should be 1
#### cld: It is 0 for sunny day and 1 for cloudy day (choose no=0)
#### sund: It is 1 fo sunny day and 0 for cloudy day (choose no=0)
#### Dt: The value of time-step
#### alpha: The value of steepness of potential
#### Diff: The coefficient for Diffusion
#### lambda: The value of jump rate   
####
#### Outputs 
#### ma: a vector of produced solar irradiance. The value is between 


fJumpDiff = function(N, no=1, s=0, ns=1, cld=0, sund=0, Dt=0.01, alpha=0.021, Diff=0.15, lambda=0.01){
	library(zoo)
	#### The initial value of time
	t0 = 0
	#### The initial value of solar irradiance  
	x0 = -0.2 
	#### The total time of calculations
	T = N * Dt
	#### The function of drift coefficient (a=a(t,x(t)))
	a = expression(alpha * (s * (-32 * x^3 + 4 * x) + ns * (-40 * x^3 + 4 * x + 0.3) + cld * (-20 * (x + 0.2)) + sund * (-20 * (x - 0.2))))  
	#### the function of diffusion (sigma = s(t,x(t)))
	sigma <- expression(Diff * sqrt(abs(x * (x + 0.4))))
	A = function(t,x)eval(a)
	S = function(t,x) eval(sigma)
	t = seq(t0, T, length = N+1)
	X = numeric(N+1)
	Y = numeric(N+1)
	X[1] = x0
	noise = numeric(N+1)
	#### To produce a poission noise for jump part
	noise = rpois(N+1,lambda) * (rnorm(N+1,mean=0,sd=100 ))
	n1 = which(noise!=0)
	U = length(n1)
	O = numeric(U)
	O[1] = -1  *  (-1)^{sund}
	
	for (l in 2:U) {O[l] = (-1)^(l)}
	for (m in 1:U) {noise[n1[m]] = abs(noise[n1[m]]) * O[m]}
	
	### To solve Jump-Diffusion equation
##############################################################################################################
	if(length(n1)==0){
		for (i in 2:N+2){
			u = rnorm(1,0,1)
			X[i] =  X[i-1] + A(t[i-1],X[i-1]) * Dt + S(t[i-1],X[i-1]) * u * sqrt(Dt) - no * sign(noise[i-1]) * ( Dt + 0.7) 

		}}
##############################################################################################################
	if(length(n1)!=0 && n1[1]!=1){
		
		for (i in 2:n1[1]){
			u = rnorm(1,0,1)
			X[i] =  X[i-1] + A(t[i-1],X[i-1]) * Dt + S(t[i-1],X[i-1]) * u * sqrt(Dt) - no * sign(noise[i-1]) * ( Dt + 0.7) 

		}}
##############################################################################################################

	u = rnorm(1,0,1)
	X[n1[1]+1] = X[n1[1]] + A(t[n1[1]],X[n1[1]]) * Dt + S(t[n1[1]],X[n1[1]]) * u * sqrt(Dt) - no * sign(noise[n1[1]]) * ( Dt + 0.7) 
	Y = X[n1[1]+1] 

##############################################################################################################
	if(U>=2){	
	for(k in 1:(U-1)){

		for(i in (n1[k]+2):(n1[k+1])){
			u = rnorm(1,0,1)
			X[i] =  X[i-1] + ( A(t[i-1],X[i-1]) + 0.1 * Y ) * Dt + S(t[i-1],X[i-1]) * u * sqrt(Dt)  - no * sign(noise[i-1]) * ( Dt + 0.7)  
		}

		u = rnorm(1,0,1)
		X[n1[k+1]+1] =  X[n1[k+1]] + A(t[n1[k+1]],X[n1[k+1]]) * Dt + S(t[n1[k+1]],X[n1[k+1]]) * u * sqrt(Dt)  -  no * sign(noise[n1[k+1]]) * ( Dt + 0.7) 
		Y = X[n1[k+1]+1] 
	}}

	if(length(n1)!=0 && n1[U]!=N+1){

		for(i in (n1[U]+2):(N+1)){
			u = rnorm(1,0,1)
			X[i] =  X[i-1] + (A(t[i-1],X[i-1]) +  0.1* Y )*Dt + S(t[i-1],X[i-1]) * u * sqrt(Dt)  -  no * sign(noise[i-1]) * ( Dt + 0.7)  
		}}

	### To eliminate the negative values
	X = X + 0.65 
	X[1:(N+1)] = X[1:(N+1)] + rnorm(N+1,0,0.01)
	ma = rollmean(X, 10)
	return(ma)
	#y=ma
	#write.table(y, file = "~/Desktop/test.txt", row.names = FALSE , col.names = FALSE)
	}






