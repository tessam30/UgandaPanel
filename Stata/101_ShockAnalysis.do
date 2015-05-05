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

* Summarize variables that will be used in regression
tab year stratumP, sum (hazardShk)

global hhchar "femhead agehead marriedHohp hhsize gendMix mixedEth" 
global agechar "under5 youth15to24 depRatio mlabor flabor adultEquiv"
global educhar "literateHoh literateSpouse educHoh"
global wealth "landless agwealth wealth infraindex hhmignet" 
global geo "dist_road dist_popcenter dist_market dist_borderpost srtm_uga"

* First fit a model for all shocks
foreach x of varlist anyshock hazardShk healthShk goodcope badcope {
	table stratumP year, c(mean `x')
}
*end

set more off
* First fit anyshock model
forvalues i = 2009(1)2011 {
	eststo any1`i', title("Any shock"): logit anyshock $hhchar $agechar $educChar i.month ib(1).stratumP if year==`i', or robust
	eststo any2`i', title("Any shock"): logit anyshock $hhchar $agechar $educChar $wealth i.month ib(1).stratumP if year==`i' , or robust
	eststo any3`i', title("Any shock"): logit anyshock $hhchar $agechar $educChar $wealth $geo i.month ib(1).stratumP if year==`i', or robust
	}
esttab any32009 any32010 any32011, se star(* 0.10 ** 0.05 *** 0.001) label
coefplot any32009 any32010 any32011
