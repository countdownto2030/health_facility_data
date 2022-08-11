********************************************************************************
********************************************************************************
*			 COUNTDOWN TO 2030 / APHRC / GFF / UNICEF / WHO		
* PRODUCING NATIONAL AND SUBNATIONAL HEALTH STATISTICS USING RHIS DATA
*	CODES - ASSESSMENT AND ADJUSTMENT OF INTERNAL CONSISTENCY
*			AND SUMMARY DATA QUALITY SCORE (v1)
********************************************************************************
********************************************************************************

* Set Stata system capacity
clear all
set maxvar 20000
set matsize 10000
set more off,permanently

*******************************************************************************************************************
*******************************************************************************************************************

* DATA QUALITY ASSESSMENT (DQA): ASSESSMENT AND ADJUSTMENT/CORRECTION OF INTERNAL CONSISTENCY

*******************************************************************************************************************
*******************************************************************************************************************
/*READ ME

This do.file is used to assess and adjust/correct the data for the following metrics:
	- Internal consistency between service: ANC1 vs Penta1/DPT1 & Penta1/DPT1 vs Penta3/DPT3 (Service consistency)
	- Internal consistency (outliers) over time (Time consistency)
	- Missing data.
The codes also generate a summary data quality score. 
	The data quality scores are polled out in an external file called:
		"1_Summary_data_quality_score_${country} in both Excel and Stata format.
The final dataset is: "${country}_master_adjusted_dataset.dta".
There are a couple of changes to make in order to run these codes.
See instructions for the changes from lines 42 to 52

*/
*******************************************************************************************************************
*******************************************************************************************************************

*PARAMETERS TO CHANGE

* Change working folder directory as per the folder where dataset to analyze is located in your computer
cd "C:\AMaiga\Dropbox\Countdown2030\CD-GFF\Workshop\2022-06_Nairobi_RHIS_WS\Analysis\Data"

* Declare your country
global country="Tanzania"    		 // Replace Tanzania by the name of your country

* Declare the older data year for your country
global firstyear=2017    			 // Replace 2017 by the oldest year of your country data (e.g., 2018, etc.)

* Declare the most recent data year for your country
global lastyear=2021    			 // Replace 2021 by the most recent year of your country data (e.g., 2020, etc.)

*******************************************************************************************************************
*******************************************************************************************************************

**INTERNAL CONSISTENCY OF ANC1 vs PENTA1 AND PENTA1 vs PENTA3 SERVICE - COMPARISON OF ADJUSTED NUMBER OF ANC1 vs PENTA1 AND PENTA1 vs PENTA3

use "${country}_Comparing_reported_and_adjusted_data.dta",clear

regress penta1 anc1
local r2: display %5.4f e(r2)
twoway (scatter penta1 anc1, sort msize(vsmall) color(navy)) (lfit penta1 anc1, sort lwidth(medthick) lcolor(black) lpattern(solid)) (function x, lcolor(red) lpattern(dash) range(anc1) n(2)), ylabel(, labsize(vsmall) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Adjusted Penta1", size(small)) xlabel(, labsize(vsmall)) xtitle("Adjusted anc1", size(small)) title("Comparison of adjusted numbers of anc1 and Penta1 Penta3 national, ${country}", size(small) position(12)) note(R-squared=`r2', size(small) color(black)) scheme(s1color) legend(order(1 "District"  2 "Linear fit"  3 "Diagonale") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) graphregion(ifcolor(white)) plotregion(fcolor(white)) saving("Graph_${country}_Comparison_Adjusted_ANC1_&_Pent1_national",replace)		

regress penta3 penta1
local r2: display %5.4f e(r2)
twoway (scatter penta3 penta1, sort msize(vsmall) color(navy)) (lfit penta3 penta1, sort lwidth(medthick) lcolor(black) lpattern(solid)) (function x, lcolor(red) lpattern(dash) range(penta1) n(2)), ylabel(, labsize(vsmall) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Adjusted Penta3", size(small)) xlabel(, labsize(vsmall)) xtitle("Adjusted penta1", size(small)) title("Comparison of adjusted numbers of Penta1 and Penta3 by year, ${country}", size(small) position(12)) note(R-squared=`r2', size(small) color(black)) scheme(s1color) legend(order(1 "District"  2 "Linear fit"  3 "Diagonale") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) graphregion(ifcolor(white)) plotregion(fcolor(white)) saving("Graph_${country}_Comparison_Adjusted_Pent1_&_Pent3_national",replace)		

regress penta1 anc1
local r2: display %5.4f e(r2)
twoway (scatter penta1 anc1, sort msize(vsmall) color(navy)) (lfit penta1 anc1, sort lwidth(medthick) lcolor(black) lpattern(solid)) (function x, lcolor(red) lpattern(dash) range(anc1) n(2)), by(year, rows(2)) subtitle(, size(small) nobox) ylabel(, labsize(vsmall) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Adjusted Penta1", size(small)) xlabel(, labsize(vsmall)) xtitle("Adjusted ANC1", size(small)) by(, title("Comparison of adjusted numbers of ANC1 and Penta1 by year, ${country}", size(small) position(12)) note(R-squared=`r2', size(small) color(gray))) scheme(s1color) legend(order(1 "District"  2 "Linear fit" 3 "Diagonale") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Graph_${country}_Comparison_Adjusted_ANC1_&_Pent1_by_year",replace)

regress penta3 penta1
local r2: display %5.4f e(r2)		
twoway (scatter penta3 penta1, sort msize(vsmall) color(navy)) (lfit penta3 penta1, sort lwidth(medthick) lcolor(black) lpattern(solid)) (function x, lcolor(red) lpattern(dash) range(penta1) n(2)), by(year, rows(2)) subtitle(, size(small) nobox) ylabel(, labsize(vsmall) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Adjusted Penta3", size(small)) xlabel(, labsize(vsmall)) xtitle("Adjusted penta1", size(small)) by(, title("Comparison of adjusted numbers of Penta1 and Penta3 by year, ${country}", size(small) position(12)) note(R-squared=`r2', size(small) color(gray))) scheme(s1color) legend(order(1 "District"  2 "Linear fit"  3 "Diagonale") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Graph_${country}_Comparison_Adjusted_Pent1_&_Pent3_by_year",replace)														
																								
*******************************************************************************************************************

**ASSESSMENT INTERNAL CONSISTENCY (OUTLIERS) OVER TIME

use "${country}_master_completnessadjusted_dataset.dta",clear

** Median Absolute Deviation (MAD) method used to assess outliers over time

*br district year month date anc1
clonevar tot_stillb=total_stillbirth 
clonevar stillb_f=stillbirth_f
clonevar stillb_m=stillbirth_m
clonevar u5_death=under5_deaths
clonevar mat_death=maternal_deaths
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death 	{
bysort district: egen `var'_mad=mad(`var') if year<${lastyear}
bysort district: egen max_`var'_mad=max(`var'_mad)
replace `var'_mad=max_`var'_mad if `var'_mad==.
replace `var'_mad=round(`var'_mad,1)
bysort district: egen `var'_med=median(`var') if year<${lastyear}
bysort district: egen max_`var'_med=max(`var'_med)
replace `var'_med=max_`var'_med if `var'_med==.
replace `var'_med=round(`var'_med,1)
bysort district: gen `var'_outlb2std=round(`var'_med - 1.4826*2*`var'_mad,1) 		/* Using Hampel X84 Method - lower bound 2 std from the median */
bysort district: gen `var'_outub2std=round(`var'_med + 1.4826*2*`var'_mad,1)		/* Using Hampel X84 Method - uppper bound 2 std from the median */
bysort district: gen `var'_outlb3std=round(`var'_med - 1.4826*3*`var'_mad,1) 		/* Using Hampel X84 Method - lower bound 3 std from the median */
bysort district: gen `var'_outub3std=round(`var'_med + 1.4826*3*`var'_mad,1)		/* Using Hampel X84 Method - uppper bound 3 std from the median */
bysort district: gen `var'_outlb5std=round(`var'_med - 1.4826*5*`var'_mad,1) 		/* Using Hampel X84 Method - lower bound 5 std from the median */
bysort district: gen `var'_outub5std=round(`var'_med + 1.4826*5*`var'_mad,1)		/* Using Hampel X84 Method - uppper bound 5 std from the median */
bysort district: gen `var'_outlb8std=round(`var'_med - 1.4826*8*`var'_mad,1) 		/* Using Hampel X84 Method - lower bound 8 std from the median */
bysort district: gen `var'_outub8std=round(`var'_med + 1.4826*8*`var'_mad,1)		/* Using Hampel X84 Method - uppper bound 8 std from the median */
drop max_`var'_mad max_`var'_med
gen `var'_outlier5std=cond(`var'!=. & (`var'<`var'_outlb5std | `var'>`var'_outub5std),1,0)
lab var `var'_outlier5std "`var' outlier for 5 STD from the median"
bysort district: egen `var'_tt_d_outlier5std=total(cond(`var'_outlier5std,1,0))
lab var `var'_tt_d_outlier5std "Total number of `var' outliers by district for 5 STD from the median"
bysort district year: egen `var'_tt_dy_outlier5std=total(cond(`var'_outlier5std,1,0))							
lab var `var'_tt_dy_outlier5std "Total number of `var' outliers by district & year for 5 STD from the median"	
bysort year: egen `var'_tt_y_outlier5std=total(cond(`var'_outlier5std,1,0))
bysort district year: gen `var'_count_dy=_N		
bysort year: gen `var'_count_y=_N				
lab var `var'_tt_y_outlier5std "Total number of `var' outliers by year for 5 STD from the median"
}		 

