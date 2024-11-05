version 17.0
loc name_do "sim-menzel-bsbc-compile-index"


tempname myName 
tempfile myFile 

set tracedepth 1 
set trace off
postfile `myName' ///
  int(beta1_100 gamma1_100 num_groups n_g rho_100 pi1_100) ///
  double( ///
    bias_beta1_hat bias_beta1_hat_bc bias_gamma1_hat bias_gamma1_hat_bc ///
    rmse_beta1_hat rmse_beta1_hat_bc rmse_gamma1_hat rmse_gamma1_hat_bc ///
  ) ///
  using `myFile'


loc beta1_100  100
  
// social multiplier parameter 
loc gamma1_100_values "0(100)100" 

// endogeneity
loc rho_100_values "20(20)60"

// first stage parameter
loc pi1_100_values "40(20)80"

loc n_g_levels "30(5)40"
loc num_groups_levels "300(50)400"


set tracedepth 1 
set trace off

forvalues gamma1_100 = `gamma1_100_values' {
  
  forvalues num_groups = `num_groups_levels' {

    forvalues rho_100 = `rho_100_values' {

      forvalues pi1_100 = `pi1_100_values' {
          
        forvalues n_g = `n_g_levels' {

loc mysuffix NG-`num_groups'-ng-`n_g'-b1-`beta1_100'-g1-`gamma1_100'-rho-`rho_100'-pi1-`pi1_100'

use "output/data/bsbc/bsbc-`mysuffix'-set-1.dta"

forvalues SET = 2/64 {
  append using "output/data/bsbc/bsbc-`mysuffix'-set-`SET'.dta"
}
 
loc beta1_true  = round(`beta1_100'/100,0.01)
loc gamma1_true = round(`gamma1_100'/100,0.01)

foreach PARAM in beta1 gamma1 {
foreach EST in hat hat_bc {

gen err_`PARAM'_`EST'     = `PARAM'_`EST' - ``PARAM'_true'
gen sqd_err_`PARAM'_`EST' = (err_`PARAM'_`EST')^2

summ  err_`PARAM'_`EST' 
loc  bias_`PARAM'_`EST' = r(mean)

summ sqd_err_`PARAM'_`EST' 
loc  mse_`PARAM'_`EST' = r(mean)

loc rmse_`PARAM'_`EST' = sqrt(`mse_`PARAM'_`EST'')
}
}

qui compress 
save "output/data/bsbc/bsbc-`mysuffix'.dta", replace
desc, s 


/*
  int(beta1_100 gamma1_100 num_groups n_g rho_100 pi1_100) ///
  double( ///
    bias_beta1_hat bias_beta1_hat_bc bias_gamma1_hat bias_gamma1_hat_bc ///
    rmse_beta1_hat rmse_beta1_hat_bc rmse_gamma1_hat rmse_gamma1_hat_bc ///
  ) ///
*/
post `myName' ///
  (`beta1_100') (`gamma1_100') ///
  (`num_groups') (`n_g') (`rho_100') (`pi1_100') ///
  (`bias_beta1_hat') (`bias_beta1_hat_bc') ///
  (`bias_gamma1_hat') (`bias_gamma1_hat_bc') ///
  (`rmse_beta1_hat') (`rmse_beta1_hat_bc') ///
  (`rmse_gamma1_hat') (`rmse_gamma1_hat_bc') 
  
  
  
        } // end loop over n_g 
        
      } // end loop over pi1  
      
    } // end loop over rho                  

  } // end loop over num_groups 

} // end loop over gamma1_100

desc, f

postclose `myName'

use `myFile'
desc, f 

save "output/data/sim-menzel-bsbc.dta", replace 


exit 
