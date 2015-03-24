/*-------------------------------------------------------------------------------
# Name:		attachlables
# Purpose:	Attaches labels to a dataset; for use after collapse command
# Author:	Tim Essam, Ph.D.
# Created:	2014/11/06
# Copyright:	USAID GeoCenter
# Licence:	<Tim Essam Consulting/OakStream Systems, LLC>
# Ado(s):	none
#-------------------------------------------------------------------------------
*/

foreach v of var * {
        label var `v' "`l`v''"
}
