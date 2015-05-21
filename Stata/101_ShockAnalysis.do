/*-------------------------------------------------------------------------------
# Name:		101_ShockAnalysis
# Purpose:	Join panel data created as of 4/8/2015.
# Author:	Tim Essam, Ph.D.
# Created:	10/31/2014; 02/19/2015.
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------*/

clear
capture log close
use "$pathout/RigaPanel_201504_all.dta", clear
set more off

log using "$pathlog/ShockAnalysis", replace

* Label ag wealth index (from FAO)
la var agwealth "Agricultural wealth index"

* Summarize variables that will be used in regression
tab year stratumP, sum (hazardShk)

* Generate dummy for month in which hh was surveyed (accounts for a lot of variation)
tab month, gen(mon)
tab ssa_aez09, gen(ageco)

global hhchar "femhead agehead ageheadsq marriedHohp gendMix mixedEth" 
global agechar "hhsize under15 youth15to24 depRatio mlabor flabor"
global educhar "literateHoh literateSpouse educHoh"
global wealth "landless agwealth wealthindex_rur infraindex hhmignet" 
global geo "dist_road dist_popcenter dist_market dist_borderpost srtm_uga"
global month "mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12"
global ageco "ageco1 ageco3 ageco4"
tab stratumP, gen(region)


* Check that variables are available across years
forvalues i = 2009(1)2011 {
	sum $hhchar $agechar $educhar $wealth $geo if year == `i'
	}
*end

* First fit a model for all shocks
foreach x of varlist anyshock hazardShk healthShk goodcope badcope {
	table stratumP year, c(mean `x')
}
*end

