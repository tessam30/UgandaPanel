/*-------------------------------------------------------------------------------
# Name:		50_panelJoin
# Purpose:	Join panel data created as of 4/8/2015.
# Author:	Tim Essam, Ph.D.
# Created:	10/31/2014; 02/19/2015.
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------*/

clear
use "$pathout/FoodSecurity_all.dta", clear
set more off

* Check missingness
mdesc HHID year
g byte misYear = (year == .)

drop hh
destring HHID, gen(hh)

* Check which files to merge in
cd "$pathout"
dir

local mfile health_all hhchar_all hhinfra_all shocks_all GeovarsMerged geoadmin
foreach x of local mfile {
	merge 1:1 HHID year using "$pathout/`x'.dta", gen(mg_`x')
	la var mg_`x' "Merge results with `x'"
	}
*end

* order the data
order mg*, last

* month variable so we know when survey occured (for seasonal variables)
replace month = month2 if month == .
replace district = district10 if district==""
replace district = upper(district)
replace district = "MITYANA" if district == "MIYANA" 

* Fix the geographic variables (districts and subregions)
include "$pathdo2/adminRecode.do"

* Check that the comm variable is available across waves
egen commMin = min(comm), by(HHID)

* Fix stratum variable for represantativeness and making R-plots
clonevar stratumP = stratum

/* Kampala - 1, Other Urban -2, Central Rural - 3, East rural - 4, North rural - 5
   West rural - 6; 
Use 2011 vars for region and urban to crosswalk these and downfill */
bys HHID (year): replace stratumP = stratum[1] if stratumP==.

* Replace rural zones
replace stratumP = 3 if region == 1 & urban == 0
replace stratumP = 4 if region == 2 & urban == 0
replace stratumP = 5 if region == 3 & urban == 0
replace stratumP = 6 if region == 4 & urban == 0

* Replace other Urban (same as above except urban == 1)
replace stratumP = 2 if region == 2 & urban == 1
replace stratumP = 2 if region == 3 & urban == 1
replace stratumP = 2 if region == 4 & urban == 1


* Retain key variables of interest for exploring with R and ArcGIS
global sampling "urban month subRegion stratum stratumP region urban latitude lat_stack longitude lon_stack HHID hh year"
global health "FCS dietDiv FCS_categ stunting underweight wasting stuntedCount "
global health2 "pctstunted underwgtCount pctunderwgt wastedCount pctwasted breastFedCount illness totIllness medCostspc"
global hhchar "femhead agehead hhsize gendMix youth15to24 youth18to30 youth15to24m youth15to24f depRatio adultEquiv mixedEth orphan mosqNet mosNetChild"
global edvars "educHoh educAdult quitEduchoh quitEducPreg marriedHohp under5 mlaborShare flaborShare literateHoh literateSpouse" 
global assets "electricity hutDwelling metalRoof latrineCovered latrineWash under5m under5f under15m under15f adultEquiv"
global shocks "hazardShk priceShk employShk healthShk crimeShk assetShk anyshock totShock"
global shock2 "priceShk_tot hazardShk_tot employShk_tot healthShk_tot crimeShk_tot assetShk_tot totShock_tot"
global pcashock "ag aglow conflict drought disaster financial health other theft"

keep $sampling $health $health2 $hhchar $edvars $assets $shocks $shock2 $pcashock
drop if latitude == .

bys HHID: gen pwave = _N

* Sort data into panels
sort HHID year
destring HHID, gen(hhid)
order HHID hh hhid year long* latit* lat_stack lon_stack, first
export delimited "$pathexport/keyVars_201504.csv", replace
save "$pathout/keyVars_201504.dta", replace

* Look at FCS and diet Diversity trends over the years
twoway(histogram FCS), by(year, cols(1))
histogram FCS, kdensity xtitle(Food Consumption Score) legend(cols(1)) name(FCS, replace) by(stratumP, cols(2))
histogram FCS, kdensity xtitle(Food Consumption Score) legend(cols(1)) name(FCS, replace) by(year, cols(2))
histogram FCS, kdensity xtitle(Food Consumption Score) legend(cols(1)) name(FCS, replace) by(stratumP year, cols(2)) 


* Look at dietary diversity over time
graph box FCS, over(dietDiv) by(year, cols(3))

* Merge with RIGA data
drop hh
ren hhid hh
merge 1:1 hh year using "$pathout/RigaPanel.dta", gen(riga_mg)

* Flag households that survive all three years
g byte pFull = riga_mg == 3

* fix jittered lat lons to be consistent overtime
bys HHID (year): g byte latCheck = (lat_stack[2] == lat_stack[1])
bys HHID (year): replace latitude = latitude[1]
bys HHID (year): replace longitude = longitude[1]

sa "$pathout/RigaPanel_201504.dta", replace




