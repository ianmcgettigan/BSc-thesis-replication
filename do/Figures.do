****************************************************************
****************************************************************
**               ON THE DETERMINANTS OF TRUST                 **
**                  FIGURES MASTER DO FILE                    **
****************************************************************
****************************************************************

/* BY: IAN MCGETTIGAN
JUNE 2025
This file contains the code to reproduce all the figures. 
*/

* PREAMBLE

global dir "~/Documents/bsc3/sem2/bscthesis" // change to where data and do are

cd $dir

cap mkdir "$dir/tables_and_figures"

global data   = "$dir/data"
global do     =   "$dir/do"
global tables = "$dir/tables_and_figures"

clear all
clear matrix
set more off
set maxvar 32000
set varabbrev on

**## Figure 1: Trust over time (KLPS-1--3), by measure of trust

	use "$data/KLPS.dta", clear

	preserve
	
	drop if survey_round==4
	sort survey_round
	
	global outcomes 	   "trust_general trust_tribe trust_othertribes trust_church trust_otherchurch"
	
	foreach outcome of varlist $outcomes {
		egen mean_`outcome' = mean(`outcome'), by(survey_round)
		egen sd_`outcome' = sd(`outcome'), by(survey_round)
	}
	
	keep survey_round mean_trust_general sd_trust_general ///
     mean_trust_tribe   sd_trust_tribe   ///
     mean_trust_othertribes sd_trust_othertribes ///
     mean_trust_church  sd_trust_church  ///
     mean_trust_otherchurch sd_trust_otherchurch
	 
	 twoway ///
  (scatter mean_trust_general    survey_round, msymbol(circle)  connect(L) msize(medium)) ///
  (scatter mean_trust_tribe      survey_round, msymbol(square)  connect(L) msize(medium)) ///
  (scatter mean_trust_othertribes survey_round, msymbol(diamond) connect(L) msize(medium)) ///
  (scatter mean_trust_church     survey_round, msymbol(triangle) connect(L) msize(medium)) ///
  (scatter mean_trust_otherchurch survey_round, msymbol(plus)    connect(L) msize(medium)), ///
    xlabel(1 "1" 2 "2" 3 "3")          ///
	xtitle("KLPS round") 				  ///
    yscale(range(0 1))                    ///
    ytitle("Mean trust (0–1)")            ///
    legend(                               ///
      order( 1 "General trust"            ///
             2 "Trust in tribe"           ///
             3 "Trust in other tribes"    ///
             4 "Trust in church"          ///
             5 "Trust in other churches") ///
      cols(1) ///
	 )
	 
	 graph export "$tables/trust_by_round.pdf", replace as(pdf) 
	 
	 restore
	 
**## Figure 2: Difference in trust between sex over time by measure of trust

	preserve
	
	drop if survey_round==4

	collapse (mean) ///
    trust_general     trust_tribe ///
    trust_othertribes trust_church trust_otherchurch,  ///
	by(survey_round female)
  
	drop if missing(female)

	reshape wide ///
    trust_general trust_tribe trust_othertribes trust_church trust_otherchurch, ///
	i(survey_round) j(female)
  
	gen diff_general      = trust_general0      - trust_general1
	gen diff_tribe        = trust_tribe0        - trust_tribe1
	gen diff_othertribes  = trust_othertribes0  - trust_othertribes1
	gen diff_church       = trust_church0       - trust_church1
	gen diff_otherchurch  = trust_otherchurch0  - trust_otherchurch1

	twoway ///
	(scatter diff_general      survey_round, msymbol(circle)  connect(L) msize(medium) sort) ///
	(scatter diff_tribe        survey_round, msymbol(square)  connect(L) msize(medium) sort) ///
	(scatter diff_othertribes  survey_round, msymbol(diamond) connect(L) msize(medium) sort) ///
	(scatter diff_church       survey_round, msymbol(triangle) connect(L) msize(medium) sort) ///
	(scatter diff_otherchurch  survey_round, msymbol(plus)    connect(L) msize(medium) sort), ///
    xlabel(1 "1" 2 "2" 3 "3")      ///
    xtitle("KLPS round")            ///
    ytitle("Male – Female Trust")     ///
    yline(0, lpattern(dash))          ///
    legend(                           ///
      order(1 "General" 2 "Tribe" 3 "Other tribes"  ///
            4 "Church" 5 "Other churches")       ///
      cols(1)     ///
    )

	graph export "$tables/trust_by_round_sex.pdf", replace as(pdf)
	
	restore
	