save "_tmp_daq_2a_2b_dataset.dta",replace		//*Added - Dataset for Metrics 2a & 2b assessment

*Graphs internal consistency for assessing outliers over time

cap drop groupdistrict											
gen groupdistrict=ceil(district/12)   /* create group of 12 districts; can change 12 to whichever number one desires per page */
local l=1
sum groupdistrict
local j=r(max)
forval t=1/`j' {
foreach var of varlist anc1 {	//This code runs for ANC1 services (anc1) only. You can run for more variables (e.g., anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths)
twoway (line `var'_outlb5 date, sort lwidth(medthin) lcolor(gray) lpattern(shortdash))  (line `var'_outub5 date, sort lwidth(medthin) lcolor(purple) lpattern(shortdash)) (line `var' date, sort lcolor(blue) lwidth(medium) lpattern(solid)) if groupdistrict==`t', by(district, rows(3)) subtitle(, size(small) nobox)  ylabel(, labsize(tiny) glwidth(thin) glcolor(gs15) glpattern(solid)) xlabel(, labsize(vsmall)) xtitle("Date", size(small)) by(, title("Assessment of `var' outliers over time by district, ${country}", size(small) position(12)) note(Outlier>±1.482*5*MAD (5 std from median), size(tiny) color(gray))) legend(order(1 "Outlier lower bound"  2 "Outlier upper bound"  3 "`var'_service") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Graph_${country}_Internal_consistency_over_time_Assessment_outliers_of_`var'_in districts_gr`t'",replace)
}
}

*Identification of the number of outliers by district and by year

sort district year month 
										
log using "Log_${country}_identification_number_outliers_by_district_and_by_year",replace

/*
*Identification of the number of outliers by district and by year for all services run once									
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}	
*/

******												
*Identification of the number of outliers by district and by year for ANC1									
foreach var of varlist anc1 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		 

******												
*Identification of the number of outliers by district and by year for ANC4									
foreach var of varlist anc4 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		 

******												
*Identification of the number of outliers by district and by year for IPT 2									
foreach var of varlist ipt2 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}
													
******												
*Identification of the number of outliers by district and by year for institutional delivery											
foreach var of varlist idelv 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		 													

******												
*Identification of the number of outliers by district and by year for delivery by skilled birth attendant											
foreach var of varlist sba 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		 	

******												
*Identification of the number of outliers by district and by year for csection											
foreach var of varlist csection 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}	

******												
*Identification of the number of outliers by district and by year for PNC 48h											
foreach var of varlist pnc48h 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}	
										
******												
*Identification of the number of outliers by district and by year for BCG vaccination									
foreach var of varlist bcg 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}	

******												
*Identification of the number of outliers by district and by year for Penta 1 vaccination									
foreach var of varlist penta1 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}											
								
******												
*Identification of the number of outliers by district and by year for Penta 3 vaccination									
foreach var of varlist penta3 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}														

******												
*Identification of the number of outliers by district and by year for Measles 1 vaccination									
foreach var of varlist measles1 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}

******												
*Identification of the number of outliers by district and by year for total OPD visits									
foreach var of varlist opd_total 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}														

******												
*Identification of the number of outliers by district and by year for Under 5 OPD visits									
foreach var of varlist opd_under5 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}			

******												
*Identification of the number of outliers by district and by year for total IPD admissions									
foreach var of varlist ipd_total 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}	

******												
*Identification of the number of outliers by district and by year for Under-5 IPD admissions									
foreach var of varlist ipd_under5 	{
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}	

******												
*Identification of the number of outliers by district and by year for Total Family Planing									
foreach var of varlist fp_total 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		

******												
*Identification of the number of outliers by district and by year for New Family Planing										
foreach var of varlist fp_new 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		

******												
*Identification of the number of outliers by district and by year for Revisit Family Planing										
foreach var of varlist fp_revisits 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		

******												
*Identification of the number of outliers by district and by year for Total Stillbirth									
foreach var of varlist tot_stillb 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		

******												
*Identification of the number of outliers by district and by year for Fresh Stillbirth									
foreach var of varlist stillb_f 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		

******												
*Identification of the number of outliers by district and by year for Macerated Stillbirth									
foreach var of varlist stillb_m 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		

******												
*Identification of the number of outliers by district and by year for Under 5 deaths									
foreach var of varlist u5_death 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		

