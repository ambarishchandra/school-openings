*Code to read in data on testing, examine whether rate of kids tests rose relative to adults
*Written by AC, May 11, 2023

tempfile tempNY tempGA tempFL tempCHI
*******************NYS Testing********************************
import delimited using "./data/testing/New_York_State_COVID19_Testing_By_Age.csv", clear
gen agecat="20plus"
replace agecat="5_19" if agegroup=="5 to 19"
replace agecat="0_4" if inlist(agegroup,"1 to 4","< 1")
drop agegroup
collapse (sum) positivecases totaltests, by(testdate agecat)
rename positivecases cases
rename totaltests tests

reshape wide cases tests, i(testdate) j(agecat) string
gen date=date(testdate,"MDY")
gen week=week(date)
gen year=year(date)
collapse (sum) cases0_4 tests0_4 cases20plus tests20plus cases5_19 tests5_19, by(year week)

gen totaltests=tests20plus+tests5_19+tests0_4
gen frac_tests_kids=tests5_19/(tests20plus+tests5_19+tests0_4)
gen frac_cases_kids=cases5_19/(cases20plus+cases5_19+cases0_4)
format frac* %9.3f

label var frac_tests_kids "Tests"
label var frac_cases_kids "Cases"

*Data for testing table
gen schoolweek=week-36
sum frac* if year==2021 & schoolweek>=-6 & schoolweek<=-1
sum frac* if year==2021 & schoolweek>=2 & schoolweek<=7
drop schoolweek

twoway (line frac_tests_kids week) (line frac_cases_kids week) if year==2021 & week<51 & week>20, xline(36, lpattern(dash)) ytitle("Fraction in Children") xtitle("Week") title("New York State") legend(rows(1)) yscale(range(.05 .35)) ylabel(.05 ".05" .15 ".15" .25 ".25" .35 ".35") xlabel(20 "May 20" 30 "Jul 29" 40 "Oct 7" 50 "Dec 15") text(.32 25 "Corr = 0.92") name(nys, replace)

keep if year==2021 & week<51 & week>21
rename frac_tests_kids frac_tests_kidsNY
rename frac_cases_kids frac_cases_kidsNY 
rename tests5_19 testsNY
rename totaltests totaltestsNY
keep week frac_cases_kidsNY frac_tests_kidsNY testsNY totaltestsNY
save `tempNY'

****************************GA testing********************************
import delimited using "./data/testing/ga consolidated.csv", clear
rename reportdate date2
keep date2 kidstests kidscases adulttests adultcases
gen date=date(date2,"DM20Y")
gen week=week(date)
gen frac_tests_kids=kidstests/(kidstests+adulttests)
gen frac_cases_kids=kidscases/(adultcases+kidscases)
drop if date==.

gen totaltests=kidstests+adulttests
label var frac_tests_kids "Tests"
label var frac_cases_kids "Cases"

*Data for testing table
gen schoolweek=week-31
sum frac* if schoolweek>=-6 & schoolweek<=-1
sum frac* if schoolweek>=2 & schoolweek<=7
drop schoolweek


twoway (line frac_tests_kids week) (line frac_cases_kids week) if date<22625 & week<51 & week>20, xline(31, lpattern(dash)) ytitle("Fraction in Children") xtitle("Week") title("Georgia") yscale(range(.05 .35)) ylabel(.05 ".05" .15 ".15" .25 ".25" .35 ".35")  text(.32 25 "Corr = 0.91") xlabel(20 "May 20" 30 "Jul 29" 40 "Oct 7" 50 "Dec 15") name(georgia, replace)

keep if week<51 & week>21
rename frac_tests_kids frac_tests_kidsGA
rename frac_cases_kids frac_cases_kidsGA
rename kidstests testsGA
rename totaltests totaltestsGA
keep week frac_tests_kidsGA testsGA frac_cases_kidsGA totaltestsGA
save `tempGA'


********************* Chicago Testing****************************************

import delimited using "./data/testing/chicago testing by age.csv", clear
keep date positivetestsage* notpositivetestsage*
rename date date2
drop if date2==""
gen date=date(date2,"MDY")
gen year=year(date)
drop date2
gen week=week(date)
sort year week
collapse (sum) positivetestsage* notpositivetestsage*, by(year week)
egen tot_testspos=rowtotal(positivetestsage*)
egen tot_testsneg=rowtotal(notpositivetestsage*)
gen frac_tests_kids=(positivetestsage017+ notpositivetestsage017)/(tot_testsneg+tot_testspos)
gen frac_cases_kids=positivetestsage017/tot_testspos
gen totaltests=tot_testsneg+tot_testspos

