/*-------------------------------------------------------------------------------
# Name:		01_GeographicInfo
# Purpose:	Merge lat long info for households and export to R for jittering
# Author:	Tim Essam, Ph.D.
# Created:	10/31/2014; 02/19/2015.
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "$pathlog/01_GeographicInfo", replace

* First, just try appending all hh together



local geolist _0910 _1011 _1112
local i = 1
local j = 2009
foreach x of local geolist {
	use "$pathin/UNPS_Geovars`x'.dta"
	destring HHID, gen(hh)
	
	rename *_`j' *
	
	tempfile temp`i'
	save "`temp`i''", replace
	local i = `i' + 1
	local j = `j' + 1
}	
*end
	









/* NOTE: ENSURE THE R FILE GPSjitter.R has been executed and merge file exists.
Use the windows shell to execute the R file (may only work on laptops). */
cd $pathR
*qui: shell "C:\Program Files\R\R-3.1.1\bin\x64\R.exe" CMD BATCH GPSjitter.R
qui: shell "C:\Program Files\R\R-3.0.2\bin\R.exe" CMD BATCH GPSjitter.R

* Verify shell command generated correct file
qui local required_file GPSjitter2009
foreach x of local required_file { 
	 capture findfile `x'.csv, path($pathexport)
		if _rc==601 {
			noi disp in red "Please verify `x'.csv file exists. Execute GPSjitter.R script."
			* Create an exit conditions based on whether or not file is found.
			if _rc==601 exit = 1
		}
		else display in yellow "File exists, continue with merge."
	}
*end

* Load the .csv and merge with other geographic variables
import delimited "$pathexport/GPSjitter2009.csv", clear 
la var longitude "HH longitude"
la var latitude  "HH latitude"
la var lon_stack "HH longitude stacked"
la var lat_stack "HH latitude stacked"
la var hh "household id"
la var year "year"
drop v1

tempfile temp1
save "`temp1'"

import delimited "$pathexport/UgandaGeo2009.csv", clear
merge 1:1 hh using "`temp1'"
drop lat_mod lon_mod

save "$pathout/Geovars2009.dta", replace

***********************
* format 2010 geo data *
************************
clear
cd $pathR
*qui: shell "C:\Program Files\R\R-3.1.1\bin\x64\R.exe" CMD BATCH GPSjitter.R
qui: shell "C:\Program Files\R\R-3.0.2\bin\R.exe" CMD BATCH GPSjitter2010.R

* Verify shell command generated correct file
qui local required_file GPSjitter2010
foreach x of local required_file { 
	 capture findfile `x'.csv, path($pathexport)
		if _rc==601 {
			noi disp in red "Please verify `x'.csv file exists. Execute GPSjitter.R script."
			* Create an exit conditions based on whether or not file is found.
			if _rc==601 exit = 1
		}
		else display in yellow "File exists, continue with merge."
	}
*end

* Load the .csv and merge with other geographic variables
import delimited "$pathexport/GPSjitter2010.csv", clear 
la var longitude "HH longitude"
la var latitude  "HH latitude"
la var lon_stack "HH longitude stacked"
la var lat_stack "HH latitude stacked"
la var hh "household id"
la var year "year"
drop v1

tempfile temp1
save "`temp1'", replace

import delimited "$pathexport/UgandaGeo2010.csv", clear
clonevar hh = hhid
merge 1:1 hh using "`temp1'"
drop lat_mod lon_mod

append

