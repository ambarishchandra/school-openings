*Code to use testing rate data to adjust the main regression results

*Merge kids testing rate with school opening data

use ./data/all_school_opening_data, clear
keep if inlist(name,"Florida","New York","Georgia")|fips==17031
replace name="CHI" if fips==17031
replace name="FL" if name=="Florida"
replace name="GA" if name=="Georgia"
replace name="NY" if name=="New York"

sort name schoolweek
merge m:1 name schoolweek using ./data/testing_frac_4places
drop _m //all matched

label var frac_tests_kids "Pediatric Frac. Tests"
eststo clear
reg kids_rate  adults_rate pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips
eststo no
reg kids_rate  adults_rate pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 frac_tests_kids i.schoolweek i.statefips
eststo yes

*Bring in the mask regression here to create output table
preserve
use ./data/all_school_opening_data, clear
reg kids_rate adults_rate pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek#masks_req i.statefips
eststo mask
restore

esttab mask no yes ///
using "./text/latex version/regmasktesting", b(3) p(3) ///
drop(*.schoolweek *.statefips) nomtitles tex replace label  nonotes fragment varwidth(30) compress nodepvars nogaps nostar nonumbers stat(r2 N, labels("R$^2$" "Obs") fmt(3 0)) 

*Calculate how much cases were lower in weeks 3+ as well as all weeks 0+ when adjusting for testing
gen week3plus=schoolweek>6
gen week0plus=schoolweek>3
gen weeksummer=schoolweek<4
gen week0to2=schoolweek>3 & schoolweek<7

reg kids_rate  adults_rate pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 frac_tests_kids week0to2 week3plus i.statefips

reg kids_rate  adults_rate pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 frac_tests_kids week0plus i.statefips
*when comparing week3plus to summer and weeks 0to2, case rates are lower by 10.65
*when comparing school open period to pre-opening, case rates are lower by 4.7


*Check if results are the same using ratio of kids to adult case rates
gen ratio=kids_rate/adults_rate

reg ratio pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips

reg ratio pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 frac_tests_kids i.schoolweek i.statefips

*Export data to R to run regs and make graphs
export delimited using ./data/test_adjusted_regs.csv, replace
