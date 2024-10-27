args index
version 17.0
loc name_do "sim-menzel-simulate-index"

if "`index'"=="" {
  di as err "must be called with an integer argument index"
  exit 999
}
// generic setup tasks
quietly include "./code/setup/setup.do"
// optional: .tex file with output macros
// qui include code/setup/setup-output-macros.do

loc name_log	"`name_do'-`index'"
cap log close local_log
log using "temp/`name_log'-TEMP.smcl", ///
  replace name(local_log)

**# Introduction and description
/* *********************************************************************

simulate two-step BLP with social multiplier

output: 
compiled by sim-menzel-compile.do
to be analyzed in sim-menzel-analysis.do

uses ado-files sim_menzel_wrapper, sim_menzel_onerep, etc

115 24-10-22 rg update jnt1 to be more cluster-like
116 24-10-23 rg fix getting seed from index.dta, 
                  record seed as dta char 
117 24-10-24 rg use sim_menzel_wrapper_parallel
********************************************************************* */
loc version_do 117


// find out a bit about Stata (esp for HPC)
di "`c(stata_version)'; `c(MP)'; `c(born_date)'"
di "`c(processors)'; `c(processors_lic)'"
di "`c(processors_mach)'; `c(os)'"
di "`c(hostname)'; `c(machine_type)'"
di "`: env HOST'"
di "`: env LSB_HOSTS'"
di "`: env LSB_MAX_NUM_PROCESSORS'"

adopath 

cret li 

local date: display %td_CCYY_NN_DD date(c(current_date), "DMY")
local date_string = subinstr(trim("`date'"), " " , "-", .)
loc archive_suff "`index'-`version_do'-`date_string'"


/* ****************************************************************** */
**# common parameters 
/* ****************************************************************** */

use "output/data/sim-menzel-index.dta", clear 

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

loc myseed = seed[`index']

di `myseed'

if strpos(lower("`c(os)'"),"nix")!=0 {
  di `"on cluster, run full sim"'
  loc num_reps 500
  loc testing ""
}
else {
  di `"not on cluster, run test sim"'
  loc num_reps 20
  loc testing "testing"
}

drop _all 

set seed `myseed'
set tracedepth 1 
set trace off

sim_menzel_wrapper_parallel, ///
  num_reps(`num_reps') ///
  num_groups(`num_groups') n_g(`n_g') ///
  beta1(`beta1') gamma1(`gamma1') ///
  rho(`rho') pi1(`pi1') ///
  myseed(`myseed') ///
  `testing' 

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
