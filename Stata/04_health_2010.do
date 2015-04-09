/*------------------------------------------------------------------------------
# Name:		04_health_2010
# Purpose:	Process household health and child nutrition information
# Author:	Tim Essam
# Created:	2015/3/23
# License:	MIT License
# Ado(s):	labutil, labutil2 (ssc install labutil, labutil2), zscore06
# Dependencies: copylables, attachlabels, 00_SetupFoldersGlobals.do
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "$pathlog/04_health_2010", replace
di in yellow "`c(current_date)' `c(current_time)'"

u "$wave2/GSEC5.dta", replace

* Household illness in past 30 days
g byte illness = (h5q4 == 1)
egen totIllness = total(illness), by(HHID)
la var totIllness "Total hh members ill in last 30 days"

* Major place of consultation
g hlthCons = .
replace hlthCons = 0 if h5q10 == .
replace hlthCons = 1 if inlist(h5q10, 1, 2, 4)
replace hlthCons = 2 if inlist(h5q10, 5, 7)
replace hlthCons = 3 if inlist(h5q10, 6, 10)
replace hlthCons = 4 if inlist(h5q10, 3, 8, 9, 11, 12, 13, 96)

la def hlth 0 "None" 1 "Government facility" 2 "Private facility" /*
*/ 3 "Pharmacy" 4 "Other"
la val hlthCons hlth

clonevar distFacility = h5q11

* Total costs for household due to illness
egen medCosts = total(h5q12), by(HHID)

* Individual costs per illness
clonevar medCostsI = h5q12

* Costs per capita
bys HHID: g byte hhtmp = (inlist(h5q12, 0, .)!=1)
egen hhtmptot = total(hhtmp), by(HHID)
g medCostspc = medCosts/hhtmptot

* Total household time lost due to illness
egen medTime = total(h5q6), by(HHID)

* Label variables
la var illness "HH member sick in past 30 days"
la var medCosts "Total hh medical costs"
la var medCostspc "Per capital medical costs"
la var medTime "Total hh time lost due to illness (activities)"
la var hlthCons "Health consultation details"

drop hhtmp hhtmptot

preserve
* Merge with individual demographic data
ds(h2* h5*), not
keep `r(varlist)'
merge 1:1 HHID PID using "$pathout/hhchar_ind_2010.dta

* Keep individuals matching in both data sets
keep if _merge == 3

* Save data and move to next module
save "$pathout/illness_I_2010.dta", replace
restore

* Create binaries for each type of treatment sought
tab hlthCons, gen(treatment)

* Keep household-level vars and collapse down
ds(PID h5* hlthCons medCostsI), not
keep `r(varlist)'

qui include "$pathdo2/copylabels.do"
ds(HHID), not
collapse (max) `r(varlist)', by(HHID)
qui include "$pathdo2/attachlabels.do"

* Recode distance to facilty to be great then 100
recode distFacility (100/1500 = 100)

* Save illness
save "$pathout/healthtmp_2010.dta", replace


*******
* MCH *
*******

* Maternal child health issues
use "$wave2/GSEC6.dta", clear

* Merge in hh gender information
merge 1:1 HHID PID using "$wave2/GSEC2.dta"
keep if _merge == 3
drop _merge

*Recode gender variable to be consistent with others
recode h2q3 (0 = 2)
la def newgend 1 "MALE" 2 "FEMALE"
la val h2q3 newgend

* Generate child height var assuming 24 month cutoff used correctly
g cheight = h6q28a 
clonevar ageMonths = h6q4
replace ageMonths =. if ageMonths == 999
la var ageMonths "Age of child (in months)
replace cheight = h6q28b if cheight == .

* Calculate z-scores using zscore06 package
* 13 reported cases of oedema
zscore06, a(h6q4) s(h2q3) h(cheight) w(h6q27) o(h6q26)

* Remove scores that are implausible
replace haz06=. if haz06<-6 | haz06>6
replace waz06=. if waz06<-6 | waz06>5
replace whz06=. if whz06<-5 | whz06>5
replace bmiz06=. if bmiz06<-5 | bmiz06>5

* Rename the variables to be more meaningful
ren haz06 stunting
ren waz06 underweight
ren whz06 wasting
ren bmiz06 BMI

la var stunting "Stunting: Length/height-for-age Z-score"
la var underweight "Underweight: Weight-for-age Z-score"
la var wasting "Wasting: Weight-for-length/height Z-score"

g byte stunted = stunting < -2 if stunting != .
g byte underwgt = underweight < -2 if underweight != . 
g byte wasted = wasting < -2 if wasting != . 
g byte BMIed = BMI <-2 if BMI ~= . 
la var stunted "Child is stunting"
la var underwgt "Child is underweight for age"
la var wasted "Child is wasting"

sum stunted underwgt wasted 
ds(h2* h6q* ), not
mdesc `r(varlist)'

* Look at the outcomes by age category
twoway (lowess stunted ageMonths, mean adjust bwidth(0.75)) /*
*/ (lowess wasted ageMonths, mean adjust bwidth(0.75)) /*
*/ (lowess underwgt ageMonths, mean adjust bwidth(0.75)),  /*
*/ xlabel(0(6)60,  labsize(small)) title("Child Nutrition Outcomes: 2010 (unweighted)")

* child was/is breastfed & given vit A
g byte breastFed = (h6q6 == 1)
g byte vitA = inlist(h6q14, 1, 2) == 1
g byte childFever = inlist(h6q22, 1) 

la var breastFed "child in hh was breastfed"
la var vitA "child in hh received vit A in last 6 months"
lowess breastFed ageMonths, mean adjust bwidth(0.6) xlabel(0(6)60,  labsize(small))

* child had diarrhea
g byte childDiarrhea = (h6q16 == 1)
la var breastFed "Child was breastfed"
la var childDiarrhea "Child had diarrhea in last 2 weeks"
la var childFever "Child had fever in last 2 weeks"

* Save individual child information
preserve
ds(h6* h2*), not
keep `r(varlist)'
sa "$pathout/childHealth_I_2010.dta", replace
restore

* Create a variable counting the number of children under 60 months (5 years)
bys HHID: g childUnd5 = _N
la var childUnd5 

* Create hh malnutrition indicators
local malnu stunted underwgt wasted breastFed childFever childDiarrhea
foreach x of local malnu {
	egen `x'Count = total(`x'), by(HHID)
	g pct`x' = `x'Count / childUnd5
	la var `x'Count "Total children `x'"
	la var pct`x' "Percent of children `x'"
	}
*end

* Collapse down to hh level keeping only major indicators
qui include "$pathdo2/copylabels.do"
#delimit ; 
	collapse (mean) stunting underweight wasting BMI
	(max) stuntedCount pctstunted underwgtCount 
	pctunderwgt wastedCount pctwasted breastFedCount 
	pctbreastFed childFeverCount pctchildFever 
	childDiarrheaCount pctchildDiarrhea childUnd5,
	by(HHID) fast;
#delimit cr
qui include "$pathdo2/attachlabels.do"

merge 1:1 HHID using "$pathout/healthtmp_2010.dta"
replace childUnd5 = 0 if childUnd5 == .
erase "$pathout/healthtmp_2010.dta"


* Save created data
sa "$pathout/health_2010.dta", replace
log2html "$pathlog/04_health_2010", replace
capture log close
