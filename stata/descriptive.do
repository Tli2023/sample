describe

// tostring date, format(%12.0f) replace

gen year =substr(date,1,4)
gen month =substr(date,5,2)
gen day =substr(date,7,2)
sort date

replace type = "PM2_5" if type == "PM2.5"
replace type = "PM2_5_24h" if type == "PM2.5_24h"
 
global measures "AQI PM2_5 PM2_5_24h PM10 PM10_24h SO2 SO2_24h NO2 NO2_24h O3 O3_24h O3_8h O3_8h_24h CO CO_24h"

foreach i in $measures {
    gen `i' = type == "`i'"
}
 
destring year month day,replace

// labeling 
// https://quotsoft.net/air/
label variable AQI "AQI实时值"
label variable PM2_5 "PM2.5实时浓度 (微克/立方米)"
label variable PM2_5_24h "PM2.5 24小时滑动均值 (微克/立方米)"
label variable PM10 "PM10实时浓度 (微克/立方米)"
label variable PM10_24h "PM10 24小时滑动均值 (微克/立方米)"
label variable SO2 "SO2实时浓度 (微克/立方米)"
label variable SO2_24h "SO2 24小时滑动均值 (微克/立方米)"
label variable NO2 "NO2实时浓度 (微克/立方米)"
label variable NO2_24h "NO2 24小时滑动均值 (微克/立方米)"
label variable O3 "O3实时浓度 (微克/立方米)"
label variable O3_24h "O3 24小时最大值 (微克/立方米)"
label variable O3_8h "O3 8小时滑动均值 (微克/立方米)"
label variable O3_8h_24h "O3 8小时滑动均值 的24小时最大值 (微克/立方米)"
label variable CO "CO实时浓度 (毫克/立方米)"
label variable CO_24h "CO 24小时滑动均值 (毫克/立方米)"

save "/Users/tli/Downloads/ecommerce/raw/air_quality.dta", replace

/////
use "/Users/tli/Downloads/ecommerce/output/air_quality.dta", clear
// compress
capture: drop if *_24h ==1 
capture: drop d11priorweek1 d11priorweek2 d11postweek1 d11postweek2
set segmentsize 3g

* one week before Nov.11: 
gen d11priorweek1 =  ( (mdy(month, day, year)>mdy(11,4,2016) & mdy(month, day, year)<=mdy(11,11,2016)) ///
 									 | (mdy(month, day, year)>mdy(11,4,2017) & mdy(month, day, year)<=mdy(11,11,2017)) ///
									  | (mdy(month, day, year)>mdy(11,4,2018) & mdy(month, day, year)<=mdy(11,11,2018)) ///
									  | (mdy(month, day, year)>mdy(11,4,2019) & mdy(month, day, year)<=mdy(11,11,2019)) ///
									  | (mdy(month, day, year)>mdy(11,4,2020) & mdy(month, day, year)<=mdy(11,11,2020)) ///
									  | (mdy(month, day, year)>mdy(10,28,2021) & mdy(month, day, year)<=mdy(11,11,2021)) ) 

* 2 weeks before Nov.11: 
gen d11priorweek2 =  ( (mdy(month, day, year)>mdy(10,28,2016) & mdy(month, day, year)<=mdy(11,14,2016)) ///
 									 | (mdy(month, day, year)>mdy(10,28,2017) & mdy(month, day, year)<=mdy(11,4,2017)) ///
									  | (mdy(month, day, year)>mdy(10,28,2018) & mdy(month, day, year)<=mdy(11,4,2018)) ///
									  | (mdy(month, day, year)>mdy(10,28,2019) & mdy(month, day, year)<=mdy(11,4,2019)) ///
									  | (mdy(month, day, year)>mdy(10,28,2020) & mdy(month, day, year)<=mdy(11,4,2020)) ///
									  | (mdy(month, day, year)>mdy(10,28,2021) & mdy(month, day, year)<=mdy(11,4,2021)) ) 
									  
