/*-------------------------------------------------------------------------------
# Name:		09_dateMerge
# Purpose:	Create variables tracking survey date/year for graphing.
# Author:	Tim Essam, Ph.D.
# Created:	10/31/2014; 02/19/2015.
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------*/

clear
capture log close

* Load in gsec1 from 09, 10, 11
use "$wave1/GSEC1.dta"

keep HHID urban h1bq2b h1bq2c

* Rename variables to ensure alignment when appending
ren h1bq2b monthInt
ren h1bq2c yearInt

g wave = 1
g year = 2009

save "$pathout/interview09.dta", replace
clear

* Next wave of survey
use "$wave2/GSEC1.dta"

keep HHID urban month year
ren month monthInt
ren year yearInt
g wave = 2
g year = 2010

save "$pathout/interview10.dta", replace
clear


* Final wave
clear
use "$wave3/GSEC1.dta"
keep HHID urban month year

ren month monthInt
ren year yearInt
g wave = 3
g year = 2011


append using "$pathout/interview09.dta" "$pathout/interview10.dta"

* Check results for consistency
bys wave: tab monthInt yearInt
tab monthInt yearInt

* save for merging with final data set of RIGA merged data
sa "$pathout/interviewInfo_all.dta", replace
