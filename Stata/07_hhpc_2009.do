/*-------------------------------------------------------------------------------
# Name:		06_hhpc
# Purpose:	Create household physical capital variables 
# Author:	Tim Essam, Ph.D.
# Created:	01/12/2015
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "$pathlog/07_hhpc_2009", replace
set more off

* Load the assets module
use "$wave1/GSEC14.dta"

g year = 2009
* Merge in geographic information to use when taking median values for assets
merge m:1 HHID year using "$pathout/geoadmin.dta"
drop if year != 2009
drop if h14q2 == .
drop _merge

* Check ownership distribution (obviously some outliers)
sum h14q4, d

/* Cap owernship number to 20 (may even be too high)
recode h14q4 (21/157 = 20)
*/

label list H14Q2
* Create a loop to create binaries and counts of the assets in their order (22 in total)
# delimit ;
local assets house building land furniture appliances tv radio generator
	solar bicycle moto vehicle boat othTrans jewelry mobile computer internet
	otherElect otherAsset otherAsset2 otherAsset3;
#delimit cr

local nsets : word count `assets'
qui label list H14Q2
assert `r(max)' == `nsets'
display in yellow "Label list has `r(max)' items, `nsets' in macro."

* Loop over each asset in order, verifying code using output (p. 24, Section 14)
local count = 1
foreach x of local assets {
	qui g byte `x' = (h14q2 == `count' & h14q3 == 1)
	
	* Check that asset matches order
	display in yellow "`x': `count' asset code"
	local count = `count'+1
	}
*end

foreach name of varlist house-otherAsset3 {
	la var `name' "HH owns at least one `name's"
	bys HHID: g n`name' = (`name' * h14q4)
	replace n`name'=0 if n`name'==. 
	la var n`name' "Total `name's owned by hh"
}
*end

* Check total value of atssets for potential outliers
sum h14q5, d
tab h14q5


* Estimate a unit value for items using median and mean values
* Another method for hhdurval
egen munitprice = median(h14q5/h14q4) if inlist(h14q4, ., 0)!=1, by(h14q2 regurb) 
la var munitprice "Median price of durable asset"

egen mnunitprice = mean(h14q5/h14q4) if inlist(h14q4, ., 0)!=1, by(h14q2 regurb) 
la var mnunitprice "Mean price of durable asset"

* Calculate total value of all durables
egen hhdurasset_md = total(h14q4 * munitprice) if inlist(h14q4, ., 0)!=1, by(HHID)
egen hhdurasset_mn = total(h14q4 * mnunitprice) if inlist(h14q4, ., 0)!=1, by(HHID)

* Caculate total household value of all durables

la var hhdurasset_md "Total value of all durable assets using sub-region item median"
la var hhdurasset_mn "Total value of all durable assets using sub-region item mean"
replace hhdurasset_md = . if hhdurasset_md == 0
replace hhdurasset_mn = . if hhdurasset_mn == 0

* Create hh tota durables value
*egen hhDurablesValue = sum(h14q5), by(HHID h14q2)
egen hhDurablesTotVal = sum(h14q5) if h14q4!=., by(HHID)
la var hhDurablesTotVal "Total value of durables using hh reported figures"

* Generate hh total durables value minus house and land
egen hhDurVal_sub = sum(h14q5) if h14q4!=. & inlist(h14q2, 2, 3, 4)!= 1, by(HHID)
la var hhDurVal_sub "total value of durables not including house, land or buildings"

*tabstat hhDurablesValue, by(d1_02) stat(mean sd min max)
drop h14* sregion HH_2005 mult stratum wgt10 wgt09wosplits wgt09 dist_code spitoff09_10 spitoff10_11 district

* Collapse down to HH level
include "$pathdo/copylabels.do"
ds (HHID urban regurb year), not
collapse (max) `r(varlist)' year, by(HHID urban regurb)
include "$pathdo/attachlabels.do"

* Create a durable asset index based on core assets (not including house, land, building)
#delimit ;
global factors "furniture appliances tv radio bicycle 
		moto vehicle jewelry mobile otherAsset";
#delimit cr

forvalues i = 0(1)1{
	sum $factors if urban == `i'
	factor $factors if urban == `i' , pcf
	predict wealth_`i' if urban == `i'
	la var wealth_`i' "wealth index"
	alpha $factors if urban == `i'
	scree
	
* Plot the factor loadings to see what is driving resultst
* Plot loadings for review
loadingplot, mlabs(small) mlabc(maroon) mc(maroon) /*
	*/ xline(0, lwidth(med) lpattern(tight_dot) lcolor(gs10)) /*
	*/ yline(0, lwidth(med) lpattern(tight_dot) lcolor(gs10)) /*
	*/ title(Household infrastructure index loadings)
graph export "$pathgraph/WealthLoadingsR.png", as(png) replace
scree, title(Scree plot of wealth index)
}
ren wealth_0 wealthindex_rur
ren wealth_1 wealthindex_urb

* Create national index
factor $factors , pcf
predict wealthindex
la var wealthindex "wealth index"
alpha $factors
scree


*end
save "$pathout/hhpc_2009.dta", replace
log2html "$pathlog/07_hhpc_2009", replace
capture log close