**## Figure 3: Difference in trust b/w low and high educ per measure by round

	preserve
	
	drop if survey_round==4
	
	gen high_educ = cov_eduattainment_KLPS3 >= 10
	
	collapse (mean) ///
    trust_general trust_tribe trust_othertribes trust_church trust_otherchurch, ///
	by(survey_round high_educ)
	
	reshape wide trust_general trust_tribe trust_othertribes trust_church trust_otherchurch, ///
	i(survey_round) j(high_educ)
  
	gen diff_general     = trust_general0     - trust_general1
	gen diff_tribe       = trust_tribe0       - trust_tribe1
	gen diff_othertribes = trust_othertribes0 - trust_othertribes1
	gen diff_church      = trust_church0    - trust_church1
	gen diff_otherchurch = trust_otherchurch0 - trust_otherchurch1
	
	twoway ///
	(scatter diff_general     survey_round, msymbol(circle)  connect(L) msize(medium) sort) ///
	(scatter diff_tribe       survey_round, msymbol(square)  connect(L) msize(medium) sort) ///
	(scatter diff_othertribes survey_round, msymbol(diamond) connect(L) msize(medium) sort) ///
	(scatter diff_church      survey_round, msymbol(triangle) connect(L) msize(medium) sort) ///
	(scatter diff_otherchurch survey_round, msymbol(plus)    connect(L) msize(medium) sort), ///
	xlabel(1 "1" 2 "2" 3 "3") ///
    xtitle("KLPS round") ///
    ytitle("Low – High education trust") ///
    yline(0, lpattern(dash)) ///
    legend( ///
      order(1 "General" 2 "Tribe" 3 "Other tribes" 4 "Church" 5 "Other churches") ///
      cols(1) ///
    )

	graph export "$tables/trust_by_round_educ.pdf", replace as(pdf)
	
	restore

**## Figure 4: Difference in trust b/w younger/older samples per measure by round

	preserve
	
	drop if survey_round==4
	
	sort survey_round younger
	
	collapse (mean) ///
    trust_general     trust_tribe ///
    trust_othertribes trust_church trust_otherchurch,  ///
	by(survey_round younger)
	
	drop if missing(younger)
	
	reshape wide ///
    trust_general trust_tribe trust_othertribes trust_church trust_otherchurch, ///
	i(survey_round) j(younger)
	
	gen diff_general     = trust_general0     - trust_general1
	gen diff_tribe       = trust_tribe0       - trust_tribe1
	gen diff_othertribes = trust_othertribes0 - trust_othertribes1
	gen diff_church      = trust_church0    - trust_church1
	gen diff_otherchurch = trust_otherchurch0 - trust_otherchurch1
	
	twoway ///
    (scatter diff_general     survey_round, msymbol(circle)  connect(L) msize(medium) sort) ///
    (scatter diff_tribe       survey_round, msymbol(square)  connect(L) msize(medium) sort) ///
    (scatter diff_othertribes survey_round, msymbol(diamond) connect(L) msize(medium) sort) ///
    (scatter diff_church      survey_round, msymbol(triangle) connect(L) msize(medium) sort) ///
    (scatter diff_otherchurch survey_round, msymbol(plus)    connect(L) msize(medium) sort), ///
	xlabel(1 "1" 2 "2" 3 "3")           ///
	xtitle("KLPS round")                 ///
	ytitle("Younger – Older trust")          ///
	yline(0, lpattern(dash) lcolor(gs8))   ///
	legend(                                ///
		order(1 "General trust"             ///
          2 "Trust in tribe"            ///
          3 "Trust in other tribes"     ///
          4 "Trust in church"           ///
          5 "Trust in other churches")  ///
    cols(1)    ///
	)
	
	graph export "$tables/trust_by_round_age.pdf", replace as(pdf)
	
	restore

	
	
	

		
	
	
	


	
	