******												
*Identification of the number of outliers by district and by year for Maternal deaths									
foreach var of varlist mat_death 	{		
list district year `var' `var'_outlb5std `var'_outub5std `var'_tt_d_outlier5std `var'_tt_y_outlier5std if `var'_outlier5std==1,abbrev(20)
tab district, sum(`var'_tt_d_outlier5std)
tab year,sum(`var'_tt_y_outlier5std)
}		
							
log close			
					  
																				
*******************************************************************************************************************

**CORRECTION OF INTERNAL CONSISTENCY (OUTLIERS) OVER TIME
					  
*Correction of outliers over time using the district annual mediane value

*br district year month anc1 anc1_outlb5std anc1_outub5std anc1_tt_d_outlier5std anc1_tt_y_outlier5std anc1_outlier5std
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death	{
clonevar raw_`var'=`var'
order raw_`var',after(`var')
lab var raw_`var' "Raw `var' data without correction of outliers over time"
bysort district year: egen med_`var'=median(`var') if `var'_outlier5std!=1
replace med_`var'=round(med_`var',1)
bysort district year: egen max_`var'=max(med_`var')
replace `var'=max_`var' if `var'_outlier5std==1
drop med_`var' max_`var'
}	

*List of districts with outliers corrected
foreach var of varlist anc1 	  {		//This code runs for ANC1 services (anc1) only. You can run for more variables (e.g., anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death)
list district year raw_`var' `var' if `var'_outlier5std==1
}	


* Graph internal consistency after correction of outliers

cap drop groupdistrict											
gen groupdistrict=ceil(district/12)	/* create group of 12 districts; can change 20 to whichever number one desires per page */
local l=1
sum groupdistrict
local j=r(max)
forval t=1/`j' {
foreach var of varlist anc1 {		//This code runs for ANC1 services (anc1) only. You can run for more variables (e.g., anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths) 
twoway (line `var'_outlb5 date, sort lwidth(medthin) lcolor(gray) lpattern(shortdash))  (line `var'_outub5 date, sort lwidth(medthin) lcolor(purple) lpattern(shortdash)) (line `var' date, sort lcolor(blue) lwidth(medium) lpattern(solid)) if groupdistrict==`t', by(district, rows(3)) subtitle(, size(small) nobox)  ylabel(, labsize(tiny) glwidth(thin) glcolor(gs15) glpattern(solid)) xlabel(, labsize(vsmall)) xtitle("Date", size(small)) by(, title("`var' after correcting outliers over time by district, ${country}", size(small) position(12)) note(Outlier>±1.482*5*MAD (5 std from median), size(tiny) color(gray))) legend(order(1 "Outlier lower bound"  2 "Outlier upper bound"  3 "`var'_service") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Graph_${country}_Internal_consistency_over_time_after_correction_of_outliers_of_`var'_in_districts_gr`t'",replace)
}
}

drop *_mad *_med raw_* *_outlb*std *_outub*std *_outlier5std *_tt_d_outlier5std *_tt_dy_outlier5std

save "${country}_master_completeness_&_outliers_adjusted_dataset.dta",replace
					  	  
					  
*******************************************************************************************************************					  

**ASSESSMENT OF MISSING DATA

use "${country}_master_completeness_&_outliers_adjusted_dataset.dta",clear
 *
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths	 {
recode `var' (.=1 "Missing") (else=0 "Non-missing"),gen(mis_`var')
lab var mis_`var' "Missing `var'"
*br district year month `var' mis_`var' if mis_`var'==1
bysort district year: egen max_mis_`var'=max(mis_`var')
*br district year month `var' mis_`var' if max_mis_`var'==1
}						  

*Identification of missing data for all services
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths	 { 		//This code runs for all services. You can run for specific variables as needed (e.g., anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths)
count if  `var'==.
tab mis_`var'
list district year month `var' mis_`var' if mis_`var'==1, abbrev(20) noobs
}	

 					  
*******************************************************************************************************************

**CORRECTION OF MISSING DATA

foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths	 {
bysort district year: egen total_mis_`var'=total(mis_`var')
bysort district year: egen count_mis_`var'=count(mis_`var')
gen prop_mis_`var'=round(total_mis_`var'/count_mis_`var'*100,1)
lab var prop_mis_`var' "Percentage missing value of `var' by distict and year"
bysort district year: egen median_`var'=median(`var') if mis_`var'!=1
replace median_`var'=round(median_`var',1)
bysort district year: egen max_median_`var'=max(median_`var')
replace median_`var'=max_median_`var' if median_`var'==.
replace `var'=max_median_`var' if `var'==. & max_median_`var'!=. & prop_mis_`var'<50
}						  

