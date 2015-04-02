/*-------------------------------------------------------------------------------
# Name:		06_hhinfra_2011
# Purpose:	Create preliminary analysis Uganda  
# Author:	Tim Essam, Ph.D.
# Created:	01/12/2015
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

capture log close
log using "$pathlog/06_hhinfra_2011", replace
use "$wave3/GSEC9A.dta", clear
set more off

* Type of dwelling
g byte hutDwelling = (h9q1 == 7)
la var hutDwelling "Household dwelling is a hut"

* g byte hh owns dwelling
g byte ownDwelling = inlist(h9q2, 1, 2, 3)
la var ownDwelling "hh owns dwelling"

* g dwelling rooms size
clonevar dwellingSize = h9q3
recode dwellingSize (0 = 1) (12000 = 12)

* metal roof
g byte metalRoof = inlist(h9q4, 4, 7, 8, 10) == 1
la var metalRoof "dwelling has a metal/tin roof"

* mud home/hut?
g byte mudDwelling = inlist(h9q5, 1, 2, 3) == 1
la var mudDwelling "dwelling is made primarily of mud"

* Dirt floor?
g byte cmtfloor = inlist(h9q6, 1, 2) != 1
la var cmtfloor "dwelling does not have mud/dirt/earth floor" 

* HH has protected water source
g byte protWater = inlist(h9q7, 1, 2, 3, 4, 5) == 1
la var protWater "hh has protected water source"

* Time to get drinking water
g waterTime = (h9q9a+ h9q9b)
la var waterTime "Total time required to get drinking water"

* Distance to water source
clonevar waterDist = h9q10

* HH purchase water used
clonevar waterPay = h9q12
recode waterPay (2 = 0)

* What does hh do to make water safe
g byte safeWater = inlist(h9q17, 1, 2, 3) == 1
la var safeWater "hh boil/filters water to make water safe"

*************
* Sanitation*
*************

* HH has private, covered latrine
g byte latrineCovered = inlist(h9q22, 5, 8) != 1

* HH has hand-washing facility at toilet
g byte latrineWash = (h9q23 != 1)

la var latrineCovered "hh has access to covered latrine"
la var latrineWash "hand washing station facility at toilet"

* Save create variables and collapse
ds(h9q*), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo2/copylabels.do"

ds(HHID), not
collapse (max) 	`r(varlist)', by(HHID)

* Reapply variable lables & value labels
include "$pathdo2/attachlabels.do"

* Save data
save "$pathout/hhinfra_tmp", replace

* Create energy use variables
use "$wave3/GSEC10A.dta", clear

* House has electricity
clonevar electricity = h10q1
recode electricity (2 = 0)

* Stove used by hh
g byte openFire = h10q9 == 8
la var openFire "hh uses open fire for stove"

g byte outdoorStove = h10q12 == 3
la var outdoorStove "hh has outdoor stove"

ds(h10q*), not
keep `r(varlist)'

save "$pathout/hhenergy.dta", replace

merge 1:1 HHID using "$pathout/hhinfra_tmp", gen(_hhinfra)
erase "$pathout/hhenergy.dta"
erase "$pathout/hhinfra_tmp.dta"
drop _hhinfra 

g year = 2011

sa "$pathout/hhinfra_2011.dta", replace

/* ---- NOT NECESSARY TO CONDUCT THIS AS RIGA HAS INDICES ALREADY!

* Merge in geograhpic information for urban/rural distinction
merge 1:1 HHID using "$pathout/Geovars.dta", gen(_geo)
drop if _geo != 3
drop _geo

/* NOTES: Create Infrastructure indices *Rural, Urban, National*
 Keeping only first factor to simplify;
 Use polychoric correlation matrix because of binary variables
 http://www.ats.ucla.edu/stat/stata/faq/efa_categorical.htm
*/

* Infra index based on FAO RIGA methodology
* running water, electricity, toilet, distance to water, floor material



#delimit ;
global factors "electricity openFire dwellingSize metalRoof 
			mudDwelling cmtfloor protWater latrineCovered";
#delimit cr

polychoric $factors if urban == 0
matrix C = r(R)
global N = r(N)
factormat C, n($N) pcf factor(2)
rotate, varimax
greigen
predict infraindex if urban == 0
la var infraindex "infrastructure index for rural hh"
alpha $factors if urban == 0

#delimit ;
global factors "electricity openFire dwellingSize metalRoof 
			 cmtfloor protWater latrineCovered";
#delimit cr
polychoric $factors if urban == 1
matrix C = r(R)
global N = r(N)
factormat C, n($N) pcf factor(2)
rotate, varimax
greigen
predict infraindex_urb if urban == 1
la var infraindex_urb "infrastructure index for rural hh"
alpha $factors if urban == 1

* Plot the factor loadings to see what is driving resultst
* Plot loadings for review
loadingplot, mlabs(small) mlabc(maroon) mc(maroon) /*
	*/ xline(0, lwidth(med) lpattern(tight_dot) lcolor(gs10)) /*
	*/ yline(0, lwidth(med) lpattern(tight_dot) lcolor(gs10)) /*
	*/ title(Household infrastructure index loadings)
graph export "$pathgraph\InfraWealthLoadings.png", as(png) replace
scree, title(Scree plot of infrastructure index)

* Run same process for entire sample
polychoric $factors
matrix C = r(R)
global N = r(N)
factormat C, n($N) pcf factor(2)
rotate, varimax
greigen
predict infraindex_all
la var infraindex_all "infrastructure index for all hh"
alpha $factors 

save "$pathout/hhinfra.dta", replace
log2html "$pathlog/05_hhchar", replace
capture log close

