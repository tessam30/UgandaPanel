/*-------------------------------------------------------------------------------
# Name:		01_panelMerge
# Purpose:	Merge the 2010, 2011, 2012 Uganda RIGA data
# Author:	Tim Essam, Ph.D.
# Created:	03/24/2015
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "$pathlog/01_panelMerge", replace

u "$pathin/Uganda10_HHCHAR.dta"

merge 1:1 hh using "$pathin/Uganda10_HH_ADMIN.dta"
drop _merge
merge 1:1 hh using "$pathin/Uganda10_HH_INCOME.dta"
drop _merge
g year = 2010
save "$pathout/Uganda10_all.dta", replace

* Load in the 2011 data
clear
u "$pathin/Uganda11_HHCHAR.dta"
merge 1:1 hh using "$pathin/Uganda11_HH_ADMIN.dta", gen(_merge1)
merge 1:1 hh using "$pathin/Uganda11_HH_INCOME.dta", force gen(_merge2)
g year = 2011
save "$pathout/Uganda11_all.dta", replace

* Load in 2012 data
clear
u "$pathin/Uganda12_HHCHAR.dta"
merge 1:1 hh using "$pathin/Uganda12_HH_ADMIN.dta", gen(_merge1)
merge 1:1 hh using "$pathin/Uganda12_HH_INCOME.dta", force gen(_merge2)
drop _merge*
g year = 2012
save "$pathout/Uganda12_all.dta", replace

* Append all the data together
append using "$pathout\Uganda11_all.dta" "$pathout\Uganda10_all.dta", generate(_append) force
set more off
tab district

bys hh: gen pCount = _N
la var pCount "Number of waves hh is present"

* Merge in the 2009 Panel GPS data (with jittered offsets)
merge m:1 hh using "$pathout/Geovars2009"


xtset hh year


