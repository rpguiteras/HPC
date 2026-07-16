prog def bootstrap_bias_correction, rclass 
version 17.0
syntax, ///
  num_groups(integer) n_g(integer) ///
  rho_100(integer)  pi1_100(integer) ///
  gamma1_100(integer) beta1_100(integer) ///
  [ ///
  num_bootstrap_reps(integer 20) ///
  num_proc(integer 4) ///
  max_converge_reps(integer 100) ///
  TESTing ///
  NOISily ///
  ]

  
tempfile simulation_data_group
tempfile simulation_data_hh
tempfile delta_hats 
tempfile bootstrap_results 

**# create data

loc rho    = round(`rho_100'/100, 0.01)
loc pi1    = round(`pi1_100'/100, 0.01)
loc beta1  = round(`beta1_100'/100, 0.01)
loc gamma1 = round(`gamma1_100'/100, 0.01)

sim_generate, ///
  temp_group("`simulation_data_group'") temp_hh("`simulation_data_hh'") ///
  num_groups(`num_groups') n_g(`n_g') ///
  rho(`rho') ///
  beta1(`beta1') gamma1(`gamma1') ///
  pi1(`pi1') ///
  `testing' 
  
desc, s   
sim_data_to_mata  

*# first-step FE logit

sim_step1_logitfe_estimate , ///
  temp_group("`simulation_data_group'") temp_hh("`simulation_data_hh'") ///
  temp_delta("`delta_hats'")


loc beta0_hat = `r(beta0_hat)'
loc beta1_hat = `r(beta1_hat)'
  
  
**# 2SLS in Stata 
sim_step2_tsls_stata , ///
  temp_group("`simulation_data_group'") ///
  temp_hh("`simulation_data_hh'") ///
  temp_delta("`delta_hats'")

ret li 

loc gamma0_hat = r(gamma0_hat)
loc gamma1_hat = r(gamma1_hat)

  
parallel initialize `num_proc'

loc success = 0 
loc attempt = 1

while `success'==0 {

cap parallel sim, ///
  expr( ///
    pi1_hat_BS    = r(pi1_hat_BS)  ///
    pi1_hat_se_BS = r(pi1_hat_se_BS) ///
    gamma0_hat_BS = r(gamma0_hat_BS) ///
    gamma1_hat_BS = r(gamma1_hat_BS) ///
    beta1_hat_BS  = r(beta1_hat_BS) ///
  ) /// end expr()
  reps(`num_bootstrap_reps') `noisily'  ///
  saving("`bootstrap_results'", replace) ///
  : ///
  sim_bootstrap_simulation, ///
    temp_group("`simulation_data_group'") temp_hh("`simulation_data_hh'") ///
    num_groups(`num_groups')  n_g(`n_g') ///
    beta0_hat(`beta0_hat') beta1_hat(`beta1_hat') ///
    gamma0_hat(`gamma0_hat') gamma1_hat(`gamma1_hat') ///
    `noisily'

if _rc==0 {
  noi di `"** succeeded on attempt `attempt' **"'

  loc my_pll_id `r(pll_id)'
  parallel clean, event(`my_pll_id')

  use `bootstrap_results', clear 

  foreach param in gamma0 gamma1 beta1 {
    ret scal `param'_hat = ``param'_hat'
    summ `param'_hat_BS, meanonly 
    loc mean_`param'_hat_BS = r(mean)
    ret scal mean_`param'_hat_BS = `mean_`param'_hat_BS'
    loc B_`param'_hat_BS = `mean_`param'_hat_BS' - ``param'_hat'
    ret scal B_`param'_hat_BS = `B_`param'_hat_BS'
    loc `param'_hat_bc = ``param'_hat' - `B_`param'_hat_BS'
    ret scal `param'_hat_bc = ``param'_hat_bc'
  }
  
  loc success = 1
}
else {
  di `"** attempt `attempt' failed"'
  loc success = 0
  loc ++attempt
  
  loc tosleep = 2
  di `"** wait `tosleep' seconds to try again"'
  sleep `tosleep'
}

} // end while

end 

