********************************************************************************
********************************************************************************
*			 COUNTDOWN TO 2030 / APHRC / GFF / UNICEF / WHO		
* PRODUCING NATIONAL AND SUBNATIONAL HEALTH STATISTICS USING RHIS DATA
*		CODES - ASSESSMENT AND ADJUSTMENT FOR INCOMPLETE REPORTING (v1)
********************************************************************************
********************************************************************************

* Set Stata system capacity
clear all
set maxvar 20000
set matsize 10000
set more off,permanently

*******************************************************************************************************************
*******************************************************************************************************************

* DATA QUALITY ASSESSMENT (DQA): ASSESSMENT AND ADJUSTMENT/CORRECTION FOR INCOMPLETE REPORTING

*******************************************************************************************************************
*******************************************************************************************************************
/*READ ME

This is the do.file for assessing data quality completeness and adjust/correct for incomplete reporting. It allows to:
	- assess the data completeness,
	- assess low reporting rates
	- adjust for incomplete reporting,
	- compare reported and adjusted numbers,
The output file from these codes is "${country}_master_completnessadjusted_dataset.dta"

There are a couple of changes to make in order to run these codes.
See instructions for the changes from lines 38 to 58

*/
*******************************************************************************************************************
*******************************************************************************************************************

*PARAMETERS TO CHANGE

* Change working folder directory as per the folder where dataset to analyze is located in your computer
cd "C:\AMaiga\Dropbox\Countdown2030\CD-GFF\Workshop\2022-06_Nairobi_RHIS_WS\Analysis\Data"

* Declare your country
global country="Tanzania"     // Replace Tanzania by the name of your country

* Change the adjustment factor value for incomplete reporting for each health service
		// Use k=0 if no service expected in non-reporting facilities (DEFAULT VALUE)
		// Use k=0.25 if some service (about 25%) are expected in non-reporting, but much lower than reporting facilities
		// Use k=0.5 if half (50%) the reporting rate compared to reporting facilities
		// Use k=1 if same reporting rate of services in non-reporting facilities as reporting facilities

global k_fp=0.25			//Family planning service: Value of adjustment factor for incomplete reporting (k==0.25 default value)
global k_anc=0.25			//ANC, IPT service: Value of adjustment factor for incomplete reporting (k==0.25 default value) 
global k_idelv=0.25			//Delivery, csection service, stillbirth, neonatal deaths: Value of adjustment factor for incomplete reporting (k==0.25 default value) 
global k_pnc=0.25			//Postnatal care (e.g., pnc48h): Value of adjustment factor for incomplete reporting (k==0.25 default value) 
global k_vacc=0.25			//Vaccination (BCG, DPT/Penta, Measles) service: Value of adjustment factor for incomplete reporting (k==0.25 default value) 
global k_opd=0.25			//OPD visits: Value of adjustment factor for incomplete reporting (k==0.25 default value) 
global k_ipd=0.25			//IPD admissions: Value of adjustment factor for incomplete reporting (k==0.25 default value) 

*******************************************************************************************************************

**ASSESSMENT DATA FOR INCOMPLETE REPORTING


*COMPLETENESS SERVICE AT NATONAL LEVEL AND BY YEAR

use "${country}_Completeness_reporting_by_year_national.dta",clear	 									