label var frac_tests_kids "Tests"
label var frac_cases_kids "Cases"

*Data for testing table
gen schoolweek=week-34
sum frac* if year==2021 & schoolweek>=-6 & schoolweek<=-1
sum frac* if year==2021 & schoolweek>=2 & schoolweek<=7
drop schoolweek


twoway (line frac_tests_kids week) (line frac_cases_kids week) if year==2021 & week<51 & week>20, xline(33, lpattern(dash))  ytitle("Fraction in Children") xtitle("Week") title("Chicago") yscale(range(.05 .35)) ylabel(.05 ".05" .15 ".15" .25 ".25" .35 ".35")  xlabel(20 "May 20" 30 "Jul 29" 40 "Oct 7" 50 "Dec 15") text(.32 25 "Corr = 0.98") name(chicago, replace)

keep if year==2021 & week<51 & week>21
gen testsCHI=positivetestsage017+ notpositivetestsage017
rename frac_tests_kids frac_tests_kidsCHI
rename frac_cases_kids frac_cases_kidsCHI
rename totaltests totaltestsCHI
keep week frac_tests_kidsCHI testsCHI frac_cases_kidsCHI totaltestsCHI
save `tempCHI'

*************************Florida Testing********************************
import delimited using "./data/testing/florida testing.csv", clear
gen date=date(week_ending,"DM20Y")
replace date=22483 if date==. //one missing year field
gen week=week(date)
destring cases_tot, ignore(",") replace

gen frac_tests_kids=(tests_kidsu12+tests_kids1219)/(tests_tot)
gen frac_cases_kids=(cases_kidsu12+cases_kids1219)/(cases_tot)

label var frac_tests_kids "Tests"
label var frac_cases_kids "Cases"

*Data for testing table
gen schoolweek=week-32
sum frac* if schoolweek>=-6 & schoolweek<=-1
sum frac* if schoolweek>=2 & schoolweek<=7
drop schoolweek


twoway (line frac_tests_kids week) (line frac_cases_kids week) if week<51, xline(32, lpattern(dash)) ytitle("Fraction in Children") xtitle("Week") title("Florida") yscale(range(.05 .35)) ylabel(.05 ".05" .15 ".15" .25 ".25" .35 ".35")  text(.32 25 "Corr = 0.97") xlabel(20 "May 20" 30 "Jul 29" 40 "Oct 7" 50 "Dec 15") name(florida, replace)
*graph export ./figures/florida.pdf

*graph combine nys florida georgia chicago
grc1leg nys florida georgia chicago, legendfrom(nys) note("Notes: The graph plots the share of reported tests and cases in children, as a proportion of the total in the population. Dashed" "vertical lines denote the median week of school opening in each jurisdiction. Children are defined according to the following" "age groups: NYS: 5-19; FL: 0-19; GA: 5-17; Chicago: 0-17.") subtitle("Figure 4: Reported Pediatric PCR Positive Tests and Pediatric Testing for four jurisdictions")

graph export ./figures/testing_4places.pdf, replace

keep if week<51 & week>21
gen testsFL=tests_kidsu12+tests_kids1219
rename frac_tests_kids frac_tests_kidsFL
rename frac_cases_kids frac_cases_kidsFL
rename tests_tot totaltestsFL
keep week frac_tests_kidsFL testsFL frac_cases_kidsFL totaltestsFL
save `tempFL'

use `tempNY'
merge 1:1 week using `tempGA'
drop _m
merge 1:1 week using `tempFL'
drop if _m~=3
drop _m
merge 1:1 week using `tempCHI'
drop _m
reshape long frac_tests_kids tests frac_cases_kids totaltests, i(week) j(name) string
sort week
rename tests kidstests
*Week 0 is:
*FL: 32
*GA:31
*NYS: 36
*CHI: 34

gen schoolweek=.
replace schoolweek=week-29 if name=="FL"
replace schoolweek=week-28 if name=="GA"
replace schoolweek=week-33 if name=="NY"
replace schoolweek=week-31 if name=="CHI"
keep if schoolweek>=1
keep if schoolweek<=16
drop week
sort name schoolweek
save ./data/testing_frac_4places, replace




