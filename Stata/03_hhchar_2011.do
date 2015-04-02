/*------------------------------------------------------------------------------
# Name:		03_hhchar_2011
# Purpose:	Process household characteristics and education characteristics
# Author:	Tim Essam
# Created:	2015/2/26
# License:	MIT License
# Ado(s):	labutil, labutil2 (ssc install labutil, labutil2)
# Dependencies: copylables, attachlabels, 00_SetupFoldersGlobals.do
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "$pathlog/03_hhchar_2011", replace
di in yellow "`c(current_date)' `c(current_time)'"
set more off

use "$wave3/GSEC2.dta", replace

* Merge education data to household roster using the force command
merge 1:1 HHID PID using "$wave3/GSEC4.dta", force
ren _merge gsecMerge
merge 1:1 HHID PID using "$wave3/GSEC3.dta", force

/* Demographic list to calculate
1. Head of Household Sex
2. Relationship Status
*/

* Create head of household variable based on primary respondent and sex
g byte hoh = h2q4 == 1
la var hoh "Head of household"

g byte femhead = h2q3 == 2 & h2q4 == 1
la var femhead "Female head of household"

g agehead = h2q8 if hoh == 1
la var agehead "Age of head of household"

g ageSpouse = h2q8 if h2q4 == 2
la var ageSpouse "Age of spouse"

g ageheadsq = agehead^2
la var ageheadsq "Squared age of the head (for non-linear life experience)"

* Relationship status variables
g byte marriedHohm = h2q10 == 1 & hoh==1
la var marriedHohm "married HOH monogamous"

g byte marriedHoh = hoh ==1 & inlist(h2q10, 1, 2)
la var marriedHoh "married head of household (any type)"

g byte marriedHohp = h2q10 == 2 & hoh==1
la var marriedHohp "married HOH polygamous"

g byte divorcedHead = (h2q10 == 3 & hoh==1)
la var divorcedHead "divorced HoH"

g byte divorcedFemhead = (h2q10 == 3 & femhead == 1)
la var divorcedFemhead "divorced Female head of household"

g byte widowHead = (h2q10 == 4 & hoh==1)
la var widowHead "widowed HoH"

g byte widowFemhead = (h2q10 == 4 & femhead == 1)
la var widowFemhead "Widowed Female head of household"

g byte singleHead = (h2q10==5 & hoh==1)
la var singleHead "single HoH"

g byte singleFemhead = (h2q10==5 & femhead == 1)
la var singleFemhead "single HoH"

* Calculate household demographics (size, adult equivalent units, dep ratio, etc).

/* Household size - Household size refers to the number of usual members in a 
household. Usual members are defined as those who have lived in the household 
for at least 6 months in the past 12 months. However, it includes persons who 
may have spent less than 6 months during the last 12 months in the household 
but have joined the household with intention to live permanently or for an 
extended period of time.
* http://www.ubos.org/UNHS0910/chapter2_householdcharacteristics.html */

*Create a flag variable for determining who is a usual member from above.
g byte hhmemb = (inlist(h2q7, 1, 2) & h2q5 >= 6)
la var hhmemb "Usual member of household"
egen hhsize = total(hhmemb), by(HHID)
la var hhsize "household size"

* Create gender ratio for households
g byte male = h2q3 == 1 & hhmemb == 1
g byte female = h2q3 == 2 & hhmemb == 1
la var male "male hh members"
la var female "female hh members"

egen msize = total(male), by(HHID)
la var msize "number of males in hh"

egen fsize = total(female), by(HHID)
la var fsize "number of females in hh"

* Create a gender ratio variable
g gendMix = msize/fsize
recode gendMix (. = 0) if fsize==0
la var gendMix "Ratio of males to females (1 = 1:1 mix)"