* 1 week after Nov.11: 									  
gen d11postweek1 = ((mdy(month, day, year)>mdy(11,11,2016) & mdy(month, day, year)<=mdy(11,18,2016)) ///
							| (mdy(month, day, year)>mdy(11,11,2017) & mdy(month, day, year)<=mdy(11,18,2017)) ///
							| (mdy(month, day, year)>mdy(11,11,2018) & mdy(month, day, year)<=mdy(11,18,2018)) ///
							| (mdy(month, day, year)>mdy(11,11,2019) & mdy(month, day, year)<=mdy(11,18,2019)) ///
							| (mdy(month, day, year)>mdy(11,11,2020) & mdy(month, day, year)<=mdy(11,18,2020)) ///
							| (mdy(month, day, year)>mdy(11,11,2021) & mdy(month, day, year)<=mdy(11,18,2021)))
  
		 
* 2 week after Nov.11: 										 
gen d11postweek2 = ( (mdy(month, day, year)>mdy(11,18,2016) & mdy(month, day, year)<=mdy(11,25,2016)) ///
									 | (mdy(month, day, year)>mdy(11,18,2017) & mdy(month, day, year)<=mdy(11,25,2017)) ///
									 | (mdy(month, day, year)>mdy(11,18,2018) & mdy(month, day, year)<=mdy(11,25,2018)) ///
									 | (mdy(month, day, year)>mdy(11,18,2019) & mdy(month, day, year)<=mdy(11,25,2019)) ///
									 | (mdy(month, day, year)>mdy(11,18,2020) & mdy(month, day, year)<=mdy(11,25,2020)) ///
									 | (mdy(month, day, year)>mdy(11,18,2021) & mdy(month, day, year)<=mdy(11,25,2021)) )
									  
									  
**# graphing pollutants based on year: 
/* twoway (scatter value year, sort), ytitle(`"mg/m3"') xtitle(`"year"') by(, title(`"Pollution over year"')) by(type)


twoway (scatter value year if type == "CO", sort), ytitle(`"mg/m3"') xtitle(`"Year"') by(type, title(`"Pollution over year"')) xlabel(2016(1)2021, grid) name(gco) saving(scatter_co)

twoway (scatter value year if type == "PM2_5", sort), ytitle(`"mg/m3"') xtitle(`"Year"') by(type, title(`"Pollution over year PM2_5"')) xlabel(2016(1)2021, grid)

twoway (scatter value year if type == "AQI", sort), ytitle(`"value"') xtitle(`"Year"') by(type, title(`"Pollution over year AQI"')) xlabel(2016(1)2021, grid) saving(scatter_aqi)

twoway (scatter value year if type == "NO2", sort), ytitle(`"mg/m3"') xtitle(`"Year"') by(type, title(`"Pollution over year NO2"')) xlabel(2016(1)2021, grid) name(gno2,replace) saving(scatter_no2)

twoway (scatter value year if type == "SO2", sort), ytitle(`"mg/m3"') xtitle(`"Year"') by(type, title(`"Pollution over year SO2"')) xlabel(2016(1)2021, grid) name(gso2,replace) saving(scatter_so2)

twoway (scatter value year if type == "PM10", sort), ytitle(`"mg/m3"') xtitle(`"Year"') by(type, title(`"Pollution over year PM10"')) xlabel(2016(1)2021, grid) saving(scatter_pm10)

twoway (scatter value year if type == "O3", sort), ytitle(`"mg/m3"') xtitle(`"Year"') by(type, title(`"Pollution over year O3"')) xlabel(2016(1)2021, grid) name(go3,replace) saving(scatter_o3)

graph export aqi.pdf
graph export gco.pdf
graph di go3 
graph export go3.pdf
graph di gpm10
graph export PM10.pdf
*/

// "Please plot the average level of each type pollutants (let us use the instant value first, not the smoothed) in two weeks before and two weeks after the 11 Nov event. Let us check whether air pollution was affected by the event in anyway. For each type of pollutants and each year

* #average level of pollutants each day 

use "/Users/tli/Downloads/ecommerce/output/air_quality.dta", clear

// collapse (mean) avg_mph strike month day dayofwk deficit_60 d60_resid date, by(week)
// capture: generate date2 = date(date, "YMD")
// format date2 %td