**Checking correction of missing data for ANC4
foreach var of varlist  anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths	 { 		//This code runs for ANC4 services (anc1) only. You can run for more variables (e.g., anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths)
count if  `var'==.
list district year month `var' median_`var' prop_mis_`var' if mis_`var'==1, abbrev(20) noobs
*drop mis_`var' max_mis_`var' total_mis_`var' count_mis_`var' prop_mis_`var' median_`var' max_median_`var'
}	

sort country adminlevel_1 district year month
compress
save "${country}_master_adjusted_dataset.dta",replace


*******************************************************************************************************************

** SUMMARY DATA QUALITY SCORE

*** 1a. % of expected monthly facility reports (mean, national)

use "${country}_Completeness_reporting_by_year_national.dta",clear
	 									
*br year anc_rr idelv_rr pnc_rr opd_rr vacc_rr pnc_rr fp_rr
gen reporting_rate_mean=.
format reporting_rate_mean %5.0f
lab var reporting_rate_mean "Average Reporting Rate by year (National average of ANC, delivery, vaccination, opd)"		//*/
local firstyear=${firstyear}
local lastyear=${lastyear}
forval year=`firstyear'/`lastyear'	{
egen rr_`year'=rowmean(anc_rr idelv_rr vacc_rr opd_rr) if year==`year'		//*
replace reporting_rate_mean=rr_`year' if year==`year'
}
keep year anc_rr idelv_rr vacc_rr opd_rr reporting_rate_mean ipd_rr pnc_rr fp_rr		//*
lab var anc_rr "ANC - annual reporting rate"
lab var idelv_rr "Delivery - annual reporting rate"
lab var vacc_rr "Vaccination - annual reporting rate"
lab var opd_rr "OPD - annual reporting rate"
lab var ipd_rr "IPD - annual reporting rate"			//*
lab var pnc_rr "PNC - annual reporting rate"			//*
lab var fp_rr "Family Planing - annual reporting rate"	//*
rename (anc_rr idelv_rr vacc_rr opd_rr ipd_rr pnc_rr fp_rr) (ANC_All DELIVERY_All VACCINATION_All OPD_All IPD_All PNC_All FP_All)		//*
clonevar ANC1_service=ANC_All
clonevar ANC4_service=ANC_All
clonevar IPT2_service=ANC_All				//*
clonevar Delivery_service=DELIVERY_All		//*
clonevar CSection_service=DELIVERY_All		//*
clonevar BCG_service=VACCINATION_All		//*
clonevar Penta1_service=VACCINATION_All
clonevar Penta3_service=VACCINATION_All
clonevar Measles1_service=VACCINATION_All	//*
clonevar PNC48h_service=PNC_All				//*
clonevar SBA_service=DELIVERY_All			//*
clonevar OPD_under5_service=OPD_All			//*
clonevar IPD_under5_service=IPD_All			//*
clonevar FP_new_service=FP_All				//*
clonevar FP_revisits_service=FP_All			//*
clonevar Stillbirth_all=DELIVERY_All		//*
clonevar Stillbirth_fresh=DELIVERY_All		//*
clonevar Stillbirth_macerated=DELIVERY_All	//*
clonevar Under5_death=OPD_All				//*
clonevar Maternal_death=DELIVERY_All		//*
gen dq_by_service="Reporting rate (%) - by service & by year"
lab var dq_by_service "Reporting rate (%) - by service & by year"
gen dq_all_services="DQ 1a - Reporting rate (%) by year (National average of ANC, delivery, vaccination, opd)"		//*
lab var dq_all_services "Data quality indicator"
rename reporting_rate_mean mean_all_service
*order dq_all_services year mean_all_service dq_by_service ANC1_service ANC4_service DELIVERY_All Penta1_service Penta3_service OPD_All ANC_All VACCINATION_All		//*
order dq_all_services year mean_all_service dq_by_service ANC_All DELIVERY_All PNC_All VACCINATION_All OPD_All IPD_All FP_All ANC1_service ANC4_service Delivery_service Penta1_service Penta3_service  		//*
insobs 1 	//Add blank row
save "_DQ_score_reporting_rate.dta",replace

**************************************************

** 1. Completeness of monthly facility reporting (green >${threshold_low_rr}%)

*** 1b. % of districts with completeness of facility reporting >= ${threshold_low_rr}%*

use "${country}_Low_reporting_by_district_by_year.dta",clear

display ${threshold_low_rr}
						
*br district anc_rr*
gen anc=.
gen idelv=.
gen vacc=.
gen opd=.
gen ipd=.	//*
gen pnc=.	//*
gen fp=.	//*
local firstyear=${firstyear}
local lastyear=${lastyear}
foreach var of varlist	anc idelv vacc opd ipd pnc fp	{	//*
forval year=`firstyear'/`lastyear'	{
egen `var'_num_rr${threshold_low_rr}_`year'=total(cond(`var'_rr`year'>=${threshold_low_rr},1,0))
egen `var'_den_rr${threshold_low_rr}_`year'=count(`var'_rr`year')
gen `var'_per${threshold_low_rr}_`year'=(`var'_num_rr${threshold_low_rr}_`year'/`var'_den_rr${threshold_low_rr}_`year')*100
format `var'_per${threshold_low_rr}_`year' %5.0f
lab var `var'_per${threshold_low_rr}_`year' "% of districts with `var' reporting rate >= ${threshold_low_rr}%  in `year'"
}
}
collapse (first) anc idelv vacc opd ipd pnc fp *_per${threshold_low_rr}_*	//*
gen order=_n
reshape long anc_per${threshold_low_rr}_ idelv_per${threshold_low_rr}_ vacc_per${threshold_low_rr}_ opd_per${threshold_low_rr}_ ipd_per${threshold_low_rr}_ pnc_per${threshold_low_rr}_ fp_per${threshold_low_rr}_ , i(order) j(year)	//*
rename (anc_per${threshold_low_rr}_ idelv_per${threshold_low_rr}_ vacc_per${threshold_low_rr}_ opd_per${threshold_low_rr}_  ipd_per${threshold_low_rr}_ pnc_per${threshold_low_rr}_ fp_per${threshold_low_rr}_) (anc_per${threshold_low_rr} idelv_per${threshold_low_rr} vacc_per${threshold_low_rr} opd_per${threshold_low_rr} ipd_per${threshold_low_rr} pnc_per${threshold_low_rr} fp_per${threshold_low_rr})	//*
foreach var of varlist	anc idelv vacc opd ipd pnc fp		{	//*
lab var `var'_per${threshold_low_rr} "% of districts with `var' reporting rate >= ${threshold_low_rr}%  by year"
}
drop order anc idelv vacc opd ipd pnc fp	//*
egen per_district_${threshold_low_rr}=rowmean(anc_per${threshold_low_rr} idelv_per${threshold_low_rr} vacc_per${threshold_low_rr} opd_per${threshold_low_rr})	//*/
format per_district_${threshold_low_rr} %5.0f
lab var per_district_${threshold_low_rr} "Percentage of districts with reporting rate >= ${threshold_low_rr}% by year (National average of ANC, delivery, vaccination, opd)"	//*/
rename (anc_per${threshold_low_rr} idelv_per${threshold_low_rr} vacc_per${threshold_low_rr} opd_per${threshold_low_rr} ipd_per${threshold_low_rr} pnc_per${threshold_low_rr} fp_per${threshold_low_rr}) (ANC_All DELIVERY_All VACCINATION_All OPD_All IPD_All PNC_All FP_All)
clonevar ANC1_service=ANC_All
clonevar ANC4_service=ANC_All
clonevar IPT2_service=ANC_All				//*
clonevar Delivery_service=DELIVERY_All		//*
clonevar CSection_service=DELIVERY_All		//*
clonevar BCG_service=VACCINATION_All		//*
clonevar Penta1_service=VACCINATION_All
clonevar Penta3_service=VACCINATION_All
clonevar Measles1_service=VACCINATION_All	//*
clonevar PNC48h_service=PNC_All				//*
clonevar SBA_service=DELIVERY_All			//*
clonevar OPD_under5_service=OPD_All			//*
clonevar IPD_under5_service=IPD_All			//*
clonevar FP_new_service=FP_All				//*
clonevar FP_revisits_service=FP_All			//*
clonevar Stillbirth_all=DELIVERY_All		//*
clonevar Stillbirth_fresh=DELIVERY_All		//*
clonevar Stillbirth_macerated=DELIVERY_All	//*
clonevar Under5_death=OPD_All				//*
clonevar Maternal_death=DELIVERY_All		//*

gen dq_by_service="% of districts with reporting rate >= ${threshold_low_rr}%  by year - by service"
gen dq_all_services="DQ 1b - Percentage of districts with reporting rate >= ${threshold_low_rr}% by year (National average of ANC, delivery, vaccination, opd)"
rename per_district_${threshold_low_rr} mean_all_service
order dq_all_services year mean_all_service dq_by_service ANC_All DELIVERY_All VACCINATION_All OPD_All IPD_All PNC_All FP_All ANC1_service ANC4_service Delivery_service Penta1_service Penta3_service   
insobs 1 
save "_DQ_score_perc_districts_over_${threshold_low_rr}.dta",replace

**************************************************


*** 1c. % of districts with no missing monthly values in the year 

use "${country}_master_completeness_&_outliers_adjusted_dataset.dta",clear

keep district year month anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths 			//*
rename (total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths) (tot_stillb stillb_f stillb_m u5_death mat_death)

*br
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death	 {		//*
recode `var' (.=0 "Missing") (else=1 "Non-missing"),gen(`var'_m)
bysort district year: egen mis_`var'=min(`var'_m)
}						  
collapse (first) mis_anc1 mis_anc4 mis_ipt2 mis_idelv mis_sba mis_csection mis_pnc48h mis_bcg mis_penta1 mis_penta3 mis_measles1 mis_opd_total mis_opd_under5 mis_ipd_total mis_ipd_under5 mis_fp_total mis_fp_new mis_fp_revisits mis_tot_stillb mis_stillb_f mis_stillb_m mis_u5_death mis_mat_death, by(district year)		//*

*tab1 mis_anc1 mis_anc4 mis_ipt2 mis_idelv mis_sba mis_csection mis_pnc48h mis_bcg mis_penta1 mis_penta3 mis_measles1 mis_opd_total mis_opd_under5 mis_ipd_total mis_ipd_under5 mis_fp_total mis_fp_new mis_fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death

gen anc1=.
gen anc4=.
gen ipt2=.
gen idelv=.
gen sba=.
gen csection=.
gen pnc48h=.
gen bcg=.
gen penta1=.
gen penta3=.
gen measles1=.
gen opd_total=.
gen opd_under5=.
gen ipd_total=.
gen ipd_under5=.
gen fp_total=.
gen fp_new=.
gen fp_revisits=.
gen tot_stillb=.
gen stillb_f=.
gen stillb_m=.
gen u5_death=.
gen mat_death=.

local firstyear=${firstyear}
local lastyear=${lastyear}
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death  	{
forval year=`firstyear'/`lastyear'	{
egen `var'_num_mis_`year'=total(mis_`var') if year==`year',by(year)
egen `var'_den_mis_`year'=count(mis_`var') if year==`year',by(year)
gen `var'_nomiss_pd_`year'=(`var'_num_mis_`year'/`var'_den_mis_`year')*100
format `var'_nomiss_pd_`year' %5.0f
lab var `var'_nomiss_pd_`year' "Percentage of districts with `var' no missing monthly values in `year'"
}
}
collapse (first) anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death  *_nomiss_pd_*,by(year)

foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death  	{
gen `var'_pd_nomiss=.
replace `var'_pd_nomiss=`var'_nomiss_pd_2017 if year==2017
replace `var'_pd_nomiss=`var'_nomiss_pd_2018 if year==2018
replace `var'_pd_nomiss=`var'_nomiss_pd_2019 if year==2019
replace `var'_pd_nomiss=`var'_nomiss_pd_2020 if year==2020
replace `var'_pd_nomiss=`var'_nomiss_pd_2021 if year==2021
lab var `var'_pd_nomiss "% of districts with no `var' missing monthly values in the year"
format `var'_pd_nomiss %5.0f
}
keep year *_pd_nomiss

egen per_dist_no_missing=rowmean(anc1_pd_nomiss anc4_pd_nomiss idelv_pd_nomiss penta1_pd_nomiss penta3_pd_nomiss opd_total_pd_nomiss)		//*/
format per_dist_no_missing %5.0f
lab var per_dist_no_missing "Percentage of districts with no missing monthly values by year (National average of ANC1, ANC4, delivery, Penta1, Penta3, opd)"
rename (anc1_pd_nomiss anc4_pd_nomiss ipt2_pd_nomiss idelv_pd_nomiss sba_pd_nomiss csection_pd_nomiss pnc48h_pd_nomiss bcg_pd_nomiss penta1_pd_nomiss penta3_pd_nomiss measles1_pd_nomiss opd_total_pd_nomiss opd_under5_pd_nomiss ipd_total_pd_nomiss ipd_under5_pd_nomiss fp_total_pd_nomiss fp_new_pd_nomiss fp_revisits_pd_nomiss tot_stillb_pd_nomiss stillb_f_pd_nomiss stillb_m_pd_nomiss u5_death_pd_nomiss mat_death_pd_nomiss) (ANC1_service ANC4_service IPT2_service Delivery_service SBA_service CSection_service PNC48h_service BCG_service Penta1_service Penta3_service Measles1_service OPD_All OPD_under5_service IPD_All IPD_under5_service FP_All FP_new_service FP_revisits_service Stillbirth_all Stillbirth_fresh Stillbirth_macerated Under5_death Maternal_death)
rename per_dist_no_missing mean_all_service
gen dq_by_service="% of districts with no missing monthly values - by service"
order dq_by_service,after(year)
gen dq_all_services="DQ 1c - Percentage of districts with no missing monthly values by year (National average of ANC1, ANC4, delivery, Penta1, Penta3, opd)"
insobs 1 
save "_DQ_score_perc_districts_no_missing_values.dta",replace

**************************************************

** 2. Extreme outliers (green > 95%)

*** 2a. % of monthly values that are not extreme outliers (mean, national)

use "_tmp_daq_2a_2b_dataset.dta",clear
	
*br district year month anc1_tt_y_outlier5std anc4_count_y anc4_tt_y_outlier5std anc1_count_y 
collapse (first) anc1_tt_y_outlier5std anc4_tt_y_outlier5std ipt2_tt_y_outlier5std idelv_tt_y_outlier5std sba_tt_y_outlier5std csection_tt_y_outlier5std pnc48h_tt_y_outlier5std bcg_tt_y_outlier5std penta1_tt_y_outlier5std penta3_tt_y_outlier5std measles1_tt_y_outlier5std opd_total_tt_y_outlier5std opd_under5_tt_y_outlier5std ipd_total_tt_y_outlier5std ipd_under5_tt_y_outlier5std fp_total_tt_y_outlier5std fp_new_tt_y_outlier5std fp_revisits_tt_y_outlier5std tot_stillb_tt_y_outlier5std stillb_f_tt_y_outlier5std stillb_m_tt_y_outlier5std u5_death_tt_y_outlier5std mat_death_tt_y_outlier5std anc1_count_y anc4_count_y ipt2_count_y idelv_count_y sba_count_y csection_count_y pnc48h_count_y bcg_count_y penta1_count_y penta3_count_y measles1_count_y opd_total_count_y opd_under5_count_y ipd_total_count_y ipd_under5_count_y fp_total_count_y fp_new_count_y fp_revisits_count_y tot_stillb_count_y stillb_f_count_y stillb_m_count_y u5_death_count_y mat_death_count_y, by(year)

gen anc1=.	//*
gen anc4=.
gen ipt2=.
gen idelv=.
gen sba=.
gen csection=.
gen pnc48h=.
gen bcg=.
gen penta1=.
gen penta3=.
gen measles1=.
gen opd_total=.
gen opd_under5=.
gen ipd_total=.
gen ipd_under5=.
gen fp_total=.
gen fp_new=.
gen fp_revisits=.
gen tot_stillb=.
gen stillb_f=.
gen stillb_m=.
gen u5_death=.
gen mat_death=.

foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death	{
gen `var'_percnoout_y=(`var'_count_y-`var'_tt_y_outlier5std)/`var'_count_y*100
format `var'_percnoout_y %5.0f
lab var `var'_percnoout_y "% of `var' monthly values that are not extreme outliers in `year'"
}
keep year anc1_percnoout_y anc4_percnoout_y ipt2_percnoout_y idelv_percnoout_y sba_percnoout_y csection_percnoout_y pnc48h_percnoout_y bcg_percnoout_y penta1_percnoout_y penta3_percnoout_y measles1_percnoout_y opd_total_percnoout_y opd_under5_percnoout_y ipd_total_percnoout_y ipd_under5_percnoout_y fp_total_percnoout_y fp_new_percnoout_y fp_revisits_percnoout_y tot_stillb_percnoout_y stillb_f_percnoout_y stillb_m_percnoout_y u5_death_percnoout_y mat_death_percnoout_y
egen perc_not_outlier_year=rowmean(anc1_percnoout_y anc4_percnoout_y idelv_percnoout_y penta1_percnoout_y penta3_percnoout_y opd_total_percnoout_y)		//*/
format perc_not_outlier_year %5.0f
lab var perc_not_outlier_year "Percentage of monthly values that are not extreme outliers (National average of ANC1, ANC4, delivery, Penta1, Penta3, opd)"

rename (anc1_percnoout_y anc4_percnoout_y ipt2_percnoout_y idelv_percnoout_y sba_percnoout_y csection_percnoout_y pnc48h_percnoout_y bcg_percnoout_y penta1_percnoout_y penta3_percnoout_y measles1_percnoout_y opd_total_percnoout_y opd_under5_percnoout_y ipd_total_percnoout_y ipd_under5_percnoout_y fp_total_percnoout_y fp_new_percnoout_y fp_revisits_percnoout_y tot_stillb_percnoout_y stillb_f_percnoout_y stillb_m_percnoout_y u5_death_percnoout_y mat_death_percnoout_y) (ANC1_service ANC4_service IPT2_service Delivery_service SBA_service CSection_service PNC48h_service BCG_service Penta1_service Penta3_service Measles1_service OPD_All OPD_under5_service IPD_All IPD_under5_service FP_All FP_new_service FP_revisits_service Stillbirth_all Stillbirth_fresh Stillbirth_macerated Under5_death Maternal_death)

rename perc_not_outlier_year mean_all_service
gen dq_by_service="% of monthly values that are not extreme outliers - by service"
order dq_by_service,after(year)
gen dq_all_services="DQ 2a - Percentage of monthly values that are not extreme outliers"
insobs 1 
save "_DQ_score_perc_monthly_values_not_outliers.dta",replace


**************************************************

*** 2b. % of districts with no extreme outliers in the year

use "_tmp_daq_2a_2b_dataset.dta",clear
sort district year month
*br district year month anc1_tt_dy_outlier5std anc4_tt_dy_outlier5std idelv_tt_dy_outlier5std penta1_tt_dy_outlier5std penta3_tt_dy_outlier5std opd_total_tt_dy_outlier5std
*tab1 anc1_tt_dy_outlier5std anc4_tt_dy_outlier5std idelv_tt_dy_outlier5std penta1_tt_dy_outlier5std penta3_tt_dy_outlier5std opd_total_tt_dy_outlier5std
collapse (first) anc1_tt_dy_outlier5std anc4_tt_dy_outlier5std ipt2_tt_dy_outlier5std idelv_tt_dy_outlier5std sba_tt_dy_outlier5std csection_tt_dy_outlier5std pnc48h_tt_dy_outlier5std bcg_tt_dy_outlier5std penta1_tt_dy_outlier5std penta3_tt_dy_outlier5std measles1_tt_dy_outlier5std opd_total_tt_dy_outlier5std opd_under5_tt_dy_outlier5std ipd_total_tt_dy_outlier5std ipd_under5_tt_dy_outlier5std fp_total_tt_dy_outlier5std fp_new_tt_dy_outlier5std fp_revisits_tt_dy_outlier5std tot_stillb_tt_dy_outlier5std stillb_f_tt_dy_outlier5std stillb_m_tt_dy_outlier5std u5_death_tt_dy_outlier5std mat_death_tt_dy_outlier5std, by(district year)
foreach var of varlist anc1_tt_dy_outlier5std anc4_tt_dy_outlier5std ipt2_tt_dy_outlier5std idelv_tt_dy_outlier5std sba_tt_dy_outlier5std csection_tt_dy_outlier5std pnc48h_tt_dy_outlier5std bcg_tt_dy_outlier5std penta1_tt_dy_outlier5std penta3_tt_dy_outlier5std measles1_tt_dy_outlier5std opd_total_tt_dy_outlier5std opd_under5_tt_dy_outlier5std ipd_total_tt_dy_outlier5std ipd_under5_tt_dy_outlier5std fp_total_tt_dy_outlier5std fp_new_tt_dy_outlier5std fp_revisits_tt_dy_outlier5std tot_stillb_tt_dy_outlier5std stillb_f_tt_dy_outlier5std stillb_m_tt_dy_outlier5std u5_death_tt_dy_outlier5std mat_death_tt_dy_outlier5std	 {
replace `var' =1 if `var'>0 & `var' !=.
}			

	* % of districts with no ANC1 extreme outliers in the year
*br district year anc1_tt_dy_outlier5std
gen anc1=.	//*
gen anc4=.
gen ipt2=.
gen idelv=.
gen sba=.
gen csection=.
gen pnc48h=.
gen bcg=.
gen penta1=.
gen penta3=.
gen measles1=.
gen opd_total=.
gen opd_under5=.
gen ipd_total=.
gen ipd_under5=.
gen fp_total=.
gen fp_new=.
gen fp_revisits=.
gen tot_stillb=.
gen stillb_f=.
gen stillb_m=.
gen u5_death=.
gen mat_death=.

local firstyear=${firstyear}
local lastyear=${lastyear}
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death	{
forval year=`firstyear'/`lastyear'	{
egen `var'_num_out_d_`year'=total(`var'_tt_dy_outlier5std) if year==`year',by(year)
egen `var'_den_out_d_`year'=count(`var'_tt_dy_outlier5std) if year==`year',by(year)
gen `var'_percnoout_d_`year'=(`var'_den_out_d_`year'-`var'_num_out_d_`year')/`var'_den_out_d_`year'*100
format `var'_percnoout_d_`year' %5.0f
lab var `var'_percnoout_d_`year' "Percentage of districts with `var' extreme outliers in `year'"
}
}
collapse (first) anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death  *_percnoout_d_2017 *_percnoout_d_2018 *_percnoout_d_2019 *_percnoout_d_2020 *_percnoout_d_2021,by(year)
foreach var of varlist	anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits tot_stillb stillb_f stillb_m u5_death mat_death	{
gen `var'_pd_nooutlier=.
replace `var'_pd_nooutlier=`var'_percnoout_d_2017 if year==2017
replace `var'_pd_nooutlier=`var'_percnoout_d_2018 if year==2018
replace `var'_pd_nooutlier=`var'_percnoout_d_2019 if year==2019
replace `var'_pd_nooutlier=`var'_percnoout_d_2020 if year==2020
replace `var'_pd_nooutlier=`var'_percnoout_d_2021 if year==2021
lab var `var'_pd_nooutlier "% of districts with no `var' extreme outliers in the year"
format `var'_pd_nooutlier %5.0f
}
keep year anc1_pd_nooutlier anc4_pd_nooutlier ipt2_pd_nooutlier idelv_pd_nooutlier sba_pd_nooutlier csection_pd_nooutlier pnc48h_pd_nooutlier bcg_pd_nooutlier penta1_pd_nooutlier penta3_pd_nooutlier measles1_pd_nooutlier opd_total_pd_nooutlier opd_under5_pd_nooutlier ipd_total_pd_nooutlier ipd_under5_pd_nooutlier fp_total_pd_nooutlier fp_new_pd_nooutlier fp_revisits_pd_nooutlier tot_stillb_pd_nooutlier stillb_f_pd_nooutlier stillb_m_pd_nooutlier u5_death_pd_nooutlier mat_death_pd_nooutlier

local firstyear=${firstyear}
local lastyear=${lastyear}
forval year=`firstyear'/`lastyear'	{
egen percnoout_d_`year'=rowmean(anc1_pd_nooutlier anc4_pd_nooutlier idelv_pd_nooutlier penta1_pd_nooutlier penta3_pd_nooutlier opd_total_pd_nooutlier) if year==`year'	//*/
format percnoout_d_`year' %5.0f
}
gen per_district_no_outlier=.
replace per_district_no_outlier=percnoout_d_2017 if year==2017
replace per_district_no_outlier=percnoout_d_2018 if year==2018
replace per_district_no_outlier=percnoout_d_2019 if year==2019
replace per_district_no_outlier=percnoout_d_2020 if year==2020
replace per_district_no_outlier=percnoout_d_2021 if year==2021

format per_district_no_outlier %5.0f
lab var per_district_no_outlier "Percentage of districts with reporting rate in `year' (National average of ANC1, ANC4, delivery, Penta1, Penta3, opd)"
keep year anc1_pd_nooutlier anc4_pd_nooutlier ipt2_pd_nooutlier idelv_pd_nooutlier sba_pd_nooutlier csection_pd_nooutlier pnc48h_pd_nooutlier bcg_pd_nooutlier penta1_pd_nooutlier penta3_pd_nooutlier measles1_pd_nooutlier opd_total_pd_nooutlier opd_under5_pd_nooutlier ipd_total_pd_nooutlier ipd_under5_pd_nooutlier fp_total_pd_nooutlier fp_new_pd_nooutlier fp_revisits_pd_nooutlier tot_stillb_pd_nooutlier stillb_f_pd_nooutlier stillb_m_pd_nooutlier u5_death_pd_nooutlier mat_death_pd_nooutlier per_district_no_outlier

rename (anc1_pd_nooutlier anc4_pd_nooutlier ipt2_pd_nooutlier idelv_pd_nooutlier sba_pd_nooutlier csection_pd_nooutlier pnc48h_pd_nooutlier bcg_pd_nooutlier penta1_pd_nooutlier penta3_pd_nooutlier measles1_pd_nooutlier opd_total_pd_nooutlier opd_under5_pd_nooutlier ipd_total_pd_nooutlier ipd_under5_pd_nooutlier fp_total_pd_nooutlier fp_new_pd_nooutlier fp_revisits_pd_nooutlier tot_stillb_pd_nooutlier stillb_f_pd_nooutlier stillb_m_pd_nooutlier u5_death_pd_nooutlier mat_death_pd_nooutlier) (ANC1_service ANC4_service IPT2_service Delivery_service SBA_service CSection_service PNC48h_service BCG_service Penta1_service Penta3_service Measles1_service OPD_All OPD_under5_service IPD_All IPD_under5_service FP_All FP_new_service FP_revisits_service Stillbirth_all Stillbirth_fresh Stillbirth_macerated Under5_death Maternal_death)

rename per_district_no_outlier mean_all_service
gen dq_by_service="% of districts with no extreme outliers - by service"
order dq_by_service,after(year)
gen dq_all_services="DQ 2b - Percentage of districts with no extreme outliers in the year"
insobs 1 
save "_DQ_score_perc_districts_with_no_outliers.dta",replace

**************************************************

** 3. Consistency of annual reporting (green>85%)


*** 3a. % of districts with ANC1-Penta1 ratio between 1.0 and 1.5

use "${country}_Comparing_reported_and_adjusted_data.dta",clear

*br district year anc1 penta1
keep district year anc1 penta1
rename (anc1 penta1) (anc1_ penta1_) 
reshape wide anc1 penta1, i(district) j(year)

local firstyear=${firstyear}
local lastyear=${lastyear}
forval year=`firstyear'/`lastyear'	{
gen ratio_anc1_penta1_`year'=anc1_`year'/penta1_`year'
egen num_anc1_penta1_`year'=total(cond(ratio_anc1_penta1_`year'>=1 & ratio_anc1_penta1_`year'<=1.5,1,0))
egen den_anc1_penta1_`year'=count(ratio_anc1_penta1_`year')
gen cons_anc1_penta1_`year'=(num_anc1_penta1_`year'/ den_anc1_penta1_`year')*100
format cons_anc1_penta1_`year' %5.0f
lab var cons_anc1_penta1_`year' "% of districts with adequate ratio between ANC1 and Penta1 (between 1.0 and 1.5) in `year'"
egen mean_ratio_anc1_penta1_`year'=mean(ratio_anc1_penta1_`year')
format mean_ratio_anc1_penta1_`year' %10.2f
lab var mean_ratio_anc1_penta1_`year' "Average ratio between ANC1 and Penta1 at national level in `year'"
}
collapse (first) cons_anc1_penta1_* mean_ratio_anc1_penta1_*
gen order=_n
reshape long cons_anc1_penta1_ mean_ratio_anc1_penta1_, i(order) j(year)
lab var mean_ratio_anc1_penta1_ "Average ratio between ANC1 and Penta1 at national level by year"
rename (cons_anc1_penta1_ mean_ratio_anc1_penta1_) (mean_all_service mean_ratio_anc1_penta1)
drop order
gen dq3_ratio_reporting="Mean ratio between ANC1 and Penta1 at national level by year"
lab var dq3_ratio_reporting "Average ratio between ANC1 and Penta1 at national level by year"
gen dq_all_services="DQ 3a - Percentage of districts with adequate ratio between ANC1 and Penta1 (between 1.0 and 1.5) by year"
order year dq_all_services mean_all_service dq3_ratio_reporting mean_ratio_anc1_penta1
insobs 1
save "_DQ_score_perc_districts_adequate ratio_between_anc1_penta1.dta",replace