est clear
set more off
* First fit hazard Shock model for all rural and the all regions
eststo Rural09, title("Rural 2009"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month /*
*/ $ageco region3 region5 region6 if year==2009 & urban==0, robust

set more off
local loc Central East North West
local n: word count `loc'
local j = 3
forvalues i=1/`n'{
	local a: word `i' of `loc'
	eststo `a', title("`a' 2009"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month if year==2009 & urban==0 & stratumP==`j' & pFull, robust
	fitstat
	local j = `j'+1
	}
*end
*
esttab Rural09 Central East North West using "$pathreg/HazarShk09.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace /*
*/ mtitles("Rural" "Central" "East" "North" "West")

coefplot Rural09, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

coefplot Central || East || North || West, drop(_cons dist_road dist_popcenter dist_market /*
*/ dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))
graph export "$pathgraph/HazardShock_2010.png,", as(png) replace


*********
*  2010 *
*********
set more off
* First fit hazard Shock model for all rural and the all regions
eststo Rural10, title("Rural 2010"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month $ageco /*
*/ region3 region5 region6 if year==2010 & urban==0, robust

set more off
local loc Central East North West
local n: word count `loc'
local j = 3
forvalues i=1/`n'{
	local a: word `i' of `loc'
	eststo `a', title("`a' 2010"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month if year==2010 & urban==0 & stratumP==`j', robust
	fitstat
	local j = `j'+1
	}
*end

esttab Rural10 Central East North West using "$pathreg/HazarShk10.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace /*
*/ mtitles("Rural" "Central" "East" "North" "West")

coefplot Rural09 Rural10, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

coefplot Central || East || North || West, drop(_cons dist_road dist_popcenter dist_market /*
*/ dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))
graph export "$pathgraph/HazardShock_2010.png,", as(png) replace


************
* Now 2011 *
************
set more off
* First fit hazard Shock model for all rural and the all regions
eststo Rural11, title("Rural 2011"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month $ageco /*
*/ region3 region5 region6 if year==2011 & urban==0, robust

set more off
local loc Central East North West
local n: word count `loc'
local j = 3
forvalues i=1/`n'{
	local a: word `i' of `loc'
	eststo `a', title("`a' 2011"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month if year==2011 & urban==0 & stratumP==`j', robust
	fitstat
	local j = `j'+1
	}
*end

esttab Rural11 Central East North West using "$pathreg/HazarShk11.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace /*
*/ mtitles("Rural" "Central" "East" "North" "West")

esttab Rural09 Rural10 Rural11 using "$pathreg/HazShk_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace /*
*/ mtitles("Rural 2009" "Rural 2010" "Rural2011")

coefplot Rural09 Rural10 Rural11, drop(_cons dist_road dist_popcenter dist_market dist_borderpost /*
*/ srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

coefplot Central || East || North || West, drop(_cons dist_road dist_popcenter dist_market /*
*/ dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))
graph export "$pathgraph/HazardShock_2011.png,", as(png) replace


**********
* Create coefplots and exports for each region across three years
set more off
local loc Central East North West
local n: word count `loc'
local j = 3
forvalues i=1/`n'{
	local a: word `i' of `loc'
		forvalues year = 2009(1)2011 {
			eststo `a'`year', title("`a' "): logit hazardShk $hhchar $agechar $educhar $wealth $geo /*
			*/ $month if year==`year' & urban==0 & stratumP==`j', robust
			fitstat
			}
	* Create forest plots for each region
	coefplot `a'2009 || `a'2010 || `a'2011, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
	*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))
	graph export "$pathgraph/`a'_all.png", as(png) replace
	
	* Export results to a txt file
	esttab `a'* using "$pathreg/`a'_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace 	
	
	* Iterate StratumP to align with name
	local j = `j'+1
}
*end


* Run a final pooled probit model & OLS model (tried xtprobit and chi-squared test couldnt' reject; rho nearly 0 ~ 0.06)
eststo pldProbit: probit hazardShk $hhchar $agechar $educhar $wealth $geo $month $ageco region3 region5 region6 i.year if urban==0, robust
esttab pldProbit, se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace mtitles("Pooled Probit")

* Run a pooled model across each region
eststo pldCenter: probit hazardShk $hhchar $agechar $educhar $wealth $geo /*
			*/ $month i.year if urban==0 & stratumP==3, robust
linktest
eststo pldEast: probit hazardShk $hhchar $agechar $educhar $wealth $geo /*
			*/ $month i.year if urban==0 & stratumP==4, robust
linktest
eststo pldNorth : probit hazardShk $hhchar $agechar $educhar $wealth $geo /*
			*/ $month i.year if urban==0 & stratumP==5, robust
linktest
eststo pldWest: probit hazardShk $hhchar $agechar $educhar $wealth $geo /*
			*/ $month i.year if urban==0 & stratumP==6, robust
linktest

esttab pld* using "$pathreg/Pooled_hzd_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) /*
*/ label replace mtitles("Pooled Logit" "Pooled Center" "Pooled East" "Pooled North" "Pooled West")

est drop East North West Central
esttab Central* East* North* West* Rural09 Rural10 Rural11 using "$pathreg/Regions_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace /*
*/ mtitles("Central 2009" "Central 2010" "Central 2011" "East 2009" "East 2010" "East 2011"  "North 2009" "North 2010" "North 2011" /*
*/ "West 2009" "West 2010" "West 2011" "All 2009" "All 2010" "All 2011")

* Run same analysis for health shocks (may not be realiable due to variation w/in regions and some var drops due to multicollinearity)
set more off
local loc Central East North West
local n: word count `loc'
local j = 3
forvalues i=1/`n'{
	local a: word `i' of `loc'
		forvalues year = 2009(1)2011 {
			eststo hlt`a'`year', title("`a' "): logit healthShk $hhchar $agechar $educhar $wealth $geo /*
			*/ $month if year==`year' & urban==0 & stratumP==`j', robust
			fitstat
			linktest
			}
	* Create forest plots for each region
	coefplot hlt`a'2009 || hlt`a'2010 || hlt`a'2011, drop(_cons dist_road dist_popcenter dist_market /*
	*/ dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
	*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))
	graph export "$pathgraph/hlt`a'_all.png", as(png) replace
	
	* Export results to a txt file
	esttab hlt`a'* using "$pathreg/hlt`a'_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace 	
	
	* Iterate StratumP to align with name
	local j = `j'+1
}
*end

* Estimate global models for 2009/2011 of health shocks
eststo hlt_all09, title("Health 2009"): logit healthShk $hhchar $agechar $educhar /*
*/ $wealth $geo $month $ageco region3 region5 region6 if year==2009 & urban==0, robust

eststo hlt_all10, title("Health 2010"): logit healthShk $hhchar $agechar $educhar /*
*/ $wealth $geo $month $ageco region3 region5 region6 if year==2010 & urban==0, robust

eststo hlt_all11, title("Health 2011"): logit healthShk $hhchar $agechar $educhar /*
*/ $wealth $geo $month $ageco region3 region5 region6 if year==2011 & urban==0, robust

eststo hlt_all, title("Health Pooled"): logit healthShk $hhchar $agechar $educhar /*
*/ $wealth $geo $month $ageco region3 region5 region6 i.year if urban==0, robust

coefplot hlt_all09 || hlt_all10 || hlt_all11 || hlt_all, drop(_cons dist_road dist_popcenter dist_market /*
	*/ dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
	*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

eststo pldProbitHlth: probit hazardShk $hhchar $agechar $educhar $wealth $geo $month $ageco region3 region5 region6 i.year if urban==0, robust
esttab pldProbitHlth, se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace mtitles("Pooled Probit")

coefplot pldProbitHlth, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

esttab hltCentral* hltEast* hltNorth* hltWest* hlt_all* using "$pathreg/Regions_hlt_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace /*
*/ mtitles("Central 2009" "Central 2010" "Central 2011" "East 2009" "East 2010" "East 2011"  "North 2009" "North 2010" "North 2011" /*
*/ "West 2009" "West 2010" "West 2011" "All 2009" "All 2010" "All 2011" "Pooled")


* Create new exogneous variables that account for different types of livestock holdings
* Winsorize TLU as TLU cattle are large
clonevar TLUcattle = TLU_cattle
winsor2 TLUcattle, replace cuts(1 99.5)

global hhchar "femhead agehead ageheadsq marriedHohp gendMix mixedEth" 
global agechar "hhsize under15 youth15to24 depRatio mlabor flabor"
global educhar "literateHoh literateSpouse educHoh"
global wealth "landless agwealth wealthindex_rur infraindex hhmignet" 
global geo "dist_road dist_popcenter dist_market dist_borderpost srtm_uga"
global month "mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12"
global ageco "ageco1 ageco3 ageco4"
global lvstk "TLU_sheep TLU_poultry TLUcattle"

* Dietary diversity with poisson process -- may want to instrument for pcexp or use asset indices as proxy
*Use a poisson with a zero-truncated model b/c the value zero cannot appear (households have to eat)
est clear
eststo dietAll09: tpoisson dietDiv $hhchar $agechar $educhar $wealth $geo $month $ageco $lvstk region3 region5 region6 if year==2009 , ll(0) vce(robust)
eststo dietAll10: tpoisson dietDiv $hhchar $agechar $educhar $wealth $geo $month $ageco $lvstk region3 region5 region6 if year==2010 , ll(0) vce(robust)
eststo dietAll11: tpoisson dietDiv $hhchar $agechar $educhar $wealth $geo $month $ageco $lvstk region3 region5 region6 if year==2011 , ll(0) vce(robust)
* Check distributions of all regions by year
histogram dietDiv, by(year stratumP)


* Create coefplots and exports for each region across three years for dietary diversity 
set more off
local loc Central East North West
local n: word count `loc'
local j = 3
forvalues i=1/`n'{
	local a: word `i' of `loc'
		forvalues year = 2009(1)2011 {
			eststo `a'`year'Diet, title("`a' "): tpoisson dietDiv $hhchar $agechar $educhar $wealth $geo /*
			*/ $month $lvstk if year==`year' & urban==0 & stratumP==`j', ll(0) vce(robust)
			}
	* Create forest plots for each region
	coefplot `a'2009Diet || `a'2010Diet || `a'2011Diet, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
	*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))
	graph export "$pathgraph/`a'_all.png", as(png) replace
	
	* Export results to a txt file
	esttab `a'* using "$pathreg/`a'_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace 	
	
	* Iterate StratumP to align with name
	local j = `j'+1
}
*end

esttab Central* East* North* West* dietAll* using "$pathreg/Regions_diet_all.txt", se star(* 0.10 ** 0.05 *** 0.001) eform(0 1) label replace /*
*/ mtitles("Central 2009" "Central 2010" "Central 2011" "East 2009" "East 2010" "East 2011"  "North 2009" "North 2010" "North 2011" /*
*/ "West 2009" "West 2010" "West 2011" "All 2009" "All 2010" "All 2011")

* Now consider food security in the form of Food Consumption Scores (can run f.e. model here)

xtreg FCS $hhchar $agechar $educhar $wealth $geo $month $lvstk if year==`year' & urban==0 & stratumP==`j', ll(0) vce(robust)






