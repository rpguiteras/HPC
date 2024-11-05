args index
version 17.0
loc name_do "sim-menzel-bsbc-simulate-index"


quietly {
  cap file close 
  cap log close _all
  cap timer off 1
  cap timer clear 1
  timer on 1 
  
  // generic setup tasks
  include "./code/setup/setup.do"
  // optional: .tex file with output macros
  // qui include code/setup/setup-output-macros.do

  loc name_log	"`name_do'-`index'"
  log using "temp/`name_log'-TEMP.smcl", ///
    replace name(local_log)
}

**# Introduction and description
/* *********************************************************************

simulate Menzel bias-correction as GMM 
add bootstrap bias-correction

101 24-10-30 rg first 
                based on sim-Menzel-bsbc-example.do
                  111 24-10-30
102 24-10-31 rg split up into 4
103 24-10-31 rg split up into 16
104 24-10-31 rg split up into 64
105 24-11-03 rg 8 cores
106 24-11-05 rg simulate with beta1=4, 4 cores
**********************************************************************/
loc version_do 106


/* ****************************************************************** */
**# common parameters 
/* ****************************************************************** */

use "output/data/sim-menzel-bsbc-index.dta", clear 

loc beta1_100 = beta1_100[`index']
loc beta1 = round(`beta1_100'/100,0.01)
di `"beta1 = `beta1'"'

loc gamma1_100 = gamma1_100[`index']
loc gamma1 = round(`gamma1_100'/100,0.01)
di `"gamma1 = `gamma1'"'

loc num_groups = num_groups[`index']

loc n_g = n_g[`index']

loc rho_100 = rho_100[`index']
loc rho = round(`rho_100'/100,0.01)
di `"rho = `rho'"'

loc pi1_100 = pi1_100[`index']
loc pi1 = round(`pi1_100'/100,0.01)
di `"pi1 = `pi1'"'

loc set = set[`index']

loc myseed = seed[`index']

di `myseed'

drop _all 


loc mysuffix NG-`num_groups'-ng-`n_g'-b1-`beta1_100'-g1-`gamma1_100'-rho-`rho_100'-pi1-`pi1_100'-set-`set'

di `"mysuffix: `mysuffix'"'


set seed `myseed'

/* ****************************************************************** */
**#	test simulations
/* ****************************************************************** */



if strpos(lower("`c(os)'"),"nix")!=0 {
  
  di `"on cluster, run full sims"'
  loc num_simulation_reps = 16
  loc num_bootstrap_reps  = 500
  loc noisily ""
  loc num_proc = 4
  loc test_suff ""
}
else {
  di `"not on cluster, run small-scale test sims"'
  loc num_simulation_reps = 5
  loc num_bootstrap_reps  = 8
  loc noisily "noisily"
  loc num_proc = 8
  loc test_suff "-test"
}

tempfile simulation_results

simulate ///
    gamma1_hat    = r(gamma1_hat) ///
    gamma1_hat_bc = r(gamma1_hat_bc) ///
    beta1_hat     = r(beta1_hat) ///
    beta1_hat_bc  = r(beta1_hat_bc) ///
  , reps(`num_simulation_reps') `noisily' ///
  saving("`simulation_results'", replace) : ///
  bootstrap_bias_correction , ///
    num_groups(`num_groups') n_g(`n_g') ///
    rho_100(`rho_100')  pi1_100(`pi1_100') ///
    gamma1_100(`gamma1_100') beta1_100(`beta1_100') ///
    num_bootstrap_reps(`num_bootstrap_reps') ///
    num_proc(`num_proc') `noisily'

    


use "`simulation_results'", clear 

loc all_args num_groups n_g beta1_100 gamma1_100 rho_100 pi1_100 myseed set 

foreach arg of local all_args {
  char _dta[`arg'] ``arg''
} 

char li _dta[] 

save "output/data/bsbc/bsbc-`mysuffix'`test_suff'.dta", replace 
desc, f 
summ 

cap rm `simulation_results'

/* ****************************************************************** */
**#	END
/* ****************************************************************** */
// qui include code/setup/close-output-macros.do
cap timer off 1
timer list
cap log close local_log
copy "temp/`name_log'-TEMP.smcl" ///
  "output/log/smcl/`name_log'.smcl", replace
rm "temp/`name_log'-TEMP.smcl"

exit