foreach var of varlist anc_rr idelv_rr pnc_rr vacc_rr opd_rr 	 { 
twoway (line `var' year, sort lwidth(medthick) lcolor(black) lpattern(solid)), subtitle(, size(medsmall) nobox) ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Reporting rate (%)", size(small)) xlabel(2017(1)2021, labsize(medsmall)) xtitle("Year", size(small)) title("`var' national reporting rate over time, ${country}", size(small) position(12)) note(, size(tiny) color(white)) scheme(s1color) graphregion(ifcolor(white)) plotregion(fcolor(white)) saving("Reporting_rate_g1_`var'_over_time_national",replace)		
}
graph combine "Reporting_rate_g1_anc_rr_over_time_national" "Reporting_rate_g1_idelv_rr_over_time_national" "Reporting_rate_g1_vacc_rr_over_time_national" "Reporting_rate_g1_opd_rr_over_time_national", rows(2) cols(2) title("Completeness of reporting rate for ANC, delivery, vaccinaton and OPD over time, ${country}", size(small) position(12)) saving("Graph_${country}_Completeness_Reporting_rate_g1_over_time_national",replace)

foreach var of varlist pnc_rr ipd_rr fp_rr 	 { 
twoway (line `var' year, sort lwidth(medthick) lcolor(black) lpattern(solid)), subtitle(, size(medsmall) nobox) ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Reporting rate (%)", size(small)) xlabel(2017(1)2021, labsize(medsmall)) xtitle("Year", size(small)) title("`var' national reporting rate over time, ${country}", size(small) position(12)) note(, size(tiny) color(white)) scheme(s1color) graphregion(ifcolor(white)) plotregion(fcolor(white)) saving("Reporting_rate_g2_`var'_over_time_national",replace)		
}
graph combine "Reporting_rate_g2_pnc_rr_over_time_national" "Reporting_rate_g2_ipd_rr_over_time_national" "Reporting_rate_g2_fp_rr_over_time_national", rows(2) cols(2) title("Completeness of reporting rate for PNC, IPD admission and Family Planning over time, ${country}", size(small) position(12)) saving("Graph_${country}_Completeness_Reporting_rate_g2_over_time_national",replace)

*Drop temporary graphs					  
local tmpfile: dir . files "Reporting_rate_*.gph"
foreach file of local tmpfile {
erase "`file'"
} 			

************************************

*COMPLETENESS SERVICE BY AREA OF LOCATION (RURAL, URBAN, MIXED) AND BY YEAR

use "${country}_Completeness_reporting_by_urban_rural_&_year.dta",clear	 									

foreach var of varlist anc_rr idelv_rr pnc_rr vacc_rr opd_rr 	 {
twoway (line `var' year, sort lwidth(medthick) lcolor(black) lpattern(solid)), by(urban_rural, rows(1)) subtitle(, size(small) nobox) ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Reporting rate (%)", size(small)) xlabel(2017(1)2021, labsize(vsmall)) xtitle("Year", size(small)) by(, title("`var' reporting rate over time by area of location", size(small) position(12)) note(, size(tiny) color(white))) scheme(s1color) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Reporting_rate_g1_`var'_over_time_by_area_location",replace)											
}	
graph combine "Reporting_rate_g1_anc_rr_over_time_by_area_location" "Reporting_rate_g1_idelv_rr_over_time_by_area_location" "Reporting_rate_g1_vacc_rr_over_time_by_area_location" "Reporting_rate_g1_opd_rr_over_time_by_area_location", rows(2) cols(2) title("Completeness of reporting rate for ANC, delivery, vaccinaton and OPD over time by area, ${country}", size(small) position(12)) saving("Graph_${country}_Completeness_Reporting_rate_g1_over_time_by_area_location",replace)

foreach var of varlist pnc_rr ipd_rr fp_rr 	 {
twoway (line `var' year, sort lwidth(medthick) lcolor(black) lpattern(solid)), by(urban_rural, rows(1)) subtitle(, size(small) nobox) ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Reporting rate (%)", size(small)) xlabel(2017(1)2021, labsize(vsmall)) xtitle("Year", size(small)) by(, title("`var' reporting rate over time by area of location", size(small) position(12)) note(, size(tiny) color(white))) scheme(s1color) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Reporting_rate_g2_`var'_over_time_by_area_location",replace)											
}	
graph combine "Reporting_rate_g2_pnc_rr_over_time_by_area_location" "Reporting_rate_g2_ipd_rr_over_time_by_area_location" "Reporting_rate_g2_fp_rr_over_time_by_area_location", rows(2) cols(2) title("Completeness of reporting rate for PNC, IPD admission, and Family Planning over time by area, ${country}", size(small) position(12)) saving("Graph_${country}_Completeness_Reporting_rate_g2_over_time_by_area_location",replace)

*Drop temporary graphs					  
local tmpfile: dir . files "Reporting_rate_*.gph"
foreach file of local tmpfile {
erase "`file'"
} 																																										

************************************

*COMPLETENESS SERVICE BY SUB-ADMINISTRATIVE UNIT AND BY YEAR

use "${country}_Completeness_reporting_by_adminlevel_1_&_year.dta",clear	 									

cap drop groupadmin_unit
gen groupadmin_unit=ceil(adminlevel_1/20)   /* create group of 20 administrative units; can change 20 to whichever number one desires per page */
local l=1
sum groupadmin_unit
local j=r(max)
forval t=1/`j' {
foreach var of varlist anc_rr	 { 		//This code runs for ANC reporting rate (anc_rr) only. You can run for more variables (e.g., idelv_rr, pnc_rr, vacc_rr, opd_rr, ipd_rr & fp_rr)
twoway (line `var' year, sort lwidth(medthick) lcolor(black) lpattern(solid)) if groupadmin_unit==`t', by(adminlevel_1, rows(4)) subtitle(, size(medsmall) nobox) ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Reporting rate (%)", size(small)) xlabel(2017(1)2021, labsize(medsmall)) xtitle("Year", size(small)) by(, title("Completeness of reporting rate for `var' over time by administrative unit, ${country}", size(small) position(12)) note(, size(tiny) color(white))) scheme(s1color) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) 	saving("Graph_${country}_Completeness_reporting_rate_`var'_over_time_in_administrative_unit_gr`t'",replace)		
}
}
																																															
************************************

*COMPLETENESS SERVICE BY DISTRICT AND BY YEAR

use "${country}_Completeness_reporting_by_district_&_year.dta",clear	 									

cap drop groupdistrict
gen groupdistrict=ceil(district/20)   /* create group of 20 districts; can change 20 to whichever number one desires per page */
local l=1
sum groupdistrict
local j=r(max)
forval t=1/`j' {
foreach var of varlist anc_rr	 { 		//This code runs for ANC reporting rate (anc_rr) only. You can run for more variables (e.g., idelv_rr, pnc_rr, vacc_rr, opd_rr, ipd_rr & fp_rr)
twoway (line `var' year, sort lwidth(medthick) lcolor(black) lpattern(solid)) if groupdistrict==`t', by(district, rows(4)) subtitle(, size(medsmall) nobox) ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid))  ytitle("Reporting rate (%)", size(small)) xlabel(2017(1)2021, labsize(medsmall)) xtitle("Year", size(small)) by(, title("Completeness of reporting rate for `var' over time by district, ${country}", size(small) position(12)) note(, size(tiny) color(white))) scheme(s1color) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Graph_${country}_Completeness_reporting_rate_`var'_over_time_in_districts_gr`t'",replace)			
}
}

																								
************************************

*LOW REPORTING RATE BY SERVICE AND BY YEAR

use "${country}_Low_reporting_by_year.dta",clear	 									

/* Graphs below run for FP, ANC, Institutional delivery, vaccination, OPD, IPD. You can change your target indicators adding or removing indicators as needed*/

* Percentage of districts with family planning reporting below ${threshold_low_rr}
display  ${threshold_low_rr}

graph bar lowc_17_fp lowc_18_fp lowc_19_fp lowc_20_fp lowc_21_fp, ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid)) ytitle("%", size(small)) title("Family planning", size(medium) position(12)) note(, size(tiny) color(white)) legend(symxsize(2) symysize(2) order(1 "2017"  2 "2018"  3 "2019" 4 "2020" 5 "2021") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) bargap(5) blabel(bar, position(inside) format(%5.0f) color(white)) saving("Graph_${country}_Perc_districts_fp_low_reporting_rate",replace)

* Percentage of districts with ANC reporting below ${threshold_low_rr}									
graph bar lowc_17_anc lowc_18_anc lowc_19_anc lowc_20_anc lowc_21_anc, ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid)) ytitle("%", size(small)) title("ANC", size(medium) position(12)) note(, size(tiny) color(white)) legend(symxsize(2) symysize(2) order(1 "2017"  2 "2018"  3 "2019" 4 "2020" 5 "2021") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) bargap(5) blabel(bar, position(inside) format(%5.0f) color(white)) saving("Graph_${country}_Perc_districts_anc_low_reporting_rate",replace)

* Percentage of districts with institutional delivery reporting below ${threshold_low_rr} 								
graph bar lowc_17_idelv lowc_18_idelv lowc_19_idelv lowc_20_idelv lowc_21_idelv, ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid)) ytitle("%", size(small)) title("Delivery", size(medium) position(12)) note(, size(tiny) color(white)) legend(symxsize(2) symysize(2) order(1 "2017"  2 "2018"  3 "2019" 4 "2020" 5 "2021") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) bargap(5) blabel(bar, position(inside) format(%5.0f) color(white)) saving("Graph_${country}_Perc_districts_idelv_low_reporting_rate",replace)

* Percentage of districts with vaccination reporting below ${threshold_low_rr}
graph bar lowc_17_vacc lowc_18_vacc lowc_19_vacc lowc_20_vacc lowc_21_vacc, ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid)) ytitle("%", size(small)) title("Vaccination", size(medium) position(12)) note(, size(tiny) color(white)) legend(symxsize(2) symysize(2) order(1 "2017"  2 "2018"  3 "2019" 4 "2020" 5 "2021") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) bargap(5) blabel(bar, position(inside) format(%5.0f) color(white)) saving("Graph_${country}_Perc_districts_vacc_low_reporting_rate",replace)

* Percentage of districts with OPD visits reporting below ${threshold_low_rr}									
graph bar lowc_17_opd lowc_18_opd lowc_19_opd lowc_20_opd lowc_21_opd, ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid)) ytitle("%", size(small)) title("OPD visits", size(medium) position(12)) note(, size(tiny) color(white)) legend(symxsize(2) symysize(2) order(1 "2017"  2 "2018"  3 "2019" 4 "2020" 5 "2021") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) bargap(5) blabel(bar, position(inside) format(%5.0f) color(white)) saving("Graph_${country}_Perc_districts_opd_low_reporting_rate",replace)

* Percentage of districts with IPD admissions reporting below ${threshold_low_rr}
graph bar lowc_17_ipd lowc_18_ipd lowc_19_ipd lowc_20_ipd lowc_21_ipd, ylabel(0(25)100, labsize(small) glwidth(thin) glcolor(gs15) glpattern(solid)) ytitle("%", size(small)) title("IPD admissions", size(medium) position(12)) note(, size(tiny) color(white)) legend(symxsize(2) symysize(2) order(1 "2017"  2 "2018"  3 "2019" 4 "2020" 5 "2021") size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6)) scheme(s1color) bargap(5) blabel(bar, position(inside) format(%5.0f) color(white)) saving("Graph_${country}_Perc_districts_ipd_low_reporting_rate",replace)

* Combining graphs of percentage of districts with reporting below ${threshold_low_rr} by service and year
graph combine "Graph_${country}_Perc_districts_fp_low_reporting_rate" "Graph_${country}_Perc_districts_anc_low_reporting_rate" "Graph_${country}_Perc_districts_idelv_low_reporting_rate" "Graph_${country}_Perc_districts_vacc_low_reporting_rate" "Graph_${country}_Perc_districts_opd_low_reporting_rate" "Graph_${country}_Perc_districts_ipd_low_reporting_rate", rows(2) cols(3) title("Percentage of districts with low reporting rate (<${threshold_low_rr}%) by service and by year, ${country}", size(small) position(12)) note(Low reporting rate (<${threshold_low_rr}%) , size(small) color(gray)) saving("Graph_${country}_Percentage_districts_low_reporting_rate_by_service_by_year",replace)
		
