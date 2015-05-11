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

global hhchar "femhead agehead ageheadsq marriedHohp gendMix mixedEth" 
global agechar "hhsize under15 youth15to24 depRatio mlabor flabor"
global educhar "literateHoh literateSpouse educHoh"
global wealth "landless agwealth wealth infraindex hhmignet" 
global geo "dist_road dist_popcenter dist_market dist_borderpost srtm_uga"
global month "mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12"
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
eststo Rural09, title("Rural 2009"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month region3 region5 region6 if year==2009 & urban==0, robust

set more off
local loc Central East North West
local n: word count `loc'
local j = 3
forvalues i=1/`n'{
	local a: word `i' of `loc'
	eststo `a', title("`a' 2009"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month if year==2009 & urban==0 & stratumP==`j', robust
	fitstat
	local j = `j'+1
	}
*end
*
coefplot Rural09, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

coefplot Central || East || North || West, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

*********
*  2010 *
*********
set more off
* First fit hazard Shock model for all rural and the all regions
eststo Rural10, title("Rural 2010"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month region3 region5 region6 if year==2010 & urban==0, robust

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

coefplot Central || East || North || West, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

************
* Now 2011 *
************
set more off
* First fit hazard Shock model for all rural and the all regions
eststo Rural11, title("Rural 2011"): logistic hazardShk $hhchar $agechar $educhar $wealth $geo $month region3 region5 region6 if year==2011 & urban==0, robust

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

coefplot Rural09 Rural10 Rural11, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))

coefplot Central || East || North || West, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga mon1 mon2 mon3 mon4 mon5 mon6 mon8 mon9 mon10 mon11 mon12)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny)) cismooth(i(1 70))






**********
eststo Central, title("Hazard shock"): logit hazardShk $hhchar $agechar $educhar $wealth $geo if year==2009 & urban==0 & stratumP==3, or robust
eststo East, title("Hazard shock"): logit hazardShk $hhchar $agechar $educhar $wealth $geo if year==2009 & urban==0 & stratumP==4, or robust
eststo North, title("Hazard shock"): logit hazardShk $hhchar $agechar $educhar $wealth $geo if year==2009 & urban==0 & stratumP==5, or robust
eststo West, title("Hazard shock"): logit hazardShk $hhchar $agechar $educhar $wealth $geo if year==2009 & urban==0 & stratumP==6, or robust
esttab All Rural Central East North West, se star(* 0.10 ** 0.05 *** 0.001) label eform(0 1)

coefplot Central || East || North || West, drop(_cons dist_road dist_popcenter dist_market dist_borderpost srtm_uga)/*
*/ xline(0, lwidth(thin) lcolor(gray)) mlabs(tiny) ylabel(, labsize(tiny))






forvalues i = 2009(1)2011 {
	*eststo any1`i', title("Hazard shock"): logit hazardShk $hhchar $agechar $educhar if year==`i',  or robust
	*eststo any2`i', title("Hazard shock"): logit hazardShk $hhchar $agechar $educhar $wealth if year==`i' ,  or robust
	eststo any3`i', title("Hazard shock"): logit hazardShk $hhchar $agechar $educhar $wealth $geo region2-region6 if year==`i',  or cluster(longitude)
	fitstat
	}
*end




forvalues i = 2009(1)2011 {
	eststo any1`i', title("Any shock"): logit anyshock $hhchar $agechar $educhar i.month ib(1).stratumP if year==`i', or robust
	eststo any2`i', title("Any shock"): logit anyshock $hhchar $agechar $educhar $wealth i.month ib(1).stratumP if year==`i' , or robust
	eststo any3`i', title("Any shock"): logit anyshock $hhchar $agechar $educhar $wealth $geo i.month ib(1).stratumP if year==`i', or robust
	}
esttab any32009 any32010 any32011, se star(* 0.10 ** 0.05 *** 0.001) label
coefplot any32009 any32010 any32011, drop(month stratumP)
