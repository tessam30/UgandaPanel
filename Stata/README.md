Using Stata .do files
-------------

##### Preliminaries  
This folder contains all of the Stata code to set up and execute the LVAM project on your local computer. All do files are given a run order indicated by the first two numbers of the .do file name. When creating new files, please preverse the run order as much as possible. For example, ```00_SetupFoldersGlobals``` is the first file in the sequence. This file should be exectued **at the start** of each session in order to enable the global macros.  Before executing any of the do files, please review the ```00_SetupFolderGlobals.do file```. This will provide you an overview of the file folder structure and the global macros.

##### Package (.ado) Installation
To ensure that all .ado packages available for analysis are loaded across machines, the user should first install the .pkl (Stata package list) file. This can be done by downloading the .pkl file (```Uganda/Stata/TimAdoPC.pkl```) and running the following command in Stata:  
```{stata}
ssc install adolist  
adolist install C:\Users\*YOURNAME*\Downloads\TimAdoPC
``` 
This will install a suite of .ado packages used in the analysis. For users familiar with R, this process is similar to running:
```{r}
install.packages(packagename) 
library(packagename)
```  
This ensures that all .ado files needed for analysis are loaded ahead of time. In cases where the user is not able to execute this command, .ado files can also be located by typing the following into the Stata command prompt:
```{stata}
findit adofilename
```
*In case you have problems downloading the .pkl from Github, you should be able to copy the contents of the file and save it as a .pkl in a text editor.*

##### Project Setup & File Folder Structure 

The typical project structure is created by executing the ```00_SetupFoldersGlobals.do``` file and produces a directory similar to the one below:  
![File Folder Structure](https://cloud.githubusercontent.com/assets/5873344/5705046/5c5b81de-9a44-11e4-802b-1ca8d44c94c5.PNG)

Line 34 of of the file creates the main project path and line 36 changes the directory to this path.  
``` {stata}
  global projectpath "U:\"
  cd "$projectpath"
```  

Lines 40-49 create the root project folder and check if a folder with the same name already exists.  
```{stata}
local pFolder UgandaLVAM
foreach dir in `pFolder' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
		mkdir "`dir'"
		display in yellow "Project directory named: `dir' created"
		}
	else disp as error "`dir' already exists, not created."
	cd "$projectpath\`dir'"
	}
```  
	
Lines 54-62 create the sub-folders for the project. Generally, the same sub-folders are used across projects for consistency.
```{stata}
local folders Rawdata Stata Datain Log Output Dataout Excel PDF Word Graph GIS Export R Python Programs
foreach dir in `folders' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
			mkdir "`dir'"
			disp in yellow "`dir' successfully created."
		}
	else disp as error "`dir' already exists. Skipped to next folder."
}
```

Finally, the last part of the file enables the global macros used throughout the analsyis. The advantage of using global macros is it eliminates the hard-coding of any commands and ensures code portability across machines.  Lines 68-84 define the global macros.
```{stata}
global date $S_DATE
local dir `c(pwd)'
global path "`dir'"
global pathdo "`dir'\Stata"
global pathlog  "`dir'\Log"
global pathin "`dir'\Datain"
global pathout "`dir'\Dataout"
global pathgraph "`dir'\Graph"
global pathxls "`dir'\Excel"
global pathreg "`dir'\Output"
global pathgis "`dir'\GIS"
global pathraw "`dir'\Rawdata"
global pathexport "`dir'\Export"
global pathR "`dir'\R"
global pathPython "`dir'\Python"
global pathProgram "`dir'\Program"
global pathPdrive "P:\GeoCenter\GIS\Projects\UgandaLVAM"
```  

Once the file folder structure is setup and the macros defined, raw data is usually cut and pasted into the ```Rawdata``` folder. I am still working on a method to automate this process.

##### Using Global Macros
Once the first .do file has been executed, the global macros can be called by referencing them with the ```$``` in the command prompt.  For example, the following code closes any open log files, defines a new log file and loads in a batch of data fromn the Pathin folder for processing:
```{stata}
capture log close
log using "$pathlog/01_hhchar", replace

* Load household survey module of all individuals. Collapse down for hh totals.
use "$pathin\003_mod_b1_male.dta", clear
```

##### Copylabels and Attachlabels
Some of the LSMS modules are stored as individual-level datasets. As our analysis focuses on household livelihoods, we often summarize and collapse the data down to the household level. When collapsing data in Stata value labels are often lost in the process. To preserve value labels before and after the collapse command, we use the copylabels.do and the attachlabels.do files. Copies of these files should be downloaded and stored in the folder linked to the  ```$pathdo``` global macro.    

The example code below shows the label commands in action (from Bangladesh LVAM):
```{stata}
* Collapse everything down to HH-level using max values for all vars
* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

#delimit ;
	collapse (max) hoh femhead agehead ageheadsq marriedHead widowHead 
		singleHead hhSize msize fsize sexRatio depRatio 
		hhlabor mlabor flabor mlaborShare flaborShare under15 
		under15male under24 under24male under15Share under24Share 
		literateHead spouseLit educ educAdult educHoh occupation
		widowFemhead
		sample_type, by(a01) fast;
#delimit cr
order a01

* Reapply variable lables & value labels
include "$pathdo/attachlabels.do"

* Add notes to variables if needed
notes educAdult: missing values indicate that no member of household was over 25
compress

* Save
save "$pathout/hhchar.dta", replace
```