gen d11priorweek1 =  ( (mdy(month, day, year)>mdy(11,4,2016) & mdy(month, day, year)<=mdy(11,11,2016)) ///
 									 | (mdy(month, day, year)>mdy(11,4,2017) & mdy(month, day, year)<=mdy(11,11,2017)) ///
									  | (mdy(month, day, year)>mdy(11,4,2018) & mdy(month, day, year)<=mdy(11,11,2018)) ///
									  | (mdy(month, day, year)>mdy(11,4,2019) & mdy(month, day, year)<=mdy(11,11,2019)) ///
									  | (mdy(month, day, year)>mdy(11,4,2020) & mdy(month, day, year)<=mdy(11,11,2020)) ///
									  | (mdy(month, day, year)>mdy(10,28,2021) & mdy(month, day, year)<=mdy(11,11,2021)) ) 

* 2 weeks before Nov.11: 
gen d11priorweek2 =  ( (mdy(month, day, year)>mdy(10,28,2016) & mdy(month, day, year)<=mdy(11,14,2016)) ///
 									 | (mdy(month, day, year)>mdy(10,28,2017) & mdy(month, day, year)<=mdy(11,4,2017)) ///
									  | (mdy(month, day, year)>mdy(10,28,2018) & mdy(month, day, year)<=mdy(11,4,2018)) ///
									  | (mdy(month, day, year)>mdy(10,28,2019) & mdy(month, day, year)<=mdy(11,4,2019)) ///
									  | (mdy(month, day, year)>mdy(10,28,2020) & mdy(month, day, year)<=mdy(11,4,2020)) ///
									  | (mdy(month, day, year)>mdy(10,28,2021) & mdy(month, day, year)<=mdy(11,4,2021)) ) 
									  
* 1 week after Nov.11: 									  
gen d11postweek1 = ((mdy(month, day, year)>mdy(11,11,2016) & mdy(month, day, year)<=mdy(11,18,2016)) ///
							| (mdy(month, day, year)>mdy(11,11,2017) & mdy(month, day, year)<=mdy(11,18,2017)) ///
							| (mdy(month, day, year)>mdy(11,11,2018) & mdy(month, day, year)<=mdy(11,18,2018)) ///
							| (mdy(month, day, year)>mdy(11,11,2019) & mdy(month, day, year)<=mdy(11,18,2019)) ///
							| (mdy(month, day, year)>mdy(11,11,2020) & mdy(month, day, year)<=mdy(11,18,2020)) ///
							| (mdy(month, day, year)>mdy(11,11,2021) & mdy(month, day, year)<=mdy(11,18,2021)))
  
		 
* 2 week after Nov.11: 										 
gen d11postweek2 = ( (mdy(month, day, year)>mdy(11,18,2016) & mdy(month, day, year)<=mdy(11,25,2016)) ///
									 | (mdy(month, day, year)>mdy(11,18,2017) & mdy(month, day, year)<=mdy(11,25,2017)) ///
									 | (mdy(month, day, year)>mdy(11,18,2018) & mdy(month, day, year)<=mdy(11,25,2018)) ///
									 | (mdy(month, day, year)>mdy(11,18,2019) & mdy(month, day, year)<=mdy(11,25,2019)) ///
									 | (mdy(month, day, year)>mdy(11,18,2020) & mdy(month, day, year)<=mdy(11,25,2020)) ///
									 | (mdy(month, day, year)>mdy(11,18,2021) & mdy(month, day, year)<=mdy(11,25,2021)) )

capture: gen byte week = 0
replace week =-2 if d11priorweek1 ==1
replace week=-1 if d11priorweek2 ==1
replace week=1 if d11postweek1==1
replace week=2 if d11postweek2==1

//
// gen byte d1111 = 0
// replace d1111=1 if inlist(year,2016,2017,2018,2019,2020,2021) & month == 11 & day ==11
use "/Users/tli/Downloads/ecommerce/data/processed/air_quality.dta", clear

// gen ymd =year*10000 + month*100 + day

preserve
collapse (mean) value,by(type date)

