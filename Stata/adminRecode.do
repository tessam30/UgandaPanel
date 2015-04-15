g dist2011=.

* Fix mispelled district names
replace district ="KALANGALA" if district == "KALANGA"
replace district ="BULIISA" if district == "BULLISA"
replace district ="BUKWA" if district == "BUKWO"

replace dist2011 =314  if district =="ABIM"
replace dist2011 =301  if district =="ADJUMANI"
replace dist2011 =315  if district =="AMOLATAR"
replace dist2011 =216  if district =="AMURIA"
replace dist2011 =316  if district =="AMURU"
replace dist2011 =316  if district =="NWOYA"
replace dist2011 =302  if district =="APAC"
replace dist2011 =302  if district =="KOLE"
replace dist2011 =303  if district =="ARUA"
replace dist2011 =217  if district =="BUDAKA"
replace dist2011 =218  if district =="BUDUDA"
replace dist2011 =201  if district =="BUGIRI"
replace dist2011 =201  if district =="NAMAYINGO"
replace dist2011 =219  if district =="BUKEDEA"
replace dist2011 =416  if district =="BULIISA"
replace dist2011 =401  if district =="BUNDIBUGYO"
replace dist2011 =401  if district =="NTOROKO"
replace dist2011 =402  if district =="BUHWEJU"
replace dist2011 =402  if district =="BUSHENYI"
replace dist2011 =402  if district =="MITOOMA"
replace dist2011 =402  if district =="RUBIRIZI"
replace dist2011 =402  if district =="SHEEMA"
replace dist2011 =202  if district =="BUSIA"
replace dist2011 =221  if district =="BUTALEJA"
replace dist2011 =317  if district =="DOKOLO"
replace dist2011 =304  if district =="GULU"
replace dist2011 =403  if district =="HOIMA"
replace dist2011 =417  if district =="IBANDA"
replace dist2011 =203  if district =="IGANGA"
replace dist2011 =203  if district =="LUUKA"
replace dist2011 =418  if district =="ISINGIRO"
replace dist2011 =204  if district =="JINJA"
replace dist2011 =318  if district =="KAABONG"
replace dist2011 =404  if district =="KABALE"
replace dist2011 =405  if district =="KABAROLE"
replace dist2011 =213  if district =="KABERAMAIDO"
replace dist2011 =101  if district =="KALANGALA"
replace dist2011 =222  if district =="KALIRO"
replace dist2011 =102  if district =="KAMPALA"
replace dist2011 =205  if district =="BUYENDE"
replace dist2011 =205  if district =="KAMULI"
replace dist2011 =413  if district =="KAMWENGE"
replace dist2011 =414  if district =="KANUNGU"
replace dist2011 =206  if district =="KAPCHORWA"
replace dist2011 =206  if district =="KWEEN"
replace dist2011 =406  if district =="KASESE"
replace dist2011 =207  if district =="KATAKWI"
replace dist2011 =112  if district =="KAYUNGA"
replace dist2011 =407  if district =="KIBAALE"
replace dist2011 =103  if district =="KIBOGA"
replace dist2011 =103  if district =="KYANKWANZI"
replace dist2011 =419  if district =="KIRUHURA"
replace dist2011 =408  if district =="KISORO"
replace dist2011 =305  if district =="KITGUM"
replace dist2011 =305  if district =="LAMWO"
replace dist2011 =319  if district =="KOBOKO"
replace dist2011 =306  if district =="KOTIDO"
replace dist2011 =208  if district =="KUMI"
replace dist2011 =208  if district =="NGORA"
replace dist2011 =415  if district =="KYEGEGWA"
replace dist2011 =415  if district =="KYENJOJO"
replace dist2011 =307  if district =="ALEBTONG"
replace dist2011 =307  if district =="LIRA"
replace dist2011 =307  if district =="OTUKE"
replace dist2011 =104  if district =="LUWEERO"
replace dist2011 =114  if district =="LYANTONDE"
replace dist2011 =105  if district =="BUKOMANSIMBI"
replace dist2011 =105  if district =="LWENGO"
replace dist2011 =105  if district =="MASAKA"
replace dist2011 =105  if district =="KALUNGU"
replace dist2011 =409  if district =="KIRYANDONGO"
replace dist2011 =409  if district =="MASINDI"
replace dist2011 =214  if district =="MAYUGE"
replace dist2011 =209  if district =="MBALE"
replace dist2011 =410  if district =="MBARARA"
replace dist2011 =115  if district =="MITYANA"
replace dist2011 =308  if district =="MOROTO"
replace dist2011 =308  if district =="NAPAK"
replace dist2011 =309  if district =="MOYO"
replace dist2011 =106  if district =="MPIGI"
replace dist2011 =107  if district =="MUBENDE"
replace dist2011 =108  if district =="BUIKWE"
replace dist2011 =108  if district =="MUKONO"
replace dist2011 =108  if district =="BUVUMA"
replace dist2011 =311  if district =="AMUDAT"
replace dist2011 =311  if district =="NAKAPIRIPIRIT"
replace dist2011 =116  if district =="NAKASEKE"
replace dist2011 =109  if district =="NAKASONGOLA"
replace dist2011 =224  if district =="NAMUTUMBA"
replace dist2011 =310  if district =="GOMBA"
replace dist2011 =310  if district =="NEBBI"
replace dist2011 =310  if district =="ZOMBO"
replace dist2011 =411  if district =="NTUNGAMO"
replace dist2011 =321  if district =="OYAM"
replace dist2011 =312  if district =="AGAGO"
replace dist2011 =312  if district =="PADER"
replace dist2011 =210  if district =="KIBUKU"
replace dist2011 =210  if district =="PALLISA"
replace dist2011 =110  if district =="RAKAI"
replace dist2011 =412  if district =="RUKUNGIRI"
replace dist2011 =215  if district =="BULAMBULI"
replace dist2011 =215  if district =="SIRONKO"
replace dist2011 =211  if district =="SERERE"
replace dist2011 =211  if district =="SOROTI"
replace dist2011 =111  if district =="SSEMBABULE"
replace dist2011 =212  if district =="TORORO"
replace dist2011 =113  if district =="WAKISO"
replace dist2011 =313  if district =="YUMBE"
replace dist2011 =223  if district =="MANAFWA"
replace dist2011 =500  if district =="MARACHA"
replace dist2011 =220  if district =="BUKWA"

* Fill in 2009 district values based on 2009 dist_codes
replace dist2011 = dist_code if dist2011 == . & year == 2009

* drop if year is missing
drop if year==.
encode HHID, gen(hhid)

* Use value of lags within panel to fill in district names
bysort HHID (year):	g byte fillTag = dist2011[1]== dist2011[2]

* Replace district name from district variable
clonevar distName = district
bys HHID (year): replace distName = district[2] if district==""

* Fix the sub-Region variables
recode region (0 = 1)

* Create a tag for splitoffs
g byte splitOff_all = (spitoff10_11 == 1 | spitoff09_10 ==1)

* Backfill sub-region information
clonevar subRegion = sregion
bysort HHID (year): replace subRegion = subRegion[3] if splitOff_all != 1

* Create a new label set for subRegion values
la def subreg 1 "Kampala" 2 "Central-1" 3 "Central-2" 4 "East-Central" /*
*/ 5 "Eastern" 6 "Mid-North" 7 "North-East" 8 "West-Nile" 9 "Mid-West" 10 "Southwest"
la val subRegion subreg