**************************************************


*** 3b. % of districts with Penta1-Penta3 ratio between 1.0 and 1.5

use "${country}_Comparing_reported_and_adjusted_data.dta",clear

*br district year penta1 penta3
keep district year penta1 penta3
rename (penta1 penta3) (penta1_ penta3_) 
reshape wide penta1 penta3, i(district) j(year)

local firstyear=${firstyear}
local lastyear=${lastyear}
forval year=`firstyear'/`lastyear'	{
gen ratio_penta1_penta3_`year'=penta1_`year'/penta3_`year'
egen num_penta1_penta3_`year'=total(cond(ratio_penta1_penta3_`year'>=1 & ratio_penta1_penta3_`year'<=1.5,1,0))
egen den_penta1_penta3_`year'=count(ratio_penta1_penta3_`year')
gen cons_penta1_penta3_`year'=(num_penta1_penta3_`year'/ den_penta1_penta3_`year')*100
format cons_penta1_penta3_`year' %5.0f
lab var cons_penta1_penta3_`year' "% of districts with adequate ratio between penta1 and penta3 (between 1.0 and 1.5) in `year'"
egen mean_ratio_penta1_penta3_`year'=mean(ratio_penta1_penta3_`year')
format mean_ratio_penta1_penta3_`year' %10.2f
lab var mean_ratio_penta1_penta3_`year' "Average ratio between Penta1 and Penta3 at national level in `year'"
}
collapse (first) cons_penta1_penta3_* mean_ratio_penta1_penta3_*
gen order=_n
reshape long cons_penta1_penta3_ mean_ratio_penta1_penta3_, i(order) j(year)
lab var mean_ratio_penta1_penta3 "Average ratio between Penta1 and Penta3 at national level by year"
rename (cons_penta1_penta3_ mean_ratio_penta1_penta3_) (mean_all_service mean_ratio_penta1_penta3)
drop order
gen dq3_ratio_reporting="Mean ratio between Penta1 and Penta3 at national level by year"
order dq3_ratio_reporting,before(mean_ratio_penta1_penta3)
lab var dq3_ratio_reporting "Average ratio between Penta1 and Penta3 at national level by year"
gen dq_all_services="DQ 3b - Percentage of districts with adequate ratio between Penta1 and Penta3 (between 1.0 and 1.5) by year"
order year dq_all_services mean_all_service dq3_ratio_reporting mean_ratio_penta1_penta3
insobs 1
save "_DQ_score_perc_districts_adequate ratio_between_penta1_penta3.dta",replace

