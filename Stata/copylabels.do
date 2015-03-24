/*-------------------------------------------------------------------------------
# Name:		copylabels
# Purpose:	Copies labels from a dataset; for use before collapse command
# Author:	Tim Essam, Ph.D.
# Created:	2014/11/06
# Copyright:	USAID GeoCenter
# Licence:	<Tim Essam Consulting/OakStream Systems, LLC>
# Ado(s):	none
#-------------------------------------------------------------------------------
*/

foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}
