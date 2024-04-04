/* -----------
objective: a compressed coding sample including data cleaning and regressing work on STATA

NB: This code have been derived from my old coding projects. Prior data cleaning process have been deliberately omitted for clarity. 

author: Tong LI 
email: tong.li1@sciencespo.fr
last updated: Apr.4 
	update notes: include a piece of IV reg from thesis , look for apr.4 to locate the changes
date created: mar.29

--------------*/
clear all
set more off
* housekeeping
pwd
global stata /Users/tli/github/sample/stata
global data /Users/tli/downloads/data


quietly capture cd "${data}/tmp/"
if (_rc) mkdir "${data}/tmp/"

quietly capture cd "${data}/graph/"
if (_rc) mkdir "${data}/graph/"

* some loops in reading the data:
forvalues year = 2012/2017{
	import delimited "${data}/raw/BEF_`year'.csv", clear
	gen year = `year'
	save "${data}/tmp/BEF_`year'.dta",replace
}
* now we append the dta for each year
forvalues year = 2012/2017{
	append using "${data}/tmp/BEF_`year'.dta"
	erase "${data}/tmp/BEF_`year'.dta" // we can remove temporary files
}

* some recoding skills
recode pretax_income (99999 = .) 
recode posttax_income(0 = .)

* droping duplicates
egen count = seq(), by (person_id pretax_income posttax_income firm_id_sec year )
egen max = max(count), by (person_id pretax_income posttax_income firm_id_sec year)
drop if count != 1 & max > 1
drop count max

* generate a treatment variable:
gen treat = 1 if posttax_income - posttax_income[_n-1] - 1 & person_id == person_id[_n-1]
replace treat = 0 if treat < 0 | treat == .

* some merging code:
* checking if we have the same obs to merge:
cf firm_id_sec person_id year using "${data}/sample.dta"

merge 1:m firm_id_sec person_id year using "${data}/sample.dta"
keep if _merge==3
drop _merge

* some simple visualization graph for a RDD project:
global method "AQI CO NO2 O3 PM10 PM2_5 SO2"
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly resid_`i' dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly resid_`i' dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2016", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2016
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2016.png", replace
}

* some reg code with another dataset: 
local controls ln_distAllRailDegree ln_distRiverDegree ln_distLakeDegree ln_distBorderDegree _dln_precMean _dln_tempMean

foreach y in ln_nBuilt ln_nl ln_aodMean ln_ndviMean {
    eststo: quietly: reg `y' Dist0_1km_qgis Dist1_2km_qgis Dist2_3km_qgis Dist3_5km_qgis Dist5_10km_qgis  `controls' if year == 2019, vce(robust)
}
	 esttab  using "$dir/exercise_regtable.tex", replace fragment booktabs  ///
	 label nomtitles collabels(none)  ///
	 mgroups("QGIS" "R", span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cline{@span}) pattern(1 0 0 0 1 0 0 0))  ///
	  stats(r2 N, fmt(%9.0g %9.3f %9.0g star)) ///
	  noconstant  substitute("=1" "" "_" " ")
	  
* visualization on plotting residuals to check data normality:

preserve
capture egen missing_2016 = rowmiss($control $direction logvalue) if year==2016
keep if missing_2016 == 0 
codebook cityname 
levelsof cityname, local(cityreg)
foreach i in `cityreg'{
	foreach measure of varlist  AQI PM2_5 PM10 SO2 NO2 O3 CO{
		di " `i' on iteration of `measure'"
		capture reg logvalue treat date_ymd _I* $control $direction peakhour date2 date3 if year == 2016 & `measure' ==1  & date_ymd >$start_2016 & date_ymd<=20783 & cityname=="`i'", r
		if _rc == 0{
		parmest, label format(estimate min95 max95 %8.2f p %8.3f) ///
		saving(	"${data}/tmp/2016_`measure'_`i'.dta", replace) level(95)
		}
		else display "matrix not positive definite for `i' by `measure' "	
	}
}
restore

