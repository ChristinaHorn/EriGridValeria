### Time Series for Fluctuating Solar Power

The time series for solar fluctuating power is created with an R script. It basically just calls Mehrnaz' jump diffusion model [1] and creates a csv-file as the output.

#### Files

* script: *create_time_series.R*
* jump diffusion model: *RT-fJumpDiff.R*
* output file: *solar_time_series.csv*

#### How to run the script

On Ubuntu or Linux Mint R can be easily installed in the terminal by

    >>> sudo apt-get install r-base

Further, the zoo-package needs to be installed.

	>>> R
	>R> install.packages("zoo")
	>R> q()
	Save workspace image? [y/n/c]: n

The script can then be executed by

	>>> Rscript create_time_series.R

#### Reference

[1] Anvari, M., et al. "Suppressing power output fluctuations of photovoltaic power plants." *Solar Energy* 157 (2017): 735-743.