* Calculate age demographics (Youth)
* Make cuts at 0-5; 6-9; 10-14; 15-17; 18-24; 25-30; 31-35;
* Youth standard definition is 15-24; 
* Uganda definition is 18-30 (http://www.ubos.org/onlinefiles/uploads/ubos/pdf%20documents/NCLS%20Report%202011_12.pdf)
egen youthtmp = cut(h2q8), at(0, 6, 10, 15, 18, 25, 31, 36) icodes
table youthtmp, c(min h2q8 max h2q8)
table h2q8 youthtmp

* Create binary variables for demographic categories
g byte under5tmp = inlist(youthtmp, 0) & hhmemb == 1
g byte under15tmp = inlist(youthtmp, 0, 1, 2) & hhmemb == 1
g byte under24tmp = inlist(youthtmp, 0, 1, 2, 3, 4) & hhmemb == 1
g byte youth15to24tmp = inlist(youthtmp, 3, 4) & hhmemb == 1
g byte youth18to30tmp = inlist(youthtmp, 4, 5) & hhmemb == 1

* Create total, male and female totals at the household level of each demographic
local demo under5 under15 under24 youth15to24 youth18to30 
foreach x of local demo {
	egen `x'  = total(`x'tmp), by(HHID)
	egen `x'm = total(`x'tmp) if male == 1, by(HHID)
	egen `x'f = total(`x'tmp) if female == 1, by(HHID)
	
	la var `x' "total hh members `x'"
	la var `x'm "total male hh members `x'"
	la var `x'f "total female hh members `x'"
}
*end

/* Create intl. HH dependency ratio (age ranges appropriate for Bangladesh)
# HH Dependecy Ratio = [(# people 0-14 + those 65+) / # people aged 15-64 ] * 100 # 
The dependency ratio is defined as the ratio of the number of members in the age groups 
of 0Ã¢â‚¬â€œ14 years and above 60 years to the number of members of working age (15Ã¢â‚¬â€œ60 years). 
The ratio is normally expressed as a percentage (data below are multiplied by 100 for pcts.*/
g byte numDepRatio = (h2q8 < 15 | h2q8 > 64) & hhmemb == 1
g byte demonDepRatio = numDepRatio != 1 & hhmemb == 1
egen totNumDepRatio = total(numDepRatio), by(HHID)
egen totDenomDepRatio = total(demonDepRatio), by(HHID)

* Check that numbers add to hhsize
assert hhsize == totNumDepRatio+totDenomDepRatio if hhmemb==1
g depRatio = (totNumDepRatio/totDenomDepRatio)*100 if totDenomDepRatio!=.
recode depRatio (. = 0) if totDenomDepRatio==0
la var depRatio "Dependency Ratio"

drop numDepRatio demonDepRatio totNumDepRatio totDenomDepRatio
 
* Calculate household labor shares (ages 12 - 60)
/* Household Labor Shares */
g byte hhLabort = (h2q8>= 12 & h2q8<60) & hhmemb == 1
egen hhlabor = total(hhLabort), by(HHID)
la var hhlabor "hh labor age>11 & < 60"

g byte mlabort = (h2q8>= 12 & h2q8<60 & male == 1 & hhmemb == 1)
egen mlabor = total(mlabort), by(HHID)
la var mlabor "hh male labor age>11 & <60"

g byte flabort = (h2q8>= 12 & h2q8<60 & female == 1 & hhmemb == 1)
egen flabor = total(flabort), by(HHID)
la var flabor "hh female labor age>11 & <60"
drop hhLabort mlabort flabort

* Male/Female labor share in hh
g mlaborShare = mlabor/hhlabor
recode mlaborShare (. = 0) if hhlabor == 0
la var mlaborShare "share of working age males in hh"

g flaborShare = flabor/hhlabor
recode flaborShare (. = 0) if hhlabor == 0
la var flaborShare "share of working age females in hh"

* Generate adult equivalents in household
g male10 	= 1
g fem10_19 	= 0.84
g fem20		= 0.72
g child10	= 0.60

g ae = .
replace ae = male10 if (h2q8 >=10 ) & male == 1 & hhmemb == 1
replace ae = fem10_19 if (h2q8 >= 10 & h2q8 < 20) & female == 1 & hhmemb == 1
replace ae = fem20 if (h2q8 >= 20) & female == 1 & hhmemb == 1
replace ae = child10 if (h2q8) < 10 & hhmemb == 1 & hhmemb == 1
la var ae "Adult equivalents in household"

egen adultEquiv = total(ae), by(HHID)
la var adultEquiv "Total adult equivalent units"

* Ethnicity codes of household members - create mixed hh codes or homogenous hh
* Codes found in UNPS2010.Household.Woman.Qx.Manual.pdf (pp. 132)
la def eth 11 "Acholi" 12 "Alur" 13 "Baamba" 14 "Babukusu" 15 "Babwisi" /*
*/ 16 "Bafumbira" 17 "Baganda" 18 "Bagisu" 19 "Bagungu" 20 "Bagwe" 21 "Bagwere"  /*
*/ 22 "Bahehe" 23 "Bahororo" 24 "Bakenyi" 25 "Bakiga" 26 "Bakhonzo" /*
*/ 27 "Banyabindi" 28 "Banyakole" 29 "Banyara" 30 "Banyarwanda" 31 "Banyole" /*
*/ 32 "Banyoro" 33 "Baruli" 34 "Basamia" 35 "Basoga" 36 "Basongora" /*
*/ 37 "Batagwenda" 38 "Batoro" 39 "Batuku" 40 "Batwa" 41 "Chope" 42 "Dodoth" /*
*/ 43 "Ethur" 44 "Ik (Teuso)" 45 "Iteso" 46 "Indian" 47 "Japadhola" 48 "Jie" /*
*/ 49 "Jonam" 50 "Kakwa" 51 "Karimojong" 52 "Kebu" 53 "Kuku" 54 "Kumam" /*
*/ 55 "Langi" 56 "Lendu" 57 "Lugbara" 58 "Madi" 59 "Mening" 60 "Mvuba" 61 "Napore"/*
*/ 62 "Nubi" 63 "Nyangia" 64 "Pokot" 65 "Sabiny" 66 "So (Tepeth)" 67 "Vonoma" 68 "Other"
la val h3q9 eth

* Create variable reflectin whether or not husband/wife are same ethnic mix
g ethHeadtmp = h3q9 if h2q4 == 1

egen ethHead = max(ethHeadtmp), by(HHID)
la val ethHead eth
la var ethHead "Ethnicity of head"

g ethSpousetmp = h3q9 if h2q4 == 2
egen ethSpouse = max(ethSpousetmp), by(HHID)
la val ethSpouse eth
la var ethSpouse "Ethnicity of spouse"

g byte mixedEth = (ethHead != ethSpouse) if marriedHoh==1 & ethHead!=. & ethSpouse !=.
replace mixedEth = 0 if mixedEth ==.
la var mixedEth "mixed ethnicity household"

egen mixedEthType = concat(ethHead ethSpouse) if ethHead!=. & ethSpouse !=. & ethHead!=ethSpouse, decode p("-")
encode mixedEthType, gen(mixedEthN)
drop mixedEthType
la var mixedEthN "type of mixed ethinicity household"

***********
* Orphans *
***********
g byte orphan = h3q2a == 3 & h3q5a == 3
egen orphanhh = total(orphan), by(HHID)
la var orphan "hh member is an ophan"
la var orphanhh "total number of orphans in hh"

********************
* Mosquito net use *
********************
* Assuming "don't know == no"
g byte mosqNet = inlist(h3q10, 1, 2) == 1 & hhmemb == 1
la var mosqNet "member slept under net"

* For net to be considered treated, we are requiring it to be dipped
g byte mosqNetT = inlist(h3q10, 2) == 1 & h3q12 == 1 & hhmemb == 1
la var mosqNetT "member slept under dipped net"

g byte mosqNetUt = inlist(h3q10, 1, 2) == 1 & h3q12 != 1 & hhmemb == 1
la var mosqNetUt "member slept under non-dipped net"

g byte mosqNetHead = (mosqNet == 1 & hoh == 1)
la var mosqNetHead "hoh slept under mosquito net"

g byte mosNetSpouse = (mosqNet == 1 & h2q4 == 2 & hhmemb == 1)
la var mosNetSpouse "spouse slept under mosquito net"

g byte mosNetChild = (mosqNet == 1 & h2q4 == 3 & hhmemb == 1 & h2q8<=18)
la var mosNetChild "Child (under 18) slept under mosquito net"

g byte mosNetGchild = (mosqNet == 1 & h2q4 == 4 & hhmemb == 1 & h2q8<=18)
la var mosNetGchild "Grand child (under 18) slept under mosquito net" 

* Calculate % of hh member sleeping under net (also check if head slept under net)
egen mosNethh = total(mosqNet), by(HHID)
egen mosNetThh = total(mosqNetT), by(HHID)
la var mosNethh "total mosquito nets used in household"
la var mosNetThh "total treated mosquito nets used in household"

g pctMosNet = mosNethh / hhsize
g pctMosNetT = mosNetThh / hhsize
la var pctMosNet "Share of household using nets"
la var pctMosNetT "Share of household using treated nets"

* Calculate % of children under 18 sleeping under net
g byte chltmp = (h2q4 == 3 & hhmemb == 1 & h2q8<=18)
egen totChild = total(chltmp), by(HHID)

g byte gchltmp = (h2q4 == 4 & hhmemb == 1 & h2q8<=18)
egen totGchild = total(gchltmp), by(HHID)

egen mosNetChildtot = total(mosNetChild), by(HHID)
egen mosNetGchildtot = total(mosNetGchild), by(HHID)
la var mosNetChildtot "Total children using mosquito net"
la var mosNetGchildtot "Total grand-children using mosquito net"

g pctmosNetChild = mosNetChildtot / totChild
g pctmosNetGChild = mosNetGchildtot / totGchild

la var totChild "Total children in hh"
la var totGchild "Total grandchildren in hh"
la var pctmosNetChild "Share of children using nets"
la var pctmosNetGChild "Share of grandchildren using nets"

******************
* Skipping meals *
******************
g byte mealskip = (T6FQ13)==1 & T6FQ16 != 0 & hhmemb == 1
egen totMealSkip = total(mealskip), by(HHID)
g pctMealSkip = totMealSkip / hhsize
la var pctMealSkip "Share of household skipping meals"
la var mealskip "household member skipped meals"
la var totMealSkip "number of household members skipping meals"

******************
* Migration ties *
******************
* (DEFINED AS EVER MIGRATED: (1) Has lived in current village/town for one to five years 
g byte hhmig = inlist(h3q15, 1, 2, 3, 4, 5)==1
egen hhmignet = max(hhmig) , by(HHID)
la var hhmignet "household migration network"

**********************
* Education outcomes *
**********************
/* Literacy is defined as oneÃ¢â‚¬â„¢s ability to read with understanding and to 
 write meaningfully in any language. */
g byte literateHoh = h4q4 == 4 & hoh == 1
g byte literateSpouse = h4q4 == 4 & h2q4 == 2 & hhmemb == 1

la var literateHoh "Hoh is literate"
la var literateSpouse "Spouse is literate"

/* Education level values found in h4q7 defined using the following:
http://microdata.worldbank.org/index.php/catalog/565/datafile/F2/V110
http://www.classbase.com/countries/Uganda/Education-System
	No Education (0)
	Pre-Primary (Less than Primary Year 1)
	Primary Level (Years 1 - 7)
	Post-Primary Specialized Training or Certificate
	Junior Vocational/Technical (Years 8 - 10)
	Lower Secondary (Years 8 - 11)
	Upper Secondary (Years 11 - 13)
	Post-Secondary Specialized Training or Certificate
	Tertiary (Above Secondary other than Post-Secondary Specialized Training or Cer
tificate)
*/
g educ = . 
la var educ "Education levels"
* No education (This includes:"Don't Know" and "2" Responses))
replace educ = 0 if inlist(h4q7, 2, 99)
* Pre-primary
replace educ = 1 if inlist(h4q7, 10)
* Primary
replace educ = 2 if inlist(h4q7, 11, 12, 13, 14, 15, 16, 17)
* Post-Primary Specialized Training or Certificate
replace educ = 3 if inlist(h4q7, 41)
* Junior Techincal/Vocational 
replace educ = 4 if (inlist(h4q7, 21, 22, 23) | inlist(h4q9, 21, 22, 23))
* Lower Secondary 
replace educ = 5 if (inlist(h4q7, 31, 32, 33, 34) | inlist(h4q9, 31, 32, 33, 34))
* Upper Secondary 
replace educ = 6 if (inlist(h4q7, 35, 36) | inlist(h4q9, 35, 36))
* Post-Secondary Specialized Training or Certificate
replace educ = 7 if (inlist(h4q7, 51, 50) | inlist(h4q9, 50, 51))
* Tertiary
replace educ = 8 if (inlist(h4q7, 61) | inlist(h4q9, 61))

g educHoh = educ if hoh == 1
g educSpouse = educ if h2q4 == 2 & hhmemb == 1

lab def ed 0 "No education" 1 "Pre-primary" 2 "Primary" 3 "Post-Primary" /*
*/ 4 "Junior Techincal/Vocational " 5 "Lower Secondary" 6 "Upper Secondary" /*
*/ 7 "Post-Secondary Specialized" 8 "Tertiary"
la values educ ed
la values educHoh ed
la values educSpouse ed

* Create variable to reflect the maximum level of education in the household for those 25+
egen educAdult = max(educ) if h2q8>24 & hhmemb ==1, by(HHID)
egen educAdultM = max(educ) if h2q8>24 & hhmemb ==1 & male == 1, by(HHID)
egen educAdultF = max(educ) if h2q8>24 & hhmemb ==1 & female == 1, by(HHID)

* Max youth education in hh
egen educYouth = max(educ) if h2q8>17 & h2q8<31 & hhmemb == 1, by(HHID)
egen educYouthM = max(educ) if h2q8>17 & h2q8<31 & hhmemb == 1 & male == 1, by(HHID)
egen educYouthF = max(educ) if h2q8>17 & h2q8<31 & hhmemb == 1 & female == 1, by(HHID)

* Apply value labels
local edlist educ educHoh educSpouse educAdult educAdultM educAdultF educYouth educYouthM educYouthF
foreach x of local edlist {
	replace `x' = 0 if h4q5 == 1
	la values `x' ed
}
*end

la var educAdult "Highest adult education in household"
la var educAdultM "Highest male adult education in household"
la var educAdultF "Highest female adult education in household"
la var educHoh "Education of Hoh"
la var educSpouse "Education of spouse"
la var educYouth "Max education of youth"
la var educYouthM "Max education of male youth"
la var educYouthF "Max edcuation of female youth"

* Calculate school expenses for all regular household members
egen totSchoolExptmp = rsum2(h4q15a h4q15b h4q15c h4q15d h4q15e h4q15f)
replace totSchoolExptmp = h4q15g if totSchoolExp == 0
egen totSchoolExp = total(totSchoolExptmp), by(HHID)
la var totSchoolExp "Total school expenses for household"

g byte aidSchool = (h4q16 == 1)
la var aidSchool "HH member received school scholarship (all sources)"

* Create variables reflecting school dropouts
g byte quitEduchoh = (h4q8!=.  & hhmemb == 1 & hoh == 1)
la var quitEduc "stopped education early"

g byte quitEduc25  = (h4q8!=. & h2q8<= 25 & hhmemb == 1)
g byte quitEducPreg = (h4q8 == 13 & h2q8<=25 & hhmemb == 1)
la var quitEduc25 "Quit school early"
la var quitEducPreg "Quit school due to pregnancy (under 25)"

* Occupation of mother and father (do not know codes yet, need to get them).
g byte occupFath = h3q4 if hhmemb == 1
g byte oocupMoth = h3q7 if hhmemb == 1
la var occupFath "Father's occupation"
la var oocupMoth "Mother's occupation"

drop youthtmp under5tmp under15tmp under24tmp youth15to24tmp youth18to30tmp /*
*/  male10 fem10_19 fem20 child10 ethHeadtmp ethSpousetmp chltmp gchltmp /*
*/ hhmig totSchoolExptmp

* Retain only derived data for collapsing
qui ds(h2q* h4* T6* T2* LocID gsecMerge h3q* _merge educ ae), not
keep `r(varlist)'

preserve
keep if hhmemb == 1
save "$pathout/hhchar_ind_2011.dta", replace
restore

drop PID
* Collapse everything down to HH-level using max values for all vars
* Copy variable labels to reapply after collapse
qui include "$pathdo2/copylabels.do"

qui ds(HHID), not
collapse (max) `r(varlist)', by(HHID) 

* Reapply variable lables & value labels
qui include "$pathdo2/attachlabels.do"

la val mixedEthN mixedEthN

* Summarize collapsed data and review for potential coding errors
sum

* Check missing values and determine which ones can be replaced with zero
mdesc
replace pctMosNet = 0 if pctMosNet == .
replace pctMosNetT = 0 if pctMosNetT == .
replace pctMealSkip = 0 if pctMealSkip == .

foreach x of varlist youth* under* {
	replace `x' = 0 if `x' == .
}
*end	

* label values
foreach x of varlist  educHoh educSpouse educAdult educAdultM educAdultF educHoh educSpouse {
	la values `x' ed
	tab `x'
	}
*end

*merge 1:1 HHID using "$pathout/Geovars.dta", gen(geo_merge)
g year = 2011
* Save
save "$pathout/hhchar_2011.dta", replace

* Keep a master file of only household id's for missing var checks
use "$wave3/GSEC2", replace
keep HHID PID
g year = 2011
save "$pathout/hhid_2011.dta", replace

* Create an html file of the log for internet sharability
log2html "$pathlog/03_hhchar_2011", replace
log close
