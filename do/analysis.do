*********************************************************
*********************************************************
*                  DEWORMING AND TRUST                  *	
*              Descriptives and Regressions			    *
***      		Last modified in May 2025        	 ****
*********************************************************
*********************************************************

***********
**# Setup
***********

clear all
set more off
set maxvar 32000

*********************
**# Define Programs
*********************

do "$do/programs.do"

global controls "con_cost_sharing con_saturation_dm con_demeaned_popT_6k con_zoneidI2-con_zoneidI8 con_pup_pop con_month_interviewI1_KLPS con_month_interviewI2_KLPS con_month_interviewI3_KLPS con_month_interviewI4_KLPS con_month_interviewI5_KLPS con_month_interviewI6_KLPS con_month_interviewI7_KLPS con_month_interviewI8_KLPS con_month_interviewI9_KLPS con_month_interviewI10_KLPS con_month_interviewI11_KLPS con_month_interviewI12_KLPS  con_std98_base_I2 -con_std98_base_I6 con_avgtest96 con_wave2  female voced i.interview_year_KLPS"

*****************
**# Main Tables
*****************

use "$data/KLPS.dta", clear
keep if inlist(survey_round,1,2,3)
local col_width 200

**## Table 1: Pairwise correlations between trust measures and human capital

preserve

global outcomes_corr    "trust_general trust_tribe trust_othertribes trust_church trust_otherchurch"
global covariates_corr  "educ_control cov_ravens_KLPS3 cov_fedu_KLPS4 cov_medu_KLPS4"
global het1				"older"
global het2				"younger"
global panelA			"all participants"
global panelB			"older participants"
global panelC			"younger participants"
global tablename		"T1" // T1 instead of T2
** global header			"Tone" // idk what this does
correlations				
restore

**## Table 2: The effect of the deworming treatment on education

	* Column 1
	preserve 
		keep if inlist(survey_round,3) // only KLPS-1 for now
		global outcomes 	    "cov_eduattainment_KLPS3"
		global het1				"older"
		global het2				"younger"
		global panelA			"all participants"
		global panelB			"older participants"
		global panelC			"younger participants"
		global tablename		"T3_edu"
		global header			"Ttwo"
		regressions
	restore







	
	