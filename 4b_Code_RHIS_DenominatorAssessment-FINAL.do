
**** HEALTH FACILITY DATA DERIVED DENOMINATORS 

* EXAMPLE USES NIGER DATASET

* Change Working directory
/* CHANGE TO YOUR WORKING DIRECTORY */
cd "C:\Users\Agbessi\Dropbox\IIP\COUNTDOWN2030\HealthFAcilityDataAnalysis\Workshop-June2022\Analysis\NIGER"

* Declare your country
global country="Niger"

* SET YOUR PARAMETERS
global pregloss=0.03 /* Pregnancy loss - default value 0.03 */
global sbr=0.02 /* Stillbirth rate: Default value 0.02 */
global twin=0.035 /* Twin rate -- Obtain from DHS for NIGER; Default value: 0.015 */
global nmr=0.024  /* neonatal mortality rate; Default value=0.03 */
global pnmr=0.0216 /* Post neonatal mortality rate; Default value 0.02 */

**** USING ANC-1 DERIVED DENOMINATORS ****************************
******************************************************************
* INPUT VALUE OF ANC-1 FROM SURVEY
global anc1_survey=0.83    /* ANC-1 Coverage from latest household survey: PLEASE CHANGE TO YOUR SPECIFIC COUNTRY VALUE */

use "${country}_master_adjusted_dataset", clear


* Compute utilization numbers
* ANC-1
sort country adminlevel_1 district year
bysort year: egen tot_anc1=total(anc1)
bysort adminlevel_1 year: egen reg_anc1=total(anc1)

* ANC4
sort country adminlevel_1 district year
bysort year: egen tot_anc4=total(anc4)
bysort adminlevel_1 year: egen reg_anc4=total(anc4)

* IPT2
bysort year: egen tot_ipt2=total(ipt2)
bysort adminlevel_1 year: egen reg_ipt2=total(ipt2)

* Institutional Deliveries
bysort year: egen tot_idelv=total(idelv)
bysort adminlevel_1 year: egen reg_idelv=total(idelv)

* BCG
bysort year: egen tot_bcg=total(bcg)
bysort adminlevel_1 year: egen reg_bcg=total(bcg)

* DPT1
bysort year: egen tot_penta1=total(penta1)
bysort adminlevel_1 year: egen reg_penta1=total(penta1)

* DPT3 
bysort year: egen tot_penta3=total(penta3)
bysort adminlevel_1 year: egen reg_penta3=total(penta3)

* Measles vaccination
bysort year: egen tot_measles1=total(measles1)
bysort adminlevel_1 year: egen reg_measles1=total(measles1)

************************************
* Generate total pregnancies
gen preg=anc1/${anc1_survey}
sort country adminlevel_1 district year
bysort year: egen tot_preg=total(preg)
bysort adminlevel_1 year: egen reg_preg=total(preg)

* Generate total deliveries
gen deliveries=preg*(1-${pregloss})
sort country adminlevel_1 district year
bysort year: egen tot_deliveries=total(deliveries)
bysort adminlevel_1 year: egen reg_deliveries=total(deliveries)

* Generate total births
gen births=deliveries*(1+${twin})
sort country adminlevel_1 district year
bysort year: egen tot_births=total(births)
bysort adminlevel_1 year: egen reg_births=total(births)

* Generate live births
gen lbirths=births*(1-${sbr})
sort country adminlevel_1 district year
bysort year: egen tot_lbirths=total(lbirths)
bysort adminlevel_1 year: egen reg_lbirths=total(lbirths)

* Generate total infants eligible for DPT1
gen inftpenta1=lbirths*(1-${nmr})
sort country adminlevel_1 district year
bysort year: egen tot_inftpenta1=total(inftpenta1)
bysort adminlevel_1 year: egen reg_inftpenta1=total(inftpenta1)