*Drop temporary graphs					  
local tmpfile: dir . files "Graph_${country}_Perc_districts_*.gph"
foreach file of local tmpfile {
erase "`file'"
}

*Identification of districts with low reporting
									
use "${country}_Low_reporting_by_district_by_year.dta",clear	 									

/* Graphs below run for FP, ANC, Institutional delivery, vaccination, OPD, IPD. You can change your target indicators adding or removing indicators as needed*/

log using "Log_${country}_identification_districts_low_reporting",replace

list district anc_rr2017 anc_rr2018 anc_rr2019 anc_rr2020 anc_rr2021 if lowc_17_anc==1 | lowc_18_anc==1 | lowc_19_anc==1 | lowc_20_anc==1 | lowc_21_anc==1,abbrev(15) noobs			//List of districts with ANC reporting below ${threshold_low_rr}
list district idelv_rr2017 idelv_rr2018 idelv_rr2019 idelv_rr2020 idelv_rr2021 if lowc_17_idelv==1 | lowc_18_idelv==1 | lowc_19_idelv==1 | lowc_20_idelv==1 | lowc_21_idelv==1,abbrev(15) noobs		//List of districts with idelv_rr reporting below ${threshold_low_rr}
list district pnc_rr2017 pnc_rr2018 pnc_rr2019 pnc_rr2020 pnc_rr2021 if lowc_17_pnc==1 | lowc_18_pnc==1 | lowc_19_pnc==1 | lowc_20_pnc==1 | lowc_21_pnc==1,abbrev(15) noobs		//List of districts with pnc_rr reporting below ${threshold_low_rr}
list district vacc_rr2017 vacc_rr2018 vacc_rr2019 vacc_rr2020 vacc_rr2021 if lowc_17_vacc==1 | lowc_18_vacc==1 | lowc_19_vacc==1 | lowc_20_vacc==1 | lowc_21_vacc==1,abbrev(15) noobs	//List of districts with vacc reporting below ${threshold_low_rr}
list district opd_rr2017 opd_rr2018 opd_rr2019 opd_rr2020 opd_rr2021 if lowc_17_opd==1 | lowc_18_opd==1 | lowc_19_opd==1 | lowc_20_opd==1 | lowc_21_opd==1,abbrev(15) noobs			//List of districts with opd reporting below ${threshold_low_rr}
list district ipd_rr2017 ipd_rr2018 ipd_rr2019 ipd_rr2020 ipd_rr2021 if lowc_17_ipd==1 | lowc_18_ipd==1 | lowc_19_ipd==1 | lowc_20_ipd==1 | lowc_21_ipd==1,abbrev(15) noobs			//List of districts with ipd reporting below ${threshold_low_rr}
list district fp_rr2017 fp_rr2018 fp_rr2019 fp_rr2020 fp_rr2021 if lowc_17_fp==1 | lowc_18_fp==1 | lowc_19_fp==1 | lowc_20_fp==1 | lowc_21_fp==1,abbrev(15) noobs			//List of districts with fp reporting below ${threshold_low_rr}

log close																								
																								

*******************************************************************************************************************

**CORRECTION OF LOW REPORTING RATES (OUTLIERS) BY DISTRICT OVER TIME

use "${country}_master_non_adjusted_dataset.dta",clear		

foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths  {
replace rr_`var'=rr_`var'_adj if inlist(lowc_`var',1,9)
replace rr_`var'=round(rr_`var',.1)
}	