**************************************************
**************************************************

*** Create overall data quality score

use "_DQ_score_reporting_rate.dta",clear
drop if year==.
replace dq_all_services="Overall data quality score (%) by year (Average DQ11a, DQ1b, DQ1c, DQ2a, DQ3a, DQ3b - National - average of ANC, delivery, vaccination, opd)"
replace dq_by_service="Overall data quality score (%) - by service & by year (Average DQ11a, DQ1b, DQ1c, DQ2a, DQ3a, DQ3b - National)"
foreach var of varlist	mean_all_service ANC_All DELIVERY_All PNC_All VACCINATION_All OPD_All IPD_All FP_All ANC1_service ANC4_service Delivery_service Penta1_service Penta3_service IPT2_service CSection_service BCG_service Measles1_service PNC48h_service	SBA_service OPD_under5_service IPD_under5_service FP_new_service FP_revisits_service Stillbirth_all Stillbirth_fresh Stillbirth_macerated Under5_death Maternal_death	{
replace `var'=.
}
save "_DQ_score_quality_template.dta",replace


use "_DQ_score_reporting_rate.dta",clear
br
append using "_DQ_score_perc_districts_over_${threshold_low_rr}.dta" "_DQ_score_perc_districts_no_missing_values.dta" "_DQ_score_perc_monthly_values_not_outliers.dta" "_DQ_score_perc_districts_with_no_outliers.dta" "_DQ_score_perc_districts_adequate ratio_between_anc1_penta1.dta" "_DQ_score_perc_districts_adequate ratio_between_penta1_penta3.dta" "_DQ_score_quality_template.dta"
rename (mean_all_service ANC_All DELIVERY_All PNC_All VACCINATION_All OPD_All IPD_All FP_All ANC1_service ANC4_service Delivery_service Penta1_service Penta3_service IPT2_service CSection_service BCG_service Measles1_service PNC48h_service SBA_service OPD_under5_service IPD_under5_service FP_new_service FP_revisits_service Stillbirth_all Stillbirth_fresh Stillbirth_macerated Under5_death Maternal_death) (all anc_all delivery_all pnc_all vaccination_all opd_all ipd_all fp_all anc1 anc4 delivery penta1 penta3 ipt2 csection bcg measles1 pnc48h sba opd_under5 ipd_under5 fp_new fp_revisits stillbirth_all stillbirth_fresh stillbirth_macerated under5_death maternal_death)
*br dq_all_services year all

local firstyear=${firstyear}
local lastyear=${lastyear}
foreach var of varlist	all	{
forval year=`firstyear'/`lastyear'	{
egen _score_`var'_`year'=mean(`var') if year==`year',by(year)
lab var _score_`var'_`year' "Overall data quality score by year"
replace `var'=_score_`var'_`year' if year==`year' & dq_all_services=="Overall data quality score (%) by year (Average DQ11a, DQ1b, DQ1c, DQ2a, DQ3a, DQ3b - National - average of ANC, delivery, vaccination, opd)" & `var'==.
}
}
*br dq_by_service year anc1

