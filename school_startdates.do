
*Code to make a dataset of school county startdates.

use ./data/school_policy, clear

drop if districtnces==.
duplicates report districtnces //4 districts have 2 copies each. Drop the duplicates according to districtid
drop if inlist(districtid,904141,115521291,114732444,115521227)
sort districtnces
tempfile temp1
save `temp1'

use ./data/mapping, clear
drop if count==78 //Puerto Rico
keep leaid stcounty
rename leaid districtnces
sort districtnces

merge m:1 districtnces using `temp1'
*Now dealing with NYC schools, which aren't in the Census Bureau list of districts
gen nyc=physicalstate=="NY" & regexm(districtname,"New York City Geographic District")
replace stcounty=36005 if nyc & _m==2 & physicalcity=="Bronx"
replace stcounty=36047 if nyc & _m==2 & physicalcity=="Brooklyn"
replace stcounty=36061 if nyc & _m==2 & physicalcity=="New York"
replace stcounty=36085 if nyc & _m==2 & physicalcity=="Staten Island"
replace stcounty=36081 if nyc & _m==2 & ~inlist(physicalcity,"Bronx","Brooklyn","New York","Staten Island") //various names for places in Queens


keep if _merge==3 | inlist(stcounty,36005,36047,36061,36085,36081)
drop _merge
keep districtnces stcounty districtname physicalcity physicalstate enrollment schoolyearstartdate

rename stcounty county
rename physicalstate state 
rename physicalcity city

drop if state=="NY" & regexm(districtname,"Department of Education") //Avoid double counting the NYC DOE figures


*An observation is a unique combination of districtnces and county.
*Some school districts cross county lines, which is why we have multiple obs for those districts. 


*Keep if at least one district has a valid school start date
gen startdate=date(schoolyearstartdate,"MDY###")
drop schoolyearstartdate
gen valid_date=startdate~=.
sort county
by county: egen date_check=max(valid_date)
drop if date_check==0
drop date_check

by county: egen county_startdate=median(startdate)
drop if county_startdate==.
collapse  (median) county_startdate, by(county)
sort county
save ./data/all_counties_startdate, replace
