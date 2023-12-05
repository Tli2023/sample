 ** visualization **

 **# figure 1 average pollutant by year and type : 
use "/Users/tli/Downloads/ecommerce/data/processed/air_quality.dta", clear

preserve
//restore at line109
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
	qui reg value i.weekday i.hour i.year if `var'==1  & weekday != 0 & weekday !=6 
	predict resid_`var', r
	sum value if e(sample)
	replace resid_`var' = resid_`var' + r(mean)
}


global method "AQI CO NO2 O3 PM10 PM2_5 SO2"

// year 2016
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

// year 2017
foreach i in $method {
    twoway (scatter resid_`i' dday, msymbol(smcircle_hollow)) ///
           (lpoly resid_`i' dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly resid_`i' dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
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
           (lpoly resid_`i' dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly resid_`i' dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
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
           (lpoly resid_`i' dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly resid_`i' dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
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
           (lpoly resid_`i' dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly resid_`i' dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
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
           (lpoly resid_`i' dday if dday < 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)) ///
           (lpoly resid_`i' dday if dday > 0, bw(1.2) kernel(gau) lwidth(thin) lcolor(gs6)), ///
           xline(-1 1, lwidth(thin) lcolor(navy) lpattern(dash)) legend(off) ///
           xlabel(-14(1)14, angle(45)) ///
           title("Residual `i' in 2021", size(medlarge) color(black)) ///
           xtitle("Days, before, on, and after 1111") ytitle("Pollutants (mg/m3)"), ///
           if type == "`i'" & year == 2021
    graph export "/Users/tli/Downloads/ecommerce/output/figures/scatter_resid`i'_2021.png", replace
}
