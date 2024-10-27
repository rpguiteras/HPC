program define sim_menzel_wrapper_parallel
version 17.0

syntax, ///
  num_reps(integer) ///
  num_groups(integer) n_g(integer) ///
  beta1(real) gamma1(real) ///
  rho(real) pi1(real) ///
  myseed(integer) ///
  [ ///
  sigma(real 0.2) ///
  nu_scale(real 1) ///
  logit_scale(real 1) ///
  x_11_g_scale(real 0) ///
  TESTing ///
  ]
  

di `"** num_reps   = `num_reps'"'
di `"** num_groups = `num_groups'"'
di `"** n_g        = `n_g'"'
di `"** rho        = `rho'"'
di `"** beta1      = `beta1'"'
di `"** gamma1     = `gamma1'"'
di `"** pi1        = `pi1'"'
di `"** sigma      = `sigma'"'
di `"** myseed     = `myseed'"'
/*
if abs(`rho')>=1 {
  di as err `"** must have -1<rho<+1"'
  exit 999
}
*/
if "`testing'"=="testing" {
  di `"** option "testing" on, will append "-test" to output filenames "'
  loc testing_suffix "-test"
}

set seed `myseed'
local rngstate_initial = c(rngstate)

loc rho_100 = round(`rho'*100)
loc pi1_100 = round(`pi1'*100)
loc gamma1_100 = round(`gamma1'*100)

loc fileSuffix "NG`num_groups'-ng`n_g'-rho`rho_100'-pi1`pi1_100'-g1`gamma1_100'`testing_suffix'"

parallel initialize 4, force

if "`testing'"=="testing" {
  noisily {
    mata : c("seed")
  }
}

loc success = 0 
loc attempt = 1

while `success'==0 {

set seed `myseed'
local rngstate_initial = c(rngstate)

cap parallel sim, ///
  expr( ///
    beta1_hat          = r(beta1_hat)  ///
    beta1_se_hat       = r(beta1_se_hat) ///
    pi1_hat            = r(pi1_hat) ///
    pi1_hat_se         = r(pi1_hat_se) ///
    fs_Fstat           = r(fs_Fstat) ///
    gamma1_hat         = r(gamma1_hat) ///
    gamma1_hat_se_unc  = r(gamma1_hat_se_unc) ///
    gamma1_hat_se_jnt2 = r(gamma1_hat_se_jnt2) ///
    gamma1_hat_se_jnt  = r(gamma1_hat_se_jnt) ///
    gamma1_hat_se_jnt1 = r(gamma1_hat_se_jnt1) ///
    N_G_npp            = r(N_G_npp) ///
  ) /// end expr()
  reps(`num_reps') noisily randtype("current")  ///
  saving("temp/simulation_postfile-`fileSuffix'.dta", replace) ///
  : ///
    sim_menzel_onerep, ///
      num_groups(`num_groups') n_g(`n_g') ///
      beta1(`beta1') gamma1(`gamma1') ///
      rho(`rho') pi1(`pi1') sigma(`sigma') ///
      `testing'

if _rc==0 {
  noi di `"** succeeded on attempt `attempt' **"'
  noi ret li 
  loc my_pll_id `r(pll_id)'
  use "temp/simulation_postfile-`fileSuffix'.dta", clear 

  loc LocsToChars num_reps N_G n_g rho  ///
    logit_scale beta1 gamma1 pi1 sigma

  foreach LTC of local LocsToChars {
    char _dta[`LTC'] ``LTC''
  }
  char _dta[rngstate_initial] `rngstate_initial'

  save "output/data/sim_menzel/simulation_postfile-`fileSuffix'.dta", replace 
  rm "temp/simulation_postfile-`fileSuffix'.dta"

  desc, f 
  char li _dta[]

  summarize

  // remove auxiliary files
  parallel clean, event(`my_pll_id')
  loc success = 1
}
else {
  di `"** attempt `attempt' failed"'
  loc success = 0
  loc ++attempt
  
  loc tempseed = `myseed'+`attempt'
  set seed `tempseed'

  loc tosleep = runiformint(1,16)
  di `"** wait `tosleep' seconds to try again"'
  sleep `tosleep'
}

} // end while

end