* Generate total infants eligible for measles vaccination
gen inftmeasle=inftpenta1*(1-${pnmr})
sort country adminlevel_1 district year
bysort year: egen tot_inftmeasle=total(inftmeasle)
bysort adminlevel_1 year: egen reg_inftmeasle=total(inftmeasle)

***********************************************
* Generate Coverage based on ANC-1 Coverage
* Coverage of ANC-4 
gen tot_cov_anc4=100*tot_anc4/tot_preg
gen reg_cov_anc4=100*reg_anc4/reg_preg
lab var tot_cov_anc4 "Coverage ANC-4"
lab var reg_cov_anc4 "Coverage ANC-4"

* Coverage IPT2 
gen tot_cov_ipt2=100*tot_ipt2/tot_preg
gen reg_cov_ipt2=100*reg_ipt2/reg_preg
lab var tot_cov_ipt2 "Coverage IPT2"
lab var reg_cov_ipt2 "Coverage IPT2"

* Coverage Institutional deliveries
gen tot_cov_idelv=100*tot_idelv/tot_deliveries
gen reg_cov_idelv=100*reg_idelv/reg_deliveries 
lab var tot_cov_idelv "Coverage Institutional Deliveries"
lab var reg_cov_idelv "Coverage Institutional Deliveries"

* Coverage of BCG 
gen tot_cov_bcg=100*tot_bcg/tot_lbirths
gen reg_cov_bcg=100*reg_bcg/reg_lbirths 
lab var tot_cov_bcg "BCG coverage"
lab var reg_cov_bcg "BCG coverage"

* Coverage of DPT1
gen tot_cov_penta1=100*tot_penta1/tot_inftpenta1
gen reg_cov_penta1=100*reg_penta1/reg_inftpenta1 
lab var tot_cov_penta1 "Penta-1 coverage"
lab var reg_cov_penta1 "Penta-1 coverage"

* Coverage of penta3 
gen tot_cov_penta3=100*tot_penta3/tot_inftpenta1
gen reg_cov_penta3=100*reg_penta3/reg_inftpenta1 
lab var tot_cov_penta3 "Penta 3 coverage"
lab var reg_cov_penta3 "Penta 3 coverage"

* Coverage of measles vaccination
gen tot_cov_measles1=100*tot_measles1/tot_inftmeasle
gen reg_cov_measles1=100*reg_measles1/reg_inftmeasle
lab var tot_cov_measles1 "Measles coverage"
lab var reg_cov_measles1 "Measles coverage"

* Graph coverage trends
*** National 
twoway connected tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on ANC1 derived denominators, National", size(medium)) saving("trends_coverage_anc1denom_1_${country}", replace) sort

twoway connected tot_cov_bcg tot_cov_penta1 tot_cov_penta3 tot_cov_measles1 year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on ANC1 derived denominators, National", size(medium)) saving("trends_coverage_anc1denom_2_${country}", replace) sort