replace anc_rr=rr_anc1
replace idelv_rr=rr_idelv 
replace pnc_rr=rr_pnc48h 
replace vacc_rr=rr_penta3 
replace opd_rr=rr_opd_total 
replace ipd_rr=rr_ipd_total 
replace fp_rr=rr_fp_total

foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths 	{
drop `var'_mad `var'_med max_`var'_mad max_`var'_med max_rr_`var'_med rr_`var'_med `var'_ratio_rep_med lowc_`var' rr_`var'_adj `var'_outlb5std `var'_outub5std maxlowc_`var' rr_`var'
}

save "${country}_master_non_adjusted_dataset.dta",replace						  
				  
		  
*******************************************************************************************************************

**ADJUSTMENT/CORRECTION OF SERVICE DATA FOR INCOMPLETE REPORTING

use "${country}_master_non_adjusted_dataset.dta",clear		

foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths	{
rename `var' _`var'
}		 
rename (anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr) (rr_anc rr_idelv rr_pnc rr_vacc rr_opd rr_ipd rr_fp)													
		
*Adjustment of ANC service for incomplete reporting
clonevar anc1=_anc1
replace  anc1=round(_anc1 * (1 + (1/(rr_anc/100)-1)*${k_anc}),1) if !inlist(rr_anc,0,.)									//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of ANC4 service for incomplete reporting
clonevar anc4=_anc4
replace  anc4=round(_anc4 * (1 + (1/(rr_anc/100)-1)*${k_anc}),1) if !inlist(rr_anc,0,.) 								//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of IPT2 service for incomplete reporting
clonevar ipt2=_ipt2
replace  ipt2=round(_ipt2 * (1 + (1/(rr_anc/100)-1)*${k_anc}),1) if !inlist(rr_anc,0,.) 								//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of institutional delivery service for incomplete reporting
clonevar idelv=_idelv
replace idelv=round(_idelv * (1 + (1/(rr_idelv/100)-1)*${k_idelv}),1) if !inlist(rr_idelv,0,.) 							//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of skilled birth attendant service for incomplete reporting
clonevar sba=_sba
replace  sba=round(_sba * (1 + (1/(rr_idelv/100)-1)*${k_idelv}),1) if !inlist(rr_idelv,0,.) 							//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of csection service for incomplete reporting
clonevar csection=_csection
replace  csection=round(_csection * (1 + (1/(rr_idelv/100)-1)*${k_idelv}),1) if !inlist(rr_idelv,0,.) 					//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of PNC service for incomplete reporting
clonevar pnc48h=_pnc48h
replace  pnc48h=round(_pnc48h * (1 + (1/(rr_pnc/100)-1)*${k_pnc}),1) if !inlist(rr_pnc,0,.)								//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of BCG service for incomplete reporting
clonevar bcg=_bcg
replace  bcg=round(_bcg * (1 + (1/(rr_vacc/100)-1)*${k_vacc}),1) if !inlist(rr_vacc,0,.) 								//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of Pentavalent 1 service for incomplete reporting
clonevar penta1=_penta1
replace  penta1=round(_penta1 * (1 + (1/(rr_vacc/100)-1)*${k_vacc}),1) if !inlist(rr_vacc,0,.) 							//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of Pentavalent 3 service for incomplete reporting
clonevar penta3=_penta3
replace  penta3=round(_penta3 * (1 + (1/(rr_vacc/100)-1)*${k_vacc}),1) if !inlist(rr_vacc,0,.) 							//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of Measles 1 service for incomplete reporting
clonevar measles1=_measles1
replace  measles1=round(_measles1 * (1 + (1/(rr_vacc/100)-1)*${k_vacc}),1) if !inlist(rr_vacc,0,.) 						//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of OPD visits for children under 5 for incomplete reporting
clonevar opd_under5=_opd_under5
replace  opd_under5=round(_opd_under5 * (1 + (1/(rr_opd/100)-1)*${k_opd}),1) if !inlist(rr_opd,0,.) 					//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of overall OPD visits for incomplete reporting
clonevar opd_total=_opd_total
replace  opd_total=round(_opd_total * (1 + (1/(rr_opd/100)-1)*${k_opd}),1) if !inlist(rr_opd,0,.) 						//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of IPD admissions visits for children under 5 for incomplete reporting
clonevar ipd_under5=_ipd_under5
replace  ipd_under5=round(_ipd_under5 * (1 + (1/(rr_ipd/100)-1)*${k_ipd}),1) if !inlist(rr_ipd,0,.) 					//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of overall IPD admissions for incomplete reporting
clonevar ipd_total=_ipd_total
replace  ipd_total=round(_ipd_total * (1 + (1/(rr_ipd/100)-1)*${k_ipd}),1) if !inlist(rr_ipd,0,.) 						//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of new family planning visits for incomplete reporting
clonevar fp_new=_fp_new
replace  fp_new=round(_fp_new * (1 + (1/(rr_fp/100)-1)*${k_fp}),1) if !inlist(rr_fp,0,.) 								//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of family planning revisits for incomplete reporting
clonevar fp_revisits=_fp_revisits
replace  fp_revisits=round(_fp_revisits * (1 + (1/(rr_fp/100)-1)*${k_fp}),1) if !inlist(rr_fp,0,.) 						//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of total family planning visits for incomplete reporting
clonevar fp_total=_fp_total
replace  fp_total=round(_fp_total * (1 + (1/(rr_fp/100)-1)*${k_fp}),1) if !inlist(rr_fp,0,.) 							//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of fresh stillbirth for incomplete reporting
clonevar stillbirth_f=_stillbirth_f
replace  stillbirth_f=round(_stillbirth_f * (1 + (1/(rr_idelv/100)-1)*${k_idelv}),1) if !inlist(rr_idelv,0,.) 			//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of macerated stillbirth for incomplete reporting
clonevar stillbirth_m=_stillbirth_m
replace  stillbirth_m=round(_stillbirth_m * (1 + (1/(rr_idelv/100)-1)*${k_idelv}),1) if !inlist(rr_idelv,0,.) 			//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of total stillbirth for incomplete reporting
clonevar total_stillbirth=_total_stillbirth
replace  total_stillbirth=round(_total_stillbirth * (1 + (1/(rr_idelv/100)-1)*${k_idelv}),1) if !inlist(rr_idelv,0,.) 	//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of maternal deaths for incomplete reporting
clonevar maternal_deaths=_maternal_deaths
replace  maternal_deaths=round(_maternal_deaths * (1 + (1/(rr_idelv/100)-1)*${k_idelv}),1) if !inlist(rr_idelv,0,.) 	//Adjustment may be combined with a condition if needed e.g., "if year==2018"
*Adjustment of under 5 deaths for incomplete reporting
clonevar under5_deaths=_under5_deaths
replace  under5_deaths=round(_under5_deaths * (1 + (1/(rr_ipd/100)-1)*${k_ipd}),1) if !inlist(rr_ipd,0,.) 				//Adjustment may be combined with a condition if needed e.g., "if year==2018"

