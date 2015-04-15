/*-------------------------------------------------------------------------------
# Name:		51_sumStats
# Purpose:	Create summary stats of variables created as of 201504.
# Author:	Tim Essam, Ph.D.
# Created:	04/15/2015
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------*/

* create log file and load the data
clear
capture log close
log using "$pathlog/sumStats.do"

u "$pathout/RigaPanel_201504.dta"

* First look at the distribution of shocks by subRegion

table year subRegion, c(mean hazardShk mean healthShk mean crimeShk mean priceShk)

* Created logged per capita expenditure variable
g lnpcexp = ln(pcexp)

* Look at how FCS varies across subregions