*** By admin 1
twoway connected reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv year, by(adminlevel_1, title("Coverage based on ANC1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_anc1denom_admin1_1_${country}", replace) legend(size(vsmall))

twoway connected  reg_cov_bcg reg_cov_penta1 reg_cov_penta3 reg_cov_measles1 year, by(adminlevel_1, title("Coverage based on ANC1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_anc1denom_admin1_${country}", replace) legend(size(vsmall))

* Export coverage output to Excel file

save tmp, replace

collapse (max) tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta1 tot_cov_penta3 tot_cov_measles1, by(country year)
rename (tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta1 tot_cov_penta3 tot_cov_measles1) (cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta1 cov_penta3 cov_measles1)
gen area=0
save tmpcov, replace

use tmp, clear 
collapse (max) reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta1 reg_cov_penta3 reg_cov_measles1, by(country adminlevel_1 year)
rename (reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta1 reg_cov_penta3 reg_cov_measles1) (cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta1 cov_penta3 cov_measles1)

rename adminlevel_1 area
append using tmpcov

lab def first_admin_level 0"National", add
lab val area first_admin_level

sort country area year
save Coverage_based_on_ANC1, replace
export excel Coverage_based_on_ANC1.xls, firstrow(variables) replace


**************************************************************************
**************************************************************************

**** USING DPT-1 DERIVED DENOMINATORS ****************************
*****************************************************************
* INPUT VALUE OF ANC-1 FROM SURVEY
global dpt1_survey=0.84    /* ANC-1 Coverage from latest household survey: PLEASE CHANGE TO YOUR SPECIFIC COUNTRY VALUE */

use "${country}_master_adjusted_dataset", clear

* Compute utilization numbers
* ANC-1
sort country adminlevel_1 district year
bysort year: egen tot_anc1=total(anc1)
bysort adminlevel_1 year: egen reg_anc1=total(anc1)

* ANC4
sort country adminlevel_1 district year
bysort year: egen tot_anc4=total(anc4)
bysort adminlevel_1 year: egen reg_anc4=total(anc4)

* IPT2
bysort year: egen tot_ipt2=total(ipt2)
bysort adminlevel_1 year: egen reg_ipt2=total(ipt2)

* Institutional Deliveries
bysort year: egen tot_idelv=total(idelv)
bysort adminlevel_1 year: egen reg_idelv=total(idelv)

* BCG
bysort year: egen tot_bcg=total(bcg)
bysort adminlevel_1 year: egen reg_bcg=total(bcg)

* DPT1
bysort year: egen tot_penta1=total(penta1)
bysort adminlevel_1 year: egen reg_penta1=total(penta1)

* DPT3 
bysort year: egen tot_penta3=total(penta3)
bysort adminlevel_1 year: egen reg_penta3=total(penta3)

* Measles vaccination
bysort year: egen tot_measles1=total(measles1)
bysort adminlevel_1 year: egen reg_measles1=total(measles1)

************************************
* Generate total infants eligible for DPT1
gen inftpenta1=penta1/${dpt1_survey}
sort country adminlevel_1 district year
bysort year: egen tot_inftpenta1=total(inftpenta1)
bysort adminlevel_1 year: egen reg_inftpenta1=total(inftpenta1)

* Generate total infants eligible for measles vaccination
gen inftmeasle=inftpenta1*(1-${pnmr})
sort country adminlevel_1 district year
bysort year: egen tot_inftmeasle=total(inftmeasle)
bysort adminlevel_1 year: egen reg_inftmeasle=total(inftmeasle)

* Generate live births
gen lbirths=inftpenta1/(1-${nmr})
sort country adminlevel_1 district year
bysort year: egen tot_lbirths=total(lbirths)
bysort adminlevel_1 year: egen reg_lbirths=total(lbirths)

* Generate total births
gen births=lbirths/(1-${sbr})
sort country adminlevel_1 district year
bysort year: egen tot_births=total(births)
bysort adminlevel_1 year: egen reg_births=total(births)

* Generate total deliveries
gen deliveries=births/(1+${twin})
sort country adminlevel_1 district year
bysort year: egen tot_deliveries=total(deliveries)
bysort adminlevel_1 year: egen reg_deliveries=total(deliveries)

* Generate total pregnancies
gen preg=deliveries/(1-${pregloss})
sort country adminlevel_1 district year
bysort year: egen tot_preg=total(preg)
bysort adminlevel_1 year: egen reg_preg=total(preg)

***********************************************
* Generate Coverage based on DPT1 Coverage
* Coverage of ANC-1
gen tot_cov_anc1=100*tot_anc1/tot_preg
gen reg_cov_anc1=100*reg_anc1/reg_preg
lab var tot_cov_anc1 "Coverage ANC-1"
lab var reg_cov_anc1 "Coverage ANC-1"

* Coverage of ANC-4 
gen tot_cov_anc4=100*tot_anc4/tot_preg
gen reg_cov_anc4=100*reg_anc4/reg_preg
lab var tot_cov_anc4 "Coverage ANC-4"
lab var reg_cov_anc4 "Coverage ANC-4"

* Coverage IPT2 
gen tot_cov_ipt2=100*tot_ipt2/tot_preg
gen reg_cov_ipt2=100*reg_ipt2/reg_preg
lab var tot_cov_ipt2 "Coverage IPT2"
lab var reg_cov_ipt2 "Coverage IPT2"

* Coverage Institutional deliveries
gen tot_cov_idelv=100*tot_idelv/tot_deliveries
gen reg_cov_idelv=100*reg_idelv/reg_deliveries 
lab var tot_cov_idelv "Coverage Institutional Deliveries"
lab var reg_cov_idelv "Coverage Institutional Deliveries"

* Coverage of BCG 
gen tot_cov_bcg=100*tot_bcg/tot_lbirths
gen reg_cov_bcg=100*reg_bcg/reg_lbirths 
lab var tot_cov_bcg "BCG coverage"
lab var reg_cov_bcg "BCG coverage"


* Coverage of penta3 
gen tot_cov_penta1=100*tot_penta1/tot_inftpenta1
gen reg_cov_penta1=100*reg_penta1/reg_inftpenta1 
lab var tot_cov_penta1 "Penta 1 coverage"
lab var reg_cov_penta1 "Penta 1 coverage"


* Coverage of penta3 
gen tot_cov_penta3=100*tot_penta3/tot_inftpenta1
gen reg_cov_penta3=100*reg_penta3/reg_inftpenta1 
lab var tot_cov_penta3 "Penta 3 coverage"
lab var reg_cov_penta3 "Penta 3 coverage"

* Coverage of measles vaccination
gen tot_cov_measles1=100*tot_measles1/tot_inftmeasle
gen reg_cov_measles1=100*reg_measles1/reg_inftmeasle
lab var tot_cov_measles1 "Measles coverage"
lab var reg_cov_measles1 "Measles coverage"

* Graph coverage trends
*** National 
twoway connected tot_cov_anc1 tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on DPT1 derived denominators, National", size(medium)) saving("trends_coverage_dpt1denom_1_${country}", replace) sort

twoway connected tot_cov_bcg tot_cov_penta3 tot_cov_measles1 year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on DPT1 derived denominators, National", size(medium)) saving("trends_coverage_dpt1denom_2_${country}", replace) sort

*** By admin 1
twoway connected tot_cov_anc1 reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv year, by(adminlevel_1, title("Coverage based on DPT-1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_dpt1denom_admin1_1_${country}", replace) legend(size(vsmall))

twoway connected  reg_cov_bcg reg_cov_penta3 reg_cov_measles1 year, by(adminlevel_1, title("Coverage based on DPT1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_dpt1denom_admin1_2_${country}", replace) legend(size(vsmall))

* Export coverage output to Excel file

save tmp, replace

collapse (max) tot_cov_anc1 tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta3 tot_cov_measles1, by(country year)
rename (tot_cov_anc1 tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta3 tot_cov_measles1) (cov_anc1 cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta3 cov_measles1)
gen area=0
save tmpcov, replace

use tmp, clear 
collapse (max) reg_cov_anc1 reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta3 reg_cov_measles1, by(country adminlevel_1 year)

rename (reg_cov_anc1 reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta3 reg_cov_measles1) (cov_anc1 cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta3 cov_measles1)

rename adminlevel_1 area
append using tmpcov

lab def first_admin_level 0"National", add
lab val area first_admin_level

sort country area year
save Coverage_based_on_DPT1, replace
export excel Coverage_based_on_DPT1.xls, firstrow(variables) replace

************************************************************************
*** END
*** Look for the following Excel files for the output of coverage estimates
*** based on ANC1 derived denominators: "Coverage_based_on_ANC1.xls"
*** based on DPT1 derived denominators: "Coverage_based_on_DPT1.xls"