** appending:

levelsof cityname, local(cityreg)
foreach i in `cityreg'{
	foreach measure of varlist AQI PM2_5 PM10 SO2 NO2 O3 CO{
	capture append using ${data}/log2016/2016_`measure'_`i'.dta
	save ${data}/total_measure_year/2016_`measure'_all.dta, replace
	// erase "${data}/tmp/2016_parm_`measure'_`i'.dta"
	}
}

** graphing:
foreach measure of varlist AQI PM2_5 PM10 SO2 NO2 O3 CO{
use total_measure_year/2016_`measure'_all.dta, clear
twoway (scatter stderr estimate if parm == "treat" & p <= 0.05, msymbol(x))  (scatter stderr estimate if parm == "treat" & p > 0.05 , msymbol(+) ),  ytitle(`"se"') xtitle(`"treat coef on % `measure' "') xline(0, lwidth(thin) lpattern(solid) lcolor(red)) title(`"`measure' 2016 "') legend( label (2 "p>0.05") label (1 "p<=0.05"))
graph export "${data}/graph/2016_`measure'.png", replace
}

** some regression ** update apr.4
*** this code has been taken from my thesis on a IV reg ****
xtset tract year

* tot income 1 year growth rate:
bysort tract: gen lag_totinc = L.b19313_001e
bysort tract: gen g_totinc = ((b19313_001e - lag_totinc) / lag_totinc) * 100

* median range: 
bysort year: egen g_median_totinc = median(g_totinc)

* tot income lag 2 year growth rate:
bysort tract: gen lag2_totinc = L2.b19313_001e
bysort tract: gen g2_totinc = ((b19313_001e - lag2_totinc) / lag2_totinc) * 100

***********************
* generating the treatment variable  
***********************
*************************
*per capita treatment: 
************************
*** generate treatment for per capita income:
capture drop inc3yr 
gen inc3yr = 0

* Loop through each starting year of the 3-year windows from 2010 to 2019
foreach yr of numlist 2010/2019 {
    local endYr = `yr' + 2  // End year of the 3-year window
    local treatYr = `yr' + 3  // Year to check for an income increase

    * Identify tracts below the median income during the 3-year window
    gen below_`yr' = 0
    bysort tract: replace below_`yr' = 1 if g_capitainc < g_median_capitainc & inlist(year, `yr', `yr'+1, `endYr')

    * Count the occurrences of being below the median income over the 3-year window
    egen below_flag_`yr' = total(below_`yr'), by(tract)

    * Assign treatment based on income increase in the year following the 3-year window
    gen treat_inc`treatYr' = 0
    bysort tract: replace treat_inc`treatYr' = 1 if g_capitainc >= g_median_capitainc & year == `treatYr' & below_flag_`yr' == 3

    * Update the cumulative treatment variable
    replace inc3yr = inc3yr + treat_inc`treatYr'
}
tab inc3yr
drop below_* below_flag_* 

* with inc3yr *
global controls densityblack rent3 rent2 rent1 edu1 edu2 edu3 relocate stay employ pop_youth

*significant*
// global controls densityblack edu1 edu2 edu3 relocate stay employ pop_youth
ivregress 2sls den_crime_person (inc3yr= i.water) $controls  i.year, vce(cluster tract)
ivregress 2sls den_crime_property (inc3yr =i.water) $controls  i.year, vce(cluster tract)
ivregress 2sls den_crime_tot (inc3yr = i.water) $controls  i.year, vce(cluster tract)


** winsoring **
preserve 
sum b19301_001e,d
return list
drop if b19301_001e > r(p75) //significant
ivregress 2sls den_crime_person (inc3yr= i.water) $controls  i.year, vce(cluster tract)
ivregress 2sls den_crime_property (inc3yr =i.water) $controls  i.year, vce(cluster tract)
ivregress 2sls den_crime_tot (inc3yr = i.water) $controls  i.year, vce(cluster tract)
restore

** this is the end of the documents **