gen year =substr(date,1,4)
gen month =substr(date,5,2)
gen day =substr(date,7,2)
destring year month day, replace

bysort year: gen md = month*100 +day

gen dday =0

forvalues i = 1001/1031 {
        replace dday = `i' - 1042 if md ==`i'
}
forvalues i = 1101/1130 {
        replace dday = `i' - 1111 if md ==`i'
}
drop if dday > 14 | dday < -14
global method "AQI CO NO2 O3 PM10 PM2_5 SO2"
// year 2016
foreach i in $method {
    twoway (scatter value dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Average Pollutant Level `i' in 2016", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2016
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_`i'_2016.png", replace
}

// year 2017
foreach i in $method {
    twoway (scatter value dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Average Pollutant Level `i' in 2017", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2017
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_`i'_2017.png", replace
}

// year 2018
foreach i in $method {
    twoway (scatter value dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Average Pollutant Level `i' in 2018", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2018
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_`i'_2018.png", replace
}

// year 2019
foreach i in $method {
    twoway (scatter value dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Average Pollutant Level `i' in 2019", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2019
     graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_`i'_2019.png", replace
}

// year 2020

foreach i in $method {
    twoway (scatter value dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Average Pollutant Level `i' in 2020", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2020
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_`i'_2020.png", replace
}

// year 2021
foreach i in $method {
    twoway (scatter value dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Average Pollutant Level `i' in 2021", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2021
     graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_`i'_2021.png", replace
}
restore

// xi i.type

// twoway (scatter value dday, msymbol(smcircle_hollow)) (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) (lpoly value dday if  dday> 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), xline(12.5 17.5, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) xlabel(-41(7)-20 -14 -7 0 7 14 19, angle(45)) title(Average Pollutant level AQI 2016, size(medlarge) color(black)) xtitle("Days, before, on, and after 1111 ") ytitle(Pollutants (mg/m3)), if type =="AQI" & year==2016

use "/Users/tli/Downloads/ecommerce/data/processed/air_quality.dta", clear
**# regression on week and hour, and plotting the residuals:

// gen week dummies: 
capture: gen date2 = date(date, "YMD")
capture: gen weekday = dow(date2)
label var weekday "0 = Sun; 1 = Mon; 2= Tue; 3= Wed; 4= Thur; 5= Fri; 6= Sat"

// reg: 
**# figure 2 regression on week and hour :


// reg: 
capture drop date2 weekday resid* 

preserve
collapse value ,by(type date hour)

gen date2 = date(date, "YMD")
gen weekday = dow(date2)
label var weekday "0 = Sun; 1 = Mon; 2= Tue; 3= Wed; 4= Thur; 5= Fri; 6= Sat"
gen int year = year(date2)
gen byte month = month(date2)
gen byte day = day(date2)

bysort year: gen md = month*100 +day
gen dday =0
forvalues i = 1001/1031 {
        replace dday = `i' - 1042 if md ==`i'
}
forvalues i = 1101/1130 {
        replace dday = `i' - 1111 if md ==`i'
}
drop if dday > 14 | dday < -14

// bysort type: reg value i.weekday i.hour // i.year
gen AQI = type=="AQI"
xi i.type
rename (_Itype_2 _Itype_3 _Itype_4 _Itype_5 _Itype_6 _Itype_7) (CO NO2 O3 PM10 PM2_5 SO2)

global names "AQI PM2_5 PM10 SO2 NO2 O3 CO"
foreach var in $names{
	qui reg value i.weekday i.hour if `var'==1  & weekday != 0 & weekday !=6 
	predict resid_`var', r
	sum value if e(sample)
	replace resid_`var' = resid_`var' + r(mean)
}


global method "AQI CO NO2 O3 PM10 PM2_5 SO2"

// year 2016
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2016", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2016
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2016.png", replace
}

// year 2017
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2017", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2017
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2017.png", replace
}
// year 2018
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2018", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2018
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2018.png", replace
}
// year 2019
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2019", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2019
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2019.png", replace
}
// year 2020
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2020", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2020
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2020.png", replace
}
// year 2021
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly value dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly value dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2021", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2021
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2021.png", replace
}

