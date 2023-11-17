*Code to run regressions on the school opening dataset

use ./data/all_school_opening_data, clear

eststo clear
reg kids_rate  adults_rate pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips
eststo full
reg kids_rate  adults_rate pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==1
eststo region_1
reg kids_rate  adults_rate pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==2
eststo region_2
reg kids_rate adults_rate pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==3
eststo region_3
reg kids_rate  adults_rate pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==4
eststo region_4

*Robustness check using ratio of kids to adult case rates
gen ratio=kids_rate/adults_rate
reg ratio pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips
eststo full_ratio
reg ratio pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==1
eststo full_ratio_reg1
reg ratio pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==2
eststo full_ratio_reg2
reg ratio pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==3
eststo full_ratio_reg3
reg ratio pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek i.statefips if region==4
eststo full_ratio_reg4


* table
esttab full region_1 region_2 region_3 region_4 ///
using "./text/latex version/regschoolopening", b(3) p(3) ///
drop(*.statefips) nomtitles tex replace label  nonotes fragment ///
varwidth(30) compress nodepvars nogaps nostar nonumbers stat(r2 N, labels("R$^2$" "Obs") fmt(3 0)) 

esttab full_ratio full_ratio_reg1 full_ratio_reg2 full_ratio_reg3 full_ratio_reg4 ///
using "./text/latex version/regschoolopening_ratio", b(3) p(3) ///
drop(*.statefips) nomtitles tex replace label  nonotes fragment ///
varwidth(30) compress nodepvars nogaps nostar nonumbers stat(r2 N, labels("R$^2$" "Obs") fmt(3 0)) 

bysort division: reg kids_rate  adults_rate pctui pctpov density svi pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek



*Export to R
export delimited using ./data/all_school_opening_data.csv, replace

parmest, norestore
keep parm est stderr
keep if regexm(parm,"schoolweek")
*Some manipulation to generate school week and masks_req as variables, as reshape is complicated
gen n=_n
gen schoolweek=ceil(n/2)
gen masks_req=1-mod(n,2)
drop parm n
reshape wide est stderr, i(schoolweek) j(masks_req)
export delimited using "./data/schoolweek_mask_coeffs.csv", replace

*repeat above, using the ratio instead

use ./data/all_school_opening_data, clear
gen ratio=kids_rate/adults_rate

reg ratio pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek#masks_req i.statefips
eststo clear
eststo full
*Test to see if school-week coeffs are different for masks required/not required
forvalues i=1/16 {
	test `i'.schoolweek#1.masks_req= `i'.schoolweek#0.masks_req
}


areg ratio pctui pctpov density svi  pct_white_nonhisp median_age rate_twoshots_12_18sep1 i.schoolweek#masks_req, absorb(statefips)
eststo full_statefe

esttab full full_statefe using ./text/regtable_statefe_masks, b(3) p(3) nomtitles rtf replace label nonotes varwidth(30) nostar stat(r2 N, labels("R$^2$" "Obs") fmt(3 0)) 

parmest, norestore
keep parm est stderr
keep if regexm(parm,"schoolweek")
*Some manipulation to generate school week and masks_req as variables, as reshape is complicated
gen n=_n
gen schoolweek=ceil(n/2)
gen masks_req=1-mod(n,2)
drop parm n
reshape wide est stderr, i(schoolweek) j(masks_req)
export delimited using "./data/schoolweek_mask_coeffs_ratio.csv", replace



