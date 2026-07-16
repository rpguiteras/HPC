version 17.0
loc name_do "sim-menzel-bsbc-create-index"


cap drop _all 

tempname myName 
tempfile myFile 

loc beta1_100  400
  
// social multiplier parameter 
loc gamma1_100_values "0(100)200" 

// endogeneity
loc rho_100_values "20(20)60"

// first stage parameter
loc pi1_100_values "40(20)80"

// group sizes
// loc n_g_levels "30(5)40"
loc n_g_levels "35(5)35"

// number of groups 
// loc num_groups_levels "300(50)400"
loc num_groups_levels "350(50)350"


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

gen long case = _n
expand 64


sort case 
by case : gen long set = _n
sort case set 
isid case set 

// 64 seeds from random.org, Min: 1, Max: 1000000000
loc seed_list 800511350	187103054	389707626	283868559	8611030	191902509	655434033	644742691	494318144	231375368	103293198	933405669	572530389	62994423	158881053	851051911	482585251	541495401	394112458	650732066	501625795	617342621	258376280	507395437	451181996	98502478	418824263	374121631	462879159	355337809	875917565	569758348	113486633	991141598	861967918	241127833	498258121	421774421	233086884	579222884	268769191	183819274	254046207	592870938	91963048	349970351	330907941	613186636	116235541	568766670	540506003	971184882	940434583	924840650	597021911	952638755	28649635	569245539	717675990	685697350	91832070	845771138	109944353	779407976

gen long seed = .
loc j = 1 
foreach SEED of local seed_list {
  by case : replace seed = `SEED' if set==`j'
  loc ++j
}

isid case seed 

// wlongest (most groups) first 
gsort - num_groups - n_g rho_100 pi1_100 - gamma1_100 set
gen long index = _n 
sort index 
order index case set
qui compress 

save "output/data/sim-menzel-bsbc-index.dta", replace 

desc, f 

tab gamma1_100

exit 
