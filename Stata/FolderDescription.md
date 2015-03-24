####Description of project folders  

===

The use of the folders created typically is as follows:  

| Folder   | Description                                                                                              |
|----------|----------------------------------------------------------------------------------------------------------|
| Datain   | raw data or unprocessed data from which,derived data is created                                          |
| Dataout  | derived data create in Stata or R                                                                        |
| Excel    | any .xls, .xlsx, or .csv file that supports the project. Often used for quick data vizualizations.       |
| Export   | used to score cuts of data that are exported,to other individuals or statistical programs (R, Python)    |
| GIS      | all GIS related data, documentation, and geodatabases. May need it's own sub-folder structure.            |
| Graph    | graphics related to the project                                                                          |
| Log      | Stata log files or R log files documenting work flow                                                     |
| Output   | Analysis output, such as estout or outreg2 files or statistical tables                                   |
| PDF      | For storing survey documentation, completed PDFs, or other project related documents that in this format |
| Programs | used to store customized programs created in Stata or R. These can be called in Stata or "sourced" in R  |
| Python   | Python files that execute geoprocessing, spatial or geostatistical analysis                              |
| Rawdata  | All raw project data in any form. Data in the folder are to remain in their original form                |
| Stata    | Folder housing all of the do files for the project                                                       |
| Word     | all Word related documents stored here                                                                   |  
  
*Additional folders can be created as needed for each project. This will generally be done using the 00_SetupGlobalsFolder.do file.*

