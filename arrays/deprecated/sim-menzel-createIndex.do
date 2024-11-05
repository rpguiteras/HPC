version 17.0
loc name_do "sim-menzel-createIndex"

loc mySeed 655183 // random.org, 2024-10-22 23:19:41 UTC
set seed `mySeed'


cap drop _all 

tempname myName 
tempfile myFile 

loc beta1_100  100
  
// social multiplier parameter 
loc gamma1_100_values "0(25)150" 

// endogeneity
loc rho_100_values "20(20)60"

// first stage parameter
loc pi1_100_values "40(20)80"

loc n_g_levels "30(5)40"
loc num_groups_levels "300(50)400"


set tracedepth 1 
set trace off
postfile `myName' ///
  int(beta1_100 gamma1_100 num_groups n_g rho_100 pi1_100) ///
  using `myFile'

forvalues gamma1_100 = `gamma1_100_values' {
  
  forvalues num_groups = `num_groups_levels' {

    forvalues rho_100 = `rho_100_values' {

      forvalues pi1_100 = `pi1_100_values' {
          
        forvalues n_g = `n_g_levels' {
        
post `myName' ///
  (`beta1_100') (`gamma1_100') (`num_groups') (`n_g') (`rho_100') (`pi1_100')
    
  
        } // end loop over n_g 
        
      } // end loop over pi1  
      
    } // end loop over rho                  

  } // end loop over num_groups 

} // end loop over gamma1_100


postclose `myName'

use `myFile'
desc, f 

gen long seed = runiformint(1,1000000000)
isid seed 

// within gamma1, longest (most groups) first 
gsort gamma1_100 - num_groups - n_g  rho_100 pi1_100 
gen long index = _n 
sort index 
order index 
qui compress 

save "output/data/sim-menzel-index.dta", replace 

desc, f 

tab gamma1_100

exit 
