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

order mg*, last

* Retain key variables of interest for exploring with R and ArcGIS
global health "FCS dietDiv FCS_categ stunting underweight wasting stuntedCount"
global health2 "pctstunted underwgtCount pctunderwgt wastedCount pctwasted breastFedCount illness totIllness medCostspc"
global hhchar "femhead agehead hhsize gendMix youth15to24 youth18to30 depRatio adultEquiv mixedEth orphan mosqNet mosNetChild"
global edvars "educHoh educAdult quitEduchoh quitEducPreg" 
global assets "electricity hutDwelling metalRoof latrineCovered latrineWash"
global shocks "hazardShk priceShk employShk healthShk crimeShk assetShk anyshock totShock"
global shock2 "priceShk_tot hazardShk_tot employShk_tot healthShk_tot crimeShk_tot assetShk_tot totShock_tot"

keep $health $health2 $hhchar $edvars $assets $shocks $shock2 latitude lat_stack longitude lon_stack HHID hh year
drop if latitude == .

* Sort data into panels
sort HHID year
destring HHID, gen(hhid)
order HHID hh hhid year, first
export delimited "$pathexport/keyVars_201504.csv", replace

* Look at FCS and diet Diversity trends over the years
twoway(histogram FCS), by(year, cols(1))
histogram FCS, kdensity xtitle(Food Consumption Score) legend(cols(1)) name(FCS, replace) by(year, cols(1))