* Look at changes in wealth over time as captured by wealth index
forvalues i = 2009(1)2011 {
	g tmp`i' = wealthindex_rur if year==`i'
	egen hhwealth`i' = mean(tmp`i'), by(HHID)
	
	* Consumption
	g tmp2`i' = pcexpend if year==`i'
	egen consump`i' = mean(tmp2`i'), by(HHID)
	replace consump`i' = ln(consump`i')
	
	* anyshocks
	g tmp3`i' = anyshock if year==`i'
	egen anyshock`i' = max(tmp3`i'), by(HHID)
	
	* hazard shocks
	g tmp4`i' = hazardShk if year==`i'
	egen hazshock`i' = max(tmp4`i'), by(HHID)
	
	* Ag wealth
	g tmp5`i' = agwealth if year==`i'
	egen agwealth`i' = mean(tmp5`i'), by(HHID)
	
	drop tmp`i' tmp2`i' tmp3`i' tmp4`i' tmp5`i'
}
*

* How do asset indices change overtime?
clonevar wealth_ind = wealthindex_rur
separate wealth_ind, by(hazardShk)


foreach x of varlist hhwealth2009 hhwealth2010 hhwealth2011 {
	separate `x', by(hazardShk)
	}
*end

twoway(scatter hhwealth2010 hhwealth2009 if year==2009 & hazardShk==0)(scatter /*
*/ hhwealth2010 hhwealth2009 if year==2009 & hazardShk==1)(line hhwealth2009 /*
*/ hhwealth2009, sort) if pFull,  xline(0, lwidth(thin) lcolor(gray))  yline(0, lwidth(thin) lcolor(gray))



twoway(scatter hhwealth2011 hhwealth2009 if year==2009 & hhwealth2010)(line hhwealth2009 hhwealth2009, sort) if pFull,  xline(0, lwidth(thin) lcolor(gray))  yline(0, lwidth(thin) lcolor(gray))
twoway(scatter hhwealth2011 hhwealth2010 if year==2009 & hhwealth2010)(line hhwealth2009 hhwealth2009, sort) if pFull,  xline(0, lwidth(thin) lcolor(gray))  yline(0, lwidth(thin) lcolor(gray))

* How does consumption change overtime
twoway(scatter consump2010 consump2009 if year==2009 & hhwealth2010)(line consump2009 consump2009, sort) if pFull,  xline(0, lwidth(thin) lcolor(gray))  yline(0, lwidth(thin) lcolor(gray))

* How do asset indices change overtime?
twoway(scatter agwealth2010 agwealth2009 if year==2009 & hhwealth2010)(line agwealth2009 agwealth2009, sort) if pFull,  xline(0, lwidth(thin) lcolor(gray))  yline(0, lwidth(thin) lcolor(gray))



* Look into creating a waffle chart in excel of shocks
egen dateGroup = group(month year)

table intDate stratumP, c(mean hazardShk)
table year stratumP, c(mean hazardShk) 
table year stratumP, c(mean anyshock ) row col
table year stratumP, c(mean FCS ) row col
table intDate stratumP, c(mean dietDiv  ) row
table year stratumP, c(mean dietDiv ) row col

* Look at expenditures, but first winsorize outliers
winsor2 pcexp, replace cuts(1 99.8)
g lnpcexp = ln(pcexpend)

table year stratumP, c(mean lnpcexp ) row col
table intDate stratumP, c(mean lnpcexp) row 
