* Create a simple function to append data from the panel.
* Use: Function is called anytime three datasets are merged together

capture program drop pappend
program define pappend
set more off
	
	/* Four inputs required 
	* 1 - 2009 data file name
	* 2 - 2010 data file name
	* 3 - 2011 data file name to which you are appending
	* 4 - name of append variable to be created */
	
	* Append 1 & 2 to 3 (which is assumed to be using data)
	clear
	use "$pathout/`3'.dta"
	append using "$pathout/`1'.dta" "$pathout/`2'.dta", gen(`4')
	capture confirm variable year
		if !_rc {
				di in yellow "Year variable already exists."
				}
		else {
				ren `4' year
				replace year = 2011 if year == 0
				replace year = 2009 if year == 1
				replace year = 2010 if year == 2 
			}
	* Tabulate year to check appending data make sense		
	tab year
	
	* Delete annual datasets to minimize disk space usage
	*erase "$pathout/`1'.dta"
	*erase "$pathout/`2'.dta"
	*erase "$pathout/`3'.dta"

end	
