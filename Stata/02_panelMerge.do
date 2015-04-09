/*-------------------------------------------------------------------------------
# Name:		01_panelMerge
# Purpose:	Merge the 2010, 2011, 2012 Uganda RIGA data and add geovars
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
g year = 2009
save "$pathout/Uganda10_all.dta", replace

* Load in the 2011 data
clear
u "$pathin/Uganda11_HHCHAR.dta"
merge 1:1 hh using "$pathin/Uganda11_HH_ADMIN.dta", gen(_merge1)
merge 1:1 hh using "$pathin/Uganda11_HH_INCOME.dta", force gen(_merge2)
g year = 2010
save "$pathout/Uganda11_all.dta", replace

* Load in 2012 data
clear
u "$pathin/Uganda12_HHCHAR.dta"
merge 1:1 hh using "$pathin/Uganda12_HH_ADMIN.dta", gen(_merge1)
merge 1:1 hh using "$pathin/Uganda12_HH_INCOME.dta", force gen(_merge2)
drop _merge*
g year = 2011
save "$pathout/Uganda12_all.dta", replace

* Append all the data together
append using "$pathout\Uganda11_all.dta" "$pathout\Uganda10_all.dta", generate(_append) force
set more off
tab district

bys hh: gen pCount = _N
la var pCount "Number of waves hh is present"

* Merge in Panel GPS data created in 01_GeographicInfo file
merge 1:1 hh year using "$pathout/GeovarsMerged.dta", gen(_mergePanel)
order hh year

xtset hh year

* Fix up district names
replace district = upper(district)

* Main categories usually analyzled are:
/* Income = agr_wge + nonagr_wge + crop1 + livestock + selfemp + transfer + other == totincome1 */

* Designate 3 cuts of data to be explored in mapping software
global part "p_ag p_nonag p_nonfarm p_offarm p_onfarm p_trans TLU_total"
global assets "totagprod totagsold TLU_sheep TLU_pigs TLU_poultry TLU_donkey TLU_rabbit TLU_beehive TLU_cattle"
global share "sh1agr_wge sh1nonagr_wge sh1crop1 sh1livestock sh1selfemp sh1transfer sh1other"
global ftype "fhh fmhh fshh lhh mhh divhh pcexp ptrack"
global assets2 "agwealth wealth landown landless toilet electricity infraindex infraindex_urb infraindex_natl urban weight comm crop1 crop2 livestock TLU_bulls TLU_cow TLU_calf safewater hhmignet"

keep hh year latitude longitude $part $share $ftype $assets $assets2

* Retain only households surviving all three rounds of panel
keep if ptrack == 3

save "$pathout/RigaPanel.dta", replace
