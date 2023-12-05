*************************
******Data Excercise*****
******Li Tong************
*************************

global dir "~/Downloads/excercise"
use "$dir/market_masa_all_reg2.dta",clear

* Q2 

* distance are stored in meters 
label variable min_dis_qgis "qgis distance st_distance() and apply(df,1,min)"
label variable min_distance "r distance st_distance() and apply(df,1,min)"

gen dis_km_qgis = min_dis_qgis / 1000

gen dis_km_r = min_distance / 1000

label variable dis_km_qgis "QGIS distance in km"
label variable	dis_km_r "R distance in km"

* to remove multicolinearity 
histogram dis_km_qgis, normal 
histogram dis_km_r, normal 

sum dis_km_qgis dis_km_r

// winsor2 dis_km_qgis, suffix(_t) cuts(0.05 99) trim
// winsor2 dis_km_r, suffix(_t) cuts(0 70) trim
// gen ln_dis_r = ln(dis_km_r_t)

* creating dummies for qgis 
gen Dist0_1km_qgis = (dis_km_qgis <= 1)
gen Dist1_2km_qgis = (dis_km_qgis > 1 & dis_km_qgis <= 2)
gen Dist2_3km_qgis = (dis_km_qgis > 2 & dis_km_qgis <= 3)
gen Dist3_5km_qgis = (dis_km_qgis > 3 & dis_km_qgis <= 5)
gen Dist5_10km_qgis = (dis_km_qgis > 5 & dis_km_qgis <= 10)
gen Dist10morekm_qgis = (dis_km_qgis > 10)

* dummeis for r
gen Dist0_1km_r = (dis_km_r <= 1)
gen Dist1_2km_r = (dis_km_r > 1 & dis_km_r <= 2)
gen Dist2_3km_r = (dis_km_r > 2 & dis_km_r <= 3)
gen Dist3_5km_r = (dis_km_r > 3 & dis_km_r <= 5)
gen Dist5_10km_r = (dis_km_r > 5 & dis_km_r <= 10)
gen Dist10morekm_r = (dis_km_r > 10)


* adding label: 
label variable Dist0_1km_qgis "QGIS distance 0 km to 1 km"
label variable Dist1_2km_qgis "QGIS distance 1 km to 2 km"
label variable Dist2_3km_qgis "QGIS distance 2 km to 3 km"
label variable Dist3_5km_qgis "QGIS distance 3 km to 5 km"
label variable Dist5_10km_qgis "QGIS distance 5 km to 10 km"
label variable Dist10morekm_qgis "QGIS distance more than 10 km"

* labels for r
label variable Dist0_1km_r "r distance 0 km to 1 km"
label variable Dist1_2km_r "r distance 1 km to 2 km"
label variable Dist2_3km_r "r distance 2 km to 3 km"
label variable Dist3_5km_r "r distance 3 km to 5 km"
label variable Dist5_10km_r "r distance 5 km to 10 km"
label variable Dist10morekm_r "r distance more than 10 km"


* reg ln_nBuilt ln_nl ln_aodMean ln_ndviMean on dummies respectively: 
* reg qgis
local controls ln_distAllRailDegree ln_distRiverDegree ln_distLakeDegree ln_distBorderDegree _dln_precMean _dln_tempMean

foreach y in ln_nBuilt ln_nl ln_aodMean ln_ndviMean {
    eststo: quietly: reg `y' Dist0_1km_qgis Dist1_2km_qgis Dist2_3km_qgis Dist3_5km_qgis Dist5_10km_qgis  `controls' if year == 2019, vce(robust)
}
	 esttab  using "$dir/exercise_regtable.tex", replace fragment booktabs  ///
	 label nomtitles collabels(none)  ///
	 mgroups("QGIS" "R", span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cline{@span}) pattern(1 0 0 0 1 0 0 0))  ///
	  stats(r2 N, fmt(%9.0g %9.3f %9.0g star)) ///
	  noconstant  substitute("=1" "" "_" " ")
*reg r

foreach y in ln_nBuilt ln_nl ln_aodMean ln_ndviMean {
    eststo: quietly: reg `y' Dist0_1km_r Dist1_2km_r Dist2_3km_r Dist3_5km_r Dist5_10km_r /// 
	`controls' if year == 2019, vce(robust)
	 esttab  using "$dir/exercise_regtable.tex", replace fragment booktabs  ///
	 mgroups("QGIS" "R", span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cline{@span}) pattern(1 0 0 0 1 0 0 0))  ///
	  stats(r2 N, fmt(%9.0g %9.3f %9.0g star)) ///
	  noconstant  substitute("=1" "" "_" " ")
}

eststo clear

save "$dir/exercise_q2_q3_tong.dta"
