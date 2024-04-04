/*
Administrative data cleaning:

Please find this code as a toy sample of my code on cleaning the Spanish administrative data
date created: Apr.4, 2024
Author: Tong LI

*/


** housekeeping **
clear
clear matrix
set more off

global source G:/Data 

** creating temporary direction **
local cwd `"`c(pwd)'"'
quietly capture cd ${source}/tmp
if (_rc) mkdir ${source}/tmp
cd `cwd'
global digits 06 07 08 09 10 11 12 13 14 15 16
foreach x in $digits {
  quietly capture cd ${source}/tmp/1145`x'Tc
  if (_rc) mkdir ${source}/tmp/1145`x'Tc
  cd `cwd'
}

** reading file **
foreach num of numlist 1/13 {
  * new code 
  insheet using "${source}/Spain_MCVL/1145`num'Tc/MCVL2016COTIZA`num'_CDF.TXT", clear delimiter(";")
  rename v1 person_id        
  rename v2 firm_id_sec                                    
  rename v3 year
  rename v4 earnings_jan
  rename v5 earnings_feb
  rename v6 earnings_mar
  rename v7 earnings_apr
  rename v8 earnings_may
  rename v9 earnings_jun
  rename v10 earnings_jul
  rename v11 earnings_aug
  rename v12 earnings_sep
  rename v13 earnings_oct
  rename v14 earnings_nov
  rename v15 earnings_dec
  drop v16
  label var person_id "Individual identifier"
  label var firm_id_sec "Firm identifier for secondary establishment"
  label var year "Year"
  label var earnings_jan "Pension contribution-January (nominal euros in cents)"
  label var earnings_feb "Pension contribution-February (nominal euros in cents)"
  label var earnings_mar "Pension contribution-March (nominal euros in cents)"
  label var earnings_apr "Pension contribution-April (nominal euros in cents)"
  label var earnings_may "Pension contribution-May (nominal euros in cents)"
  label var earnings_jun "Pension contribution-June (nominal euros in cents)"
  label var earnings_jul "Pension contribution-July (nominal euros in cents)"
  label var earnings_aug "Pension contribution-August (nominal euros in cents)"
  label var earnings_sep "Pension contribution-September (nominal euros in cents)"
  label var earnings_oct "Pension contribution-October (nominal euros in cents)"
  label var earnings_nov "Pension contribution-November (nominal euros in cents)"
  label var earnings_dec "Pension contribution-December (nominal euros in cents)"
  sort person_id firm_id_sec year
  * new code mar.30:
	save "$source/tmp/114516Tc/contribution_`num'", replace
}   


** merging **
use "${source}/tmp/merge_1116", clear
merge 1:1 person_id using "${source}/tmp/114510Tc/individuals"
rename _merge merge_1016
drop if (birth_date < 193900 | birth_date > 199412) & merge_1016 == 2
keep person_id merge_*
save "${source}/tmp/merge_1016", replace
keep if merge_1016 == 2
drop merge_*
save "${source}/tmp/raw_cohort", replace
do "mcvl_cohort_2010_panel_li"
gen mcvl_wave = 2010
order person_id year month mcvl_wave
compress
label var mcvl_wave "MCVL wave used to extract individual SS information"
save "${source}/tmp/additional_2010", replace

** reshape code **
reshape long firm_id_sec_ regime_ occupation_ contract_type_ ptcoef_ firm_muni_ sector_ job_relationship_ firm_id_tax_ wage_ firm_workers_ firm_age_ firm_id_main_, i(person_id year) j(month)