*Labeling non-adjusted variables
foreach var of varlist _anc1 _anc4 _ipt2 _idelv _sba _csection _pnc48h _fp_total _fp_new _fp_revisits _bcg _penta1 _penta3 _measles1 _opd_total _opd_under5 _ipd_total _ipd_under5 _total_stillbirth _stillbirth_f _stillbirth_m _under5_deaths _maternal_deaths	{
rename `var' na`var'
lab var na`var' "na`var' - Non-adjusted number"
}
*order variable
foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths	{
order `var',before(na_`var')
}

save "${country}_master_completnessadjusted_dataset.dta",replace


*******************************************************************************************************************

**PREPARING THE FILE FOR COMPARING REPORTED AND ADJUSTED DATA FOR INCOMPLETE REPORTING

use "${country}_master_completnessadjusted_dataset.dta",clear

*Keep variables of interest
keep country urban_rural adminlevel_1 district year month anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths na_*

foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths na_*	{
bysort district year: gen _`var'=sum(`var')
bysort district year: replace _`var'=_`var'[_N]
preserve
collapse country urban_rural adminlevel_1 (first) _`var', by(district year)
save _district`var'.dta,replace		
restore
}

use "_districtanc1",clear
local reshapeddistrict: dir . files "_district*.dta"
foreach file of local reshapeddistrict {
merge 1:1 district year using "`file'"
drop _merge
}