local firstyear=${firstyear}
local lastyear=${lastyear}
foreach var of varlist	anc1 anc4 delivery penta1 penta3 ipt2 csection bcg measles1 pnc48h sba opd_all opd_under5 ipd_all ipd_under5 fp_all fp_new fp_revisits stillbirth_all stillbirth_fresh stillbirth_macerated under5_death maternal_death	{
forval year=`firstyear'/`lastyear'	{
egen _score_`var'_`year'=mean(`var') if year==`year',by(year)
lab var _score_`var'_`year' "Overall data quality score by year"
replace `var'=_score_`var'_`year' if year==`year' & dq_by_service=="Overall data quality score (%) - by service & by year (Average DQ11a, DQ1b, DQ1c, DQ2a, DQ3a, DQ3b - National)" & `var'==.
}
}
drop _score_*
format all all anc_all delivery_all pnc_all vaccination_all opd_all ipd_all fp_all anc1 anc4 delivery penta1 penta3 ipt2 csection bcg measles1 pnc48h sba opd_under5 ipd_under5 fp_new fp_revisits stillbirth_all stillbirth_fresh stillbirth_macerated under5_death maternal_death %5.0f
clonevar year_service=year
order year_service,after(dq_by_service)
lab var dq_all_services "Overall Data Quality by year"
lab var dq_by_service "Data Quality by service and year"

