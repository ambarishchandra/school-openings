*Code to make dataset for examining school openings


use ./data/extended_data_nov30, clear
keep county masks_req
sort county
save ./data/county_mask_info_1832, replace

use ./data/all_counties_startdate, clear
sort county
merge 1:1 county using ./data/county_mask_info_1832
drop _m //_m==1 means no mask data. _m=2 is zero. _m=3 are the 1832 counties.
tempfile county_startdate_masks
save `county_startdate_masks'


*Edited on Oct 31, 2022. Insteqd of cdc_datanov30, use data from the April 2022 release. This allows us to go into Dec 2021
*and also has updated case numbers for the Fall. Data are in a slightly different format so need to reshape
use "./cdc data april 2022/alldata.dta", clear
keep county kids cases date
sort county date
reshape wide cases, i(county date) j(kids)
rename cases0 adults
rename cases1 kids
*Code cases as zero if missing since a county only shows up if there are positive cases
replace adults=0 if adults==.
replace kids=0 if kids==.
sort county 

sort county
merge m:1 county using `county_startdate_masks'
drop if _merge==1 //Keep the _m==2 counties. These are real counties with potential start dates and mask policies, but no reported cases
replace date=county_startdate if _merge==2 //Need to assign a value so the date field is not missing, but there are no cases so doesn't matter which value.
replace adults=0 if _merge==2
replace kids=0 if _merge==2
drop _merge

replace county_startdate=round(county_startdate)
replace date=round(date)

gen wk0=date>=county_startdate & date<=county_startdate+6
gen wk1=date>=county_startdate+7 & date<=county_startdate+13
gen wk2=date>=county_startdate+14 & date<=county_startdate+20
gen wk3=date>=county_startdate+21 & date<=county_startdate+27
gen wk4=date>=county_startdate+28 & date<=county_startdate+34
gen wk5=date>=county_startdate+35 & date<=county_startdate+41
gen wk6=date>=county_startdate+42 & date<=county_startdate+48
gen wk7=date>=county_startdate+49 & date<=county_startdate+55
gen wk8=date>=county_startdate+56 & date<=county_startdate+62
gen wk9=date>=county_startdate+63 & date<=county_startdate+69
gen wk10=date>=county_startdate+70 & date<=county_startdate+76
gen wk11=date>=county_startdate+77 & date<=county_startdate+83
gen wk12=date>=county_startdate+84 & date<=county_startdate+90

gen wkm1=date<county_startdate & date>=county_startdate-7
gen wkm2=date<county_startdate-7 & date>=county_startdate-14
gen wkm3=date<county_startdate-14 & date>=county_startdate-21

foreach var of varlist wk0 wk1 wk2 wk3 wk4 wk5 wk6 wk7 wk8 wk9 wk10 wk11 wk12 wkm1 wkm2 wkm3 {
gen adults_`var'=adults*`var'
gen kids_`var'=kids*`var'
}

collapse (sum) adults_* kids_*, by(county county_startdate masks_req)

*merge in the county population data
sort county
merge m:1 county using ./data/county_pop
keep if _merge==3
drop _merge


foreach var in wk0 wk1 wk2 wk3 wk4 wk5 wk6 wk7 wk8 wk9 wk10 wk11 wk12 wkm1 wkm2 wkm3 {
gen adults_rate_`var'=(adults_`var'/popadult*100000)/7
gen kids_rate_`var'=(kids_`var'/popkid*100000)/7
}

keep county kids_rate* adults_rate*  county_startdate masks_req
save ./data/school_opening_data_upto_dec15, replace

use ./data/county_vax_rates, clear
merge 1:1 fips using ./data/county_controls
keep if _m==3
drop _merge

tempfile temp1 temp2
sort fips
save `temp1'

*Read in region and division codes
import delimited using ./data/region_division_codes.csv, clear
drop if statefips==0
tostring statefips, gen(state)
sort state
save `temp2'


use ./data/school_opening_data_upto_dec15, clear
rename county fips
merge 1:1 fips using `temp1'
keep if _m==3
drop _m

*Make data long, regress kids rate on adults rate, masks, control variables, with week indicators.
reshape long kids_rate_wk adults_rate_wk, i(fips) j(week) string

label var kids_rate "Pediatric Cases per 100K"
label var adults_rate "Adult Cases per 100K"
label var pctui "Percent Uninsured"
label var pctpov "Percent in Poverty"
label var density "Population Density"
label var svi "Social Vulnerability Index"
label var ccvi "Community Vulnerability Index"
label var pct_white_nonhisp "Percent Non-Hispanic White"
label var median_age "Median Age"
label var rate_twoshots_12_18sep1 "Pediatric Vaccination Rate"

gen schoolweek=0
replace schoolweek=1 if week=="m3"
replace schoolweek=2 if week=="m2"
replace schoolweek=3 if week=="m1"
replace schoolweek=4 if week=="0"
replace schoolweek=5 if week=="1"
replace schoolweek=6 if week=="2"
replace schoolweek=7 if week=="3"
replace schoolweek=8 if week=="4"
replace schoolweek=9 if week=="5"
replace schoolweek=10 if week=="6"
replace schoolweek=11 if week=="7"
replace schoolweek=12 if week=="8"
replace schoolweek=13 if week=="9"
replace schoolweek=14 if week=="10"
replace schoolweek=15 if week=="11"
replace schoolweek=16 if week=="12"


tostring fips, gen(stcode)
gen l=length(stcode)
gen state=""
replace state=substr(stcode,1,1) if l==4
replace state=substr(stcode,1,2) if l==5
drop stcode l
sort state
merge m:1 state using `temp2'
drop if _m==2 //DC and HI
drop _m

save ./data/all_school_opening_data, replace
export delimited ./data/all_school_opening_data.csv, replace





