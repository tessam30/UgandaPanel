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
capture log close
use "$pathout/FoodSecurity_all.dta", clear
set more off
log using "$pathlog/panelJoin", replace

* Check missingness
mdesc HHID year
g byte misYear = (year == .)

drop hh
destring HHID, gen(hh)

* Check which files to merge in
cd "$pathout"
dir

local mfile health_all hhchar_all hhinfra_all shocks_all GeovarsMerged geoadmin hhpc_all 
foreach x of local mfile {
	merge 1:1 HHID year using "$pathout/`x'.dta", gen(mg_`x')
	la var mg_`x' "Merge results with `x'"
	}
*end

* Drop existing year interview variable
drop yearInt

merge 1:1 HHID year using "$pathout/interviewInfo_all.dta", gen(mg_int)

* Generate a date grouping for tracking data
egen intGroup = group(monthInt yearInt)
g intDate = ym(yearInt, monthInt)
format intDate %tm


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
global sampling "urban month subRegion stratum stratumP region urban latitude lat_stack longitude lon_stack HHID hh year intDate monthInt yearInt"
global health "FCS dietDiv FCS_categ stunting underweight wasting stuntedCount foodLack mealsTaken femRatio20_34 femRatio35_59"
global health2 "pctstunted underwgtCount pctunderwgt wastedCount pctwasted breastFedCount illness totIllness medCostspc"
global hhchar "femhead agehead  ageheadsq hhsize gendMix youth15to24 youth18to30 youth15to24m youth15to24f depRatio adultEquiv mixedEth orphan mosqNet mosNetChild"
global agevar "under5 under15 under24 femCount20_34 femCount35_59 hhmignet mlabor flabor wealthindex_rur wealthindex"
global edvars "educHoh educAdult quitEduchoh quitEducPreg marriedHohp under5 mlaborShare flaborShare literateHoh literateSpouse" 
global assets "electricity hutDwelling metalRoof latrineCovered latrineWash under5m under5f under15m under15f adultEquiv"
global shocks "hazardShk priceShk employShk healthShk crimeShk assetShk anyshock totShock"
global shock2 "priceShk_tot hazardShk_tot employShk_tot healthShk_tot crimeShk_tot assetShk_tot totShock_tot"
global pcashock "ag aglow conflict drought disaster financial health other theft badcope goodcope"
global env "dist_road dist_popcenter dist_market dist_borderpost dist_admctr ssa_aez09 srtm_uga"

keep $sampling $health $health2 $hhchar $edvars $assets $shocks $shock2 $pcashock $agevar $env
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
*histogram FCS, kdensity xtitle(Food Consumption Score) legend(cols(1)) name(FCS, replace) by(stratumP year, cols(2)) 

* Look at dietary diversity over time
graph box FCS, over(dietDiv) by(year, cols(3))

* Merge with RIGA dataa
drop hh
ren hhid hh
merge 1:1 hh year using "$pathout/RigaPanel.dta", gen(riga_mg)


* Winsorize agwealth and pcexp
winsor2 agwealth, replace cuts(1 99.5) by(stratumP)
clonevar pcexpend = pcexp
winsor2 pcexpend, replace cuts (1 99.5) by(stratumP)

* Flag households that survive all three years
g byte pFull = riga_mg == 3

* Fix agro_ecological zones
bys HHID (year): replace ssa_aez09 = ssa_aez09[1]

* fix jittered lat lons to be consistent overtime
bys HHID (year): g byte latCheck = (lat_stack[2] == lat_stack[1])
bys HHID (year): replace latitude = latitude[1]
bys HHID (year): replace longitude = longitude[1]

* Swap lat / lon names to use stacked data in all geoprocessing with the limitation that
* any analysis is only indicative of the sample; Not enough geographic resoluation to make
* sweeping statements regarding the representativeness of the data; Only can make conclusions
* about the sample itself and show suggestive geographic patterns which may/may not
* require more detailed sample.
ren latitude lat_jit
ren longitude lon_jit
ren lat_stack latitude
ren lon_stack longitude

* Fix stratumP values
la def strat2 1 "Kampala" 2 "Other Urban" 3 "Central Rural" 4 "East Rural" /*
*/ 5 "North Rural" 6 "West Rural"
la val stratumP strat2

* Generate uniform distribution for rasters ranges for each year
g rastUnif09 = uniform() if year==2009
g rastUnif10 = uniform() if year==2010
g rastUnif11 = uniform() if year==2011 

preserve
keep hh latitude longitude rastUnif09 rastUnif10 rastUnif11 year
forvalues i = 2009(1)2011 {
	export delimited using "$pathexport\UGA_201504_`i'_rast.csv" if year == `i', replace
}
*
restore

forvalues i = 2009(1)2011 {
	export delimited using "$pathexport\UGA_201504_`i'.csv" if year == `i', replace
}

sa "$pathout/RigaPanel_201504_all.dta", replace
export delimited using "$pathexport\UGA_201504_all.csv", replace

* Keep key regional information to merge with individual-level health data
clear
 use "$pathout/childHealth_I_all.dta", clear
merge m:1 HHID year using "$pathout/RigaPanel_201504_all.dta", gen(health_merge)
drop if health_merge==2

export delimited using "$pathexport\UGA_201504_ind_all.csv", replace

* Make graphs of malnutrition indicators
global zscores "stunting wasting underweight"
local i = 2009

	foreach x of global zscores {
	 graph twoway histogram `x'|| function y=normalden(x,0,1), by(year) /*
		*/ range(`x') title("`x'") xtitle("z-score") ytitle("Density") /*
		*/ legend(off)
	 *gen below2_`x'`i' = (`x' < -2)
	 *gen below3_`x'`i' = (`x' < -3)
	 more
	}


tabstat $zscores below* , stat(mean sd) col(stat) by(year)

* Make scatter plots of the indicators to see how correlated they are
forvalues i=2009(1)2011 {
	twoway(scatter stunting wasting) if year==`i', ylabel(-6 0 5) xlabel(-6 0 5)
	more
	
	twoway(scatter stunting underweight) if year==`i', ylabel(-6 0 5) xlabel(-6 0 5)
	more
	
	twoway(scatter wasting underweight) if year==`i', ylabel(-6 0 5) xlabel(-6 0 5)
	more
}
*end

log close