*Drop temporary files					  
local tmpfile: dir . files "_DQ_score_*.dta"
foreach file of local tmpfile {
erase "`file'"
}
erase "_tmp_daq_2a_2b_dataset.dta"

save "1_Summary_data_quality_score_${country}.dta",replace

export excel using "1_Summary_data_quality_score_${country}", firstrow(variables) replace // LOOK FOR THE EXCEL FILE IN YOUR DIRECTORY TO SEE THE SUMMARY DATA QUALITY SCORE


*********************************************************************************************************

*Drop temporary files used for data quality assessment				  
erase "${country}_Comparing_reported_and_adjusted_data.dta"
erase "${country}_master_completnessadjusted_dataset.dta"
erase "${country}_master_completeness_&_outliers_adjusted_dataset.dta"
erase "${country}_master_non_adjusted_dataset.dta"

local tmpfile: dir . files "${country}_Low_*.dta"
foreach file of local tmpfile {
erase "`file'"
}														
local tmpfile: dir . files "${country}_Completeness_reporting_*.dta"
foreach file of local tmpfile {
erase "`file'"
}										  


					  
**************************************************************************************************************************************************************************
*END OF "3_Code_RHIS_DQA_Internal_consistency.do"
*NEXT: RUN "4_Code_RHIS_Denominators.do"
**************************************************************************************************************************************************************************					  