rename (_anc1 _anc4 _ipt2 _idelv _sba _csection _pnc48h _bcg _penta1 _penta3 _measles1 _opd_total _opd_under5 _ipd_total _ipd_under5 _fp_total _fp_new _fp_revisits _total_stillbirth _stillbirth_f _stillbirth_m _under5_deaths _maternal_deaths) (anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths)
rename (_na_anc1 _na_anc4 _na_ipt2 _na_idelv _na_sba _na_csection _na_pnc48h _na_bcg _na_penta1 _na_penta3 _na_measles1 _na_opd_total _na_opd_under5 _na_ipd_total _na_ipd_under5 _na_fp_total _na_fp_new _na_fp_revisits _na_total_stillbirth _na_stillbirth_f _na_stillbirth_m _na_under5_deaths _na_maternal_deaths) (na_anc1 na_anc4 na_ipt2 na_idelv na_sba na_csection na_pnc48h na_bcg na_penta1 na_penta3 na_measles1 na_opd_total na_opd_under5 na_ipd_total na_ipd_under5 na_fp_total na_fp_new na_fp_revisits na_total_stillbirth na_stillbirth_f na_stillbirth_m na_under5_deaths na_maternal_deaths)

save "${country}_Comparing_reported_and_adjusted_data.dta",replace
		
 
*******************************************************************************************************************


**COMPARISON OF REPORTED AND ADJUSTED DATA FOR INCOMPLETE REPORTING

use "${country}_Comparing_reported_and_adjusted_data.dta",clear

cap drop groupdistrict
gen groupdistrict=ceil(district/20)   /* create group of 20 districts; can change 20 to whichever number one desires per page */
local l=1
sum groupdistrict
local j=r(max)
forval t=1/`j' {
foreach var of varlist anc1			  { 		//This code runs for ANC1 services (anc1) only. You can run for more variables (e.g., anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths)
twoway (line `var' year, sort lwidth(medthick) lcolor(black) lpattern(solid)) (line na_`var' year, sort lwidth(medium) lcolor(red) lpattern(dash)) if groupdistrict==`t', by(district, rows(4)) subtitle(, size(small) nobox)  ylabel(, labsize(tiny) glwidth(thin) glcolor(gs15) glpattern(solid)) ytitle("Adjusted number", size(small))  xlabel(2017(1)2021, labsize(vsmall)) xtitle("Reported number", size(small)) by(, title("Comparison of reported and adjusted number of `var' by district, ${country}", size(small) position(12)) note(, size(tiny) color(white))) legend(order(1 "Adjusted number"  2 "Reported service")  size(vsmall) linegap(tiny) colgap(tiny) rows(1) pos(6))  scheme(s1color) by(,  graphregion(ifcolor(white)) plotregion(fcolor(white))) saving("Graph_${country}_Difference_reported_expected_of_`var'_over_time_in districts_gr`t'",replace)
list district year na_`var' `var' if groupdistrict==`t'
}
}

clear

*Drop temporary files					  
local tmpfile: dir . files "_district*.dta"
foreach file of local tmpfile {
erase "`file'"
}														


**************************************************************************************************************************************************************************
*END OF "2_Code_RHIS_DQA_Completeness.do"
*NEXT: RUN "3_Code_RHIS_DQA_Internal_consistency.do"
**************************************************************************************************************************************************************************

		  