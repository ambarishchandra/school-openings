Readme file for Chandra/Hoeg, "School Opening Associated with Significantly Lower Test-Adjusted COVID-19 Case Rates in Children —United States, August to December 2021"



List of codes to run, in order:

1. school_startdates.do: Uses datasets on school policy from MCH (school_policy.dta); and district to county mapping from US Census (mapping.dta), to create dataset of school district start dates, saves all_counties_startdate.dta

2. read_data.do: Use CDC restricted data (alldata.dta and extended_data_nov30.dta) with information on weekly cases for each county, by age group. Merge in all_counties_startdate from Step 1; county population data; county vaccination rates; other county level control variables. Saves all_school_opening_data.dta

3. regs.do: Uses all_school_opening_data from Step 2, runs all regressions needed to generate Figures 1 and 2, as well as Figures 1 and 2 in the Appendix.

4. Testing.do: Reads in data on testing from four jurisdictions, creates graph for Figure 4 in the paper.

5. test_adjusted_regs.do: Incorporates testing data to re-run regressions with age-stratified tests as a control, creates data for Figures 3 and 5. 