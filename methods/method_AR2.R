library(rjags)
library(coda)
setwd("~/Desktop/School/2022/stat_520/stat520_project/")
source("retrieve_data.R")

model.loc <- ("AR2.txt")
jagsscript <- cat("
model {  
   # priors on parameters
   u ~ dnorm(0, 0.001); 
   inv.q ~ dgamma(0.001,0.001); 
   
   q <- 1/inv.q;
   inv.r ~ dgamma(0.001,0.001);
   
   r <- 1/inv.r; 
   
   X0 ~ dnorm(Y1, 0.001);
   
   # likelihood
   X[1] ~ dnorm(X0 + u, inv.q);
   Y[1] ~ dnorm(X[1], inv.r);
   X[2] ~ dnorm(X[1] + u, inv.q);
   Y[2] ~ dnorm(X[2], inv.r)
   
   for(t in 3:N) {
      X[t] ~ dnorm(X[t-2] + X[t-1] + u, inv.q);
      Y[t] ~ dnorm(X[t], inv.r); 
   }
}  
",  file = model.loc)

jags.data <- list("Y" = covid$before/1000, "N" = N, "Y1" = covid$before[1]/1000)
jags.params <- c("q", "r", "u")

mod_ss <- jags.model(file = model.loc, data=jags.data)

update(mod_ss, n.iter = 5000)
run_jag <- coda.samples(mod_ss, c("u"), n.iter=100000)

summary(run_jag